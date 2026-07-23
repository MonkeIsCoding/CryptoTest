//
//  MockNotificationService.swift
//  CryptoTest
//
//  Created by Kiko on 22/07/2026.
//

@MainActor
struct MockNotificationService: NotificationService {

    let onNotify: ((String, AlertModel) -> Void)?

    init(onNotify: ((String, AlertModel) -> Void)? = nil) {
        self.onNotify = onNotify
    }

    func requestAuthorization() async {}

    func notifyAlertTriggered(coinName: String, alert: AlertModel) async {
        onNotify?(coinName, alert)
    }
}
