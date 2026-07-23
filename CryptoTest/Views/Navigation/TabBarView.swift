//
//  TabView.swift
//  CryptoTest
//
//  Created by Kiko on 19/07/2026.
//

import SwiftUI

struct TabBarView: View {

    @Environment(CoinManager.self) private var coinManager
    @Environment(AlertManager.self) private var alertManager

    var body: some View {
        TabView {
            Tab {
                HomeView()
            } label: {
                Label("Home", systemImage: "house")
                    .labelStyle(.iconOnly)
            }
            Tab {
                WatchlistView()
            } label: {
                Label("Watchlist", systemImage: "star")
                    .labelStyle(.iconOnly)
            }
            Tab {
                AlertsView()
            } label: {
                Label("Alerts", systemImage: "list.bullet")
                    .labelStyle(.iconOnly)
            }
            Tab {
                SettingsView()
            } label: {
                Label("Settings", systemImage: "gear")
                    .labelStyle(.iconOnly)
            }
        }
        .task {
            await alertManager.requestNotificationAuthorization()
        }
        .onChange(of: coinManager.coins) { _, newCoins in
            Task {
                await alertManager.checkAlerts(against: newCoins)
            }
        }
    }
}

#Preview {
    TabBarView()
        .environment(AuthManager(authService: MockAuthService()))
        .environment(CoinManager(coinService: MockCoinService()))
        .environment(WatchlistManager(watchlistService: MockWatchlistService()))
        .environment(AlertManager(alertService: MockAlertService()))
}
