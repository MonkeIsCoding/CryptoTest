//
//  AlertService.swift
//  CryptoTest
//
//  Created by Kiko on 21/07/2026.
//

protocol AlertService {
    func fetchAlerts() async throws -> [AlertModel]
    func addAlert(coinId: String, price: Double, type: AlertType) async throws -> AlertModel
    func removeAlert(alertId: String) async throws
    func markTriggered(alertId: String) async throws
    func deleteAllForCurrentUser() async throws
}
