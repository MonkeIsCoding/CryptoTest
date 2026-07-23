//
//  AlertManagerTests.swift
//  CryptoTestTests
//
//  Created by Kiko on 22/07/2026.
//

import Testing
import Foundation
@testable import CryptoTest

@MainActor
struct AlertManagerTests {

    private func makeAlert(
        id: String = UUID().uuidString,
        coinId: String = "bitcoin",
        targetPrice: Double = 50_000,
        type: AlertType = .above,
        triggered: Bool = false
    ) -> AlertModel {
        AlertModel(id: id, userId: "user", coinId: coinId, targetPrice: targetPrice, type: type, triggered: triggered)
    }

    private func makeCoin(id: String = "bitcoin", price: Double, name: String = "Bitcoin") -> CoinModel {
        CoinModel(
            id: id,
            symbol: id,
            name: name,
            image: nil,
            currentPrice: price,
            marketCap: nil,
            marketCapRank: nil,
            priceChange24h: nil,
            priceChangePercentage24h: nil,
            lastUpdated: nil
        )
    }

    @Test func fetchAlerts_onSuccess_updatesAlertsAndSyncsLocal() async throws {
        let alert = makeAlert(id: "1")
        let context = TestModelContainer.makeContext()
        let manager = AlertManager(
            alertService: MockAlertService(alerts: [alert]),
            local: SwiftDataAlertLocalPersistence(context: context)
        )

        try await manager.fetchAlerts()

        #expect(manager.alerts.map(\.id) == ["1"])

        let mirrored = try SwiftDataAlertLocalPersistence(context: context).getAlerts()
        #expect(mirrored.map(\.id) == ["1"])
    }

    @Test func fetchAlerts_onFailure_fallsBackToCachedAlertsAndRethrows() async throws {
        let cached = makeAlert(id: "cached")
        let manager = AlertManager(
            alertService: MockAlertService(shouldFail: true),
            local: MockAlertLocalPersistence(alerts: [cached])
        )

        do {
            try await manager.fetchAlerts()
            Issue.record("Expected fetchAlerts to rethrow the underlying error.")
        } catch is URLError {
            // success
        } catch {
            Issue.record("Wrong error thrown: \(error)")
        }

        #expect(manager.alerts.map(\.id) == ["cached"])
    }

    @Test func addAlert_persistsAndAppendsAlert() async throws {
        let alertService = MockAlertService()
        let context = TestModelContainer.makeContext()
        let manager = AlertManager(
            alertService: alertService,
            local: SwiftDataAlertLocalPersistence(context: context)
        )

        try await manager.addAlert(coinId: "bitcoin", price: 50_000, type: .above, coins: [])

        #expect(alertService.addedAlerts.count == 1)
        #expect(manager.alerts.count == 1)

        let mirrored = try SwiftDataAlertLocalPersistence(context: context).getAlerts()
        #expect(mirrored.count == 1)
    }

    @Test func addAlert_whenConditionAlreadyMet_immediatelyMarksTriggeredAndNotifies() async throws {
        var notified: [(coinName: String, alert: AlertModel)] = []
        let alertService = MockAlertService()
        let context = TestModelContainer.makeContext()
        let manager = AlertManager(
            alertService: alertService,
            local: SwiftDataAlertLocalPersistence(context: context),
            notificationService: MockNotificationService { coinName, alert in
                notified.append((coinName, alert))
            }
        )
        let coin = makeCoin(price: 40_000)

        // Below alert, but the price is already under the target.
        try await manager.addAlert(coinId: "bitcoin", price: 45_000, type: .below, coins: [coin])

        #expect(manager.alerts.first?.triggered == true)
        #expect(notified.count == 1)
        #expect(alertService.triggeredAlertIds.count == 1)

        let mirrored = try SwiftDataAlertLocalPersistence(context: context).getAlerts()
        #expect(mirrored.first?.triggered == true)
    }

    @Test func removeAlert_removesFromArrayAndCallsServices() async throws {
        let alert = makeAlert(id: "1")
        let alertService = MockAlertService(alerts: [alert])
        let context = TestModelContainer.makeContext()
        let manager = AlertManager(
            alertService: alertService,
            local: SwiftDataAlertLocalPersistence(context: context)
        )
        try await manager.fetchAlerts()

        try await manager.removeAlert(alertId: "1")

        #expect(manager.alerts.isEmpty)
        #expect(alertService.removedAlertIds == ["1"])

        let mirrored = try SwiftDataAlertLocalPersistence(context: context).getAlerts()
        #expect(mirrored.isEmpty)
    }

    @Test func checkAlerts_marksAboveThresholdCrossingAsTriggered() async throws {
        let alert = makeAlert(id: "1", targetPrice: 50_000, type: .above)
        let alertService = MockAlertService(alerts: [alert])
        var notified: [(coinName: String, alert: AlertModel)] = []
        let manager = AlertManager(
            alertService: alertService,
            local: MockAlertLocalPersistence(),
            notificationService: MockNotificationService { coinName, alert in
                notified.append((coinName, alert))
            }
        )
        try await manager.fetchAlerts()

        await manager.checkAlerts(against: [makeCoin(price: 51_000)])

        #expect(manager.alerts.first?.triggered == true)
        #expect(notified.count == 1)
        #expect(alertService.triggeredAlertIds == ["1"])
    }

    @Test func checkAlerts_marksBelowThresholdCrossingAsTriggered() async throws {
        let alert = makeAlert(id: "1", targetPrice: 50_000, type: .below)
        let alertService = MockAlertService(alerts: [alert])
        let manager = AlertManager(alertService: alertService, local: MockAlertLocalPersistence())
        try await manager.fetchAlerts()

        await manager.checkAlerts(against: [makeCoin(price: 49_000)])

        #expect(manager.alerts.first?.triggered == true)
        #expect(alertService.triggeredAlertIds == ["1"])
    }

    @Test func checkAlerts_doesNotRetriggerAlreadyTriggeredAlert() async throws {
        let alert = makeAlert(id: "1", targetPrice: 50_000, type: .above, triggered: true)
        let alertService = MockAlertService(alerts: [alert])
        var notified: [(coinName: String, alert: AlertModel)] = []
        let manager = AlertManager(
            alertService: alertService,
            local: MockAlertLocalPersistence(),
            notificationService: MockNotificationService { coinName, alert in
                notified.append((coinName, alert))
            }
        )
        try await manager.fetchAlerts()

        await manager.checkAlerts(against: [makeCoin(price: 60_000)])

        #expect(notified.isEmpty, "Already-triggered alerts should not fire another notification.")
        #expect(alertService.triggeredAlertIds.isEmpty, "Already-triggered alerts should not be re-persisted as triggered.")
    }

    @Test func checkAlerts_skipsWhenCoinMissingOrPriceNil() async throws {
        let alert = makeAlert(id: "1", coinId: "bitcoin", targetPrice: 50_000, type: .above)
        let alertService = MockAlertService(alerts: [alert])
        let manager = AlertManager(alertService: alertService, local: MockAlertLocalPersistence())
        try await manager.fetchAlerts()

        await manager.checkAlerts(against: [makeCoin(id: "ethereum", price: 3_000)])

        #expect(manager.alerts.first?.triggered == false)
        #expect(alertService.triggeredAlertIds.isEmpty)
    }

    @Test func checkAlerts_whenAlertsAreReplacedMidRun_doesNotCrash() async throws {
        let seeded = (1...5).map { makeAlert(id: "\($0)", targetPrice: 100) }
        let manager = AlertManager(
            alertService: MockAlertService(alerts: seeded),
            local: MockAlertLocalPersistence(),
            notificationService: MockNotificationService()
        )
        try await manager.fetchAlerts()

        async let check: Void = manager.checkAlerts(against: [makeCoin(price: 60_000)])
        async let clear: Void = manager.deleteAllData()
        _ = try await (check, clear)

        #expect(manager.alerts.isEmpty)
    }

    @Test func deleteAllData_clearsRemoteLocalAndInMemoryState() async throws {
        let alert = makeAlert(id: "1")
        let alertService = MockAlertService(alerts: [alert])
        let context = TestModelContainer.makeContext()
        let manager = AlertManager(
            alertService: alertService,
            local: SwiftDataAlertLocalPersistence(context: context)
        )
        try await manager.fetchAlerts()

        try await manager.deleteAllData()

        #expect(alertService.didDeleteAllForCurrentUser == true)
        #expect(manager.alerts.isEmpty)

        let mirrored = try SwiftDataAlertLocalPersistence(context: context).getAlerts()
        #expect(mirrored.isEmpty)
    }

    @Test func deleteAllData_onRemoteFailure_rethrows() async throws {
        let alertService = MockAlertService(shouldFail: true)
        let manager = AlertManager(alertService: alertService, local: MockAlertLocalPersistence())

        do {
            try await manager.deleteAllData()
            Issue.record("Expected deleteAllData to rethrow the underlying error.")
        } catch is URLError {
            // success
        } catch {
            Issue.record("Wrong error thrown: \(error)")
        }
    }
}
