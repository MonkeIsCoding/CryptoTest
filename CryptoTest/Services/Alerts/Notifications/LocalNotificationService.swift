//
//  LocalNotificationService.swift
//  CryptoTest
//
//  Created by Kiko on 22/07/2026.
//

import Foundation
import UserNotifications


@MainActor
struct LocalNotificationService: NotificationService {

    private let center = UNUserNotificationCenter.current()

    func requestAuthorization() async {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            if !granted {
                print("Notifications: authorization was denied — alerts will fire but no banner will be shown.")
            }
        } catch {
            print("Failed to request notification authorization: \(error)")
        }
    }

    func notifyAlertTriggered(coinName: String, alert: AlertModel) async {
        let notificationsEnabled = UserDefaults.standard.object(forKey: "alertNotificationsEnabled") as? Bool ?? true
        guard notificationsEnabled else {
            print("Notifications: skipped — the in-app 'Alert notifications' toggle in Settings is off.")
            return
        }

        let status = await center.notificationSettings().authorizationStatus
        guard status == .authorized || status == .provisional || status == .ephemeral else {
            print("Notifications: skipped — iOS permission not granted (status \(status.rawValue)). Enable it in iOS Settings > CryptoTest > Notifications.")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Price Alert"
        content.body = "\(coinName) is now \(alert.type == .above ? "above" : "below") \(alert.targetPrice.formatted(.currency(code: "EUR")))"
        content.sound = .default

        let request = UNNotificationRequest(identifier: alert.id, content: content, trigger: nil)
        do {
            try await center.add(request)
        } catch {
            print("Notifications: failed to schedule alert notification: \(error)")
        }
    }
}
