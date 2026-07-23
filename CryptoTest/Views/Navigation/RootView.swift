//
//  ContentView.swift
//  CryptoTest
//
//  Created by Kiko on 18/07/2026.
//

import SwiftUI

struct RootView: View {

    @Environment(AuthManager.self) var authManager
    @Environment(NetworkMonitor.self) private var networkMonitor

    @AppStorage("themePreference") private var themePreference: ThemePreference = .system

    var body: some View {
        Group {
            if let _ = authManager.authUser {
                TabBarView()
            } else {
                WelcomeView()
            }
        }
        .preferredColorScheme(themePreference.colorScheme)
        .task {
            await networkMonitor.startMonitor()
        }
    }
}

#Preview {
    RootView()
        .environment(AuthManager(authService: MockAuthService()))
        .environment(NetworkMonitor())
}
