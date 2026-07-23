//
//  AlertLocalPersistence.swift
//  CryptoTest
//
//  Created by Kiko on 22/07/2026.
//

@MainActor
protocol AlertLocalPersistence {
    func getAlerts() throws -> [AlertModel]
    func addAlert(_ alert: AlertModel) throws
    func removeAlert(alertId: String) throws
    func syncAlerts(_ alerts: [AlertModel]) throws
    func markTriggered(alertId: String) throws
}
