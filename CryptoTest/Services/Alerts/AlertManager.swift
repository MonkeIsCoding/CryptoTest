//
//  AlertManager.swift
//  CryptoTest
//
//  Created by Kiko on 18/07/2026.
//

import Foundation

@MainActor
@Observable
class AlertManager {

    private let alertService: AlertService
    private let local: AlertLocalPersistence
    private let notificationService: NotificationService

    private(set) var alerts: [AlertModel] = []

    init(
        alertService: AlertService,
        local: AlertLocalPersistence = MockAlertLocalPersistence(),
        notificationService: NotificationService = MockNotificationService()
    ) {
        self.alertService = alertService
        self.local = local
        self.notificationService = notificationService
    }

    func fetchAlerts() async throws {
        do {
            let fetched = try await alertService.fetchAlerts()
            alerts = fetched
            try local.syncAlerts(fetched)
        } catch {
            alerts = try local.getAlerts()
            throw error
        }
    }

    func addAlert(coinId: String, price: Double, type: AlertType, coins: [CoinModel]) async throws {
        let alert = try await alertService.addAlert(coinId: coinId, price: price, type: type)
        try local.addAlert(alert)
        alerts.append(alert)
        await checkAlerts(against: coins)
    }

    func removeAlert(alertId: String) async throws {
        try await alertService.removeAlert(alertId: alertId)
        try local.removeAlert(alertId: alertId)
        alerts.removeAll { $0.id == alertId }
    }

    func deleteAllData() async throws {
        try await alertService.deleteAllForCurrentUser()
        try local.syncAlerts([])
        alerts = []
    }

    func requestNotificationAuthorization() async {
        await notificationService.requestAuthorization()
    }

    func checkAlerts(against coins: [CoinModel]) async {
        for alert in alerts {
            guard !alert.triggered else { continue }
            guard let coin = coins.first(where: { $0.id == alert.coinId }),
                  let price = coin.currentPrice else { continue }

            let isMet = switch alert.type {
            case .above: price >= alert.targetPrice
            case .below: price <= alert.targetPrice
            }
            guard isMet else { continue }

            guard let index = alerts.firstIndex(where: { $0.id == alert.id }) else { continue }
            alerts[index].triggered = true

            await notificationService.notifyAlertTriggered(coinName: coin.name, alert: alert)

            do {
                try local.markTriggered(alertId: alert.id)
                try await alertService.markTriggered(alertId: alert.id)
            } catch {
                print("Failed to persist triggered alert \(alert.id): \(error)")
            }
        }
    }
}
