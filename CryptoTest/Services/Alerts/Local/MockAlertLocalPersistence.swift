//
//  MockAlertLocalPersistence.swift
//  CryptoTest
//
//  Created by Kiko on 22/07/2026.
//

@MainActor
struct MockAlertLocalPersistence: AlertLocalPersistence {

    let alerts: [AlertModel]

    init(alerts: [AlertModel] = []) {
        self.alerts = alerts
    }

    func getAlerts() throws -> [AlertModel] {
        alerts
    }

    func addAlert(_ alert: AlertModel) throws {}

    func removeAlert(alertId: String) throws {}

    func syncAlerts(_ alerts: [AlertModel]) throws {}

    func markTriggered(alertId: String) throws {}
}
