//
//  NotificationService.swift
//  CryptoTest
//
//  Created by Kiko on 22/07/2026.
//

@MainActor
protocol NotificationService {
    func requestAuthorization() async
    func notifyAlertTriggered(coinName: String, alert: AlertModel) async
}
