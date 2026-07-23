//
//  CryptoTestApp.swift
//  CryptoTest
//
//  Created by Kiko on 18/07/2026.
//

import SwiftUI
import SwiftData
import FirebaseCore
import FirebaseFirestore
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    UNUserNotificationCenter.current().delegate = self
    return true
  }

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([.banner, .sound, .badge])
  }
}

@main
struct CryptoTestApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    private let modelContainer: ModelContainer
    private let networkMonitor = NetworkMonitor()

    private var authManager: AuthManager
    private var watchlistManager: WatchlistManager
    private var coinManager: CoinManager
    private var alertManager: AlertManager

    init() {
        FirebaseApp.configure()

        // Firestore's own persistent offline cache would otherwise serve fetches
        // silently while offline, masking the app's SwiftData offline fallback.
        let firestoreSettings = FirestoreSettings()
        firestoreSettings.cacheSettings = MemoryCacheSettings()
        Firestore.firestore().settings = firestoreSettings

        do {
            modelContainer = try ModelContainer(for: CoinEntity.self, WatchlistEntity.self, AlertEntity.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }

        authManager = .init(authService: FirebaseAuthService())
        coinManager = .init(coinService: FirebaseCoinService(), local: SwiftDataCoinLocalPersistence(context: modelContainer.mainContext))
        watchlistManager = .init(watchlistService: FirebaseWatchlistService(), local: SwiftDataWatchlistLocalPersistence(context: modelContainer.mainContext))
        alertManager = .init(
            alertService: FirebaseAlertService(),
            local: SwiftDataAlertLocalPersistence(context: modelContainer.mainContext),
            notificationService: LocalNotificationService()
        )
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(authManager)
                .environment(coinManager)
                .environment(watchlistManager)
                .environment(alertManager)
                .environment(networkMonitor)
        }
    }
}
