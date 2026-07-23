//
//  SwiftDataAlertLocalPersistenceTests.swift
//  CryptoTestTests
//
//  Created by Kiko on 22/07/2026.
//

import Foundation
import Testing
import SwiftData
@testable import CryptoTest

extension SwiftDataPersistenceTests {

    @MainActor
    struct AlertLocalPersistenceTests {

        let store: SwiftDataAlertLocalPersistence

        init() {
            store = SwiftDataAlertLocalPersistence(context: TestModelContainer.makeContext())
        }

        private func makeAlert(
            id: String = UUID().uuidString,
            coinId: String = "bitcoin",
            targetPrice: Double = 50_000,
            type: AlertType = .above,
            addedAt: Date = .now,
            triggered: Bool = false
        ) -> AlertModel {
            AlertModel(id: id, userId: "user", coinId: coinId, targetPrice: targetPrice, type: type, addedAt: addedAt, triggered: triggered)
        }

        @Test func getAlerts_whenEmpty_returnsEmpty() throws {
            #expect(try store.getAlerts().isEmpty)
        }

        @Test func addAlert_persistsAlert() throws {
            try store.addAlert(makeAlert(id: "1"))

            let saved = try store.getAlerts()
            let alert = try #require(saved.first)
            #expect(saved.count == 1)
            #expect(alert.id == "1")
        }

        @Test func getAlerts_sortedByAddedAtDescending() throws {
            try store.addAlert(makeAlert(id: "1", addedAt: .now.addingTimeInterval(-1000)))
            try store.addAlert(makeAlert(id: "2", addedAt: .now))

            #expect(try store.getAlerts().map(\.id) == ["2", "1"], "Alerts should be returned newest-added first")
        }

        @Test func removeAlert_removesMatchingAlert() throws {
            try store.addAlert(makeAlert(id: "1"))
            try store.removeAlert(alertId: "1")

            #expect(try store.getAlerts().isEmpty)
        }

        @Test func markTriggered_flipsFlagAndPersists() throws {
            try store.addAlert(makeAlert(id: "1", triggered: false))
            try store.markTriggered(alertId: "1")

            let saved = try store.getAlerts()
            let alert = try #require(saved.first)
            #expect(alert.triggered == true)
        }

        @Test func markTriggered_withUnknownId_doesNothing() throws {
            try store.markTriggered(alertId: "missing")
            #expect(try store.getAlerts().isEmpty)
        }

        @Test func syncAlerts_insertsNewAndRemovesStale() throws {
            try store.addAlert(makeAlert(id: "1"))
            try store.syncAlerts([makeAlert(id: "2")])

            #expect(try store.getAlerts().map(\.id) == ["2"])
        }

        @Test func syncAlerts_updatesTriggeredOnExistingAlert() throws {
            try store.addAlert(makeAlert(id: "1", triggered: false))
            try store.syncAlerts([makeAlert(id: "1", triggered: true)])

            let saved = try store.getAlerts()
            let alert = try #require(saved.first)
            #expect(alert.triggered == true)
        }
    }
}
