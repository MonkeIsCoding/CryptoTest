//
//  MockAlertService.swift
//  CryptoTest
//
//  Created by Kiko on 21/07/2026.
//

import Foundation

class MockAlertService: AlertService {

    private let alerts: [AlertModel]
    private let shouldFail: Bool

    private(set) var addedAlerts: [AlertModel] = []
    private(set) var removedAlertIds: [String] = []
    private(set) var triggeredAlertIds: [String] = []
    private(set) var didDeleteAllForCurrentUser = false

    init(
        alerts: [AlertModel] = [AlertModel(id: "", userId: "", coinId: "", targetPrice: 0, type: .above)],
        shouldFail: Bool = false
    ) {
        self.alerts = alerts
        self.shouldFail = shouldFail
    }

    func fetchAlerts() async throws -> [AlertModel]  {
        if shouldFail { throw URLError(.notConnectedToInternet) }
        return alerts
    }

    func addAlert(coinId: String, price: Double, type: AlertType) async throws -> AlertModel {
        if shouldFail { throw URLError(.notConnectedToInternet) }
        let alert = AlertModel(id: UUID().uuidString, userId: "", coinId: coinId, targetPrice: price, type: type)
        addedAlerts.append(alert)
        return alert
    }

    func removeAlert(alertId: String) async throws {
        if shouldFail { throw URLError(.notConnectedToInternet) }
        removedAlertIds.append(alertId)
    }

    func markTriggered(alertId: String) async throws {
        if shouldFail { throw URLError(.notConnectedToInternet) }
        triggeredAlertIds.append(alertId)
    }

    func deleteAllForCurrentUser() async throws {
        if shouldFail { throw URLError(.notConnectedToInternet) }
        didDeleteAllForCurrentUser = true
    }
}
