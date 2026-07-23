//
//  SettingsView.swift
//  CryptoTest
//
//  Created by Kiko on 18/07/2026.
//

import SwiftUI

struct SettingsView: View {

    @Environment(AuthManager.self) private var authManager
    @Environment(AlertManager.self) private var alertManager
    @Environment(WatchlistManager.self) private var watchlistManager

    @AppStorage("themePreference") private var themePreference: ThemePreference = .system
    @AppStorage("alertNotificationsEnabled") private var notificationsEnabled = true

    @State private var showDeleteConfirmation = false
    @State private var showPasswordPrompt = false
    @State private var password = ""
    @State private var deletingAccount = false
    @State private var errorMessage: String?
    @State private var showError = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScreenHeader(title: "Settings")
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        accountSection
                        appearanceRow
                        notificationsRow

                        Button("Log out", role: .destructive, action: logout)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 24)

                        Button(deletingAccount ? "Deleting account…" : "Delete account", role: .destructive) {
                            showDeleteConfirmation = true
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 12)
                        .disabled(deletingAccount)
                    }
                    .padding(20)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .alert(errorMessage ?? "", isPresented: $showError) {}
            .confirmationDialog(
                "Delete account",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) { showPasswordPrompt = true }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This permanently deletes your account, watchlist, and alerts. This can't be undone.")
            }
            .alert("Confirm your password", isPresented: $showPasswordPrompt) {
                SecureField("Password", text: $password)
                Button("Delete", role: .destructive, action: deleteAccount)
                Button("Cancel", role: .cancel) { password = "" }
            } message: {
                Text("For your security, enter your password to permanently delete your account.")
            }
            .onChange(of: notificationsEnabled) { _, isEnabled in
                guard isEnabled else { return }
                Task {
                    await alertManager.requestNotificationAuthorization()
                }
            }
        }
    }

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Signed in as")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(authManager.authUser?.email ?? "")
                .font(.title3.bold())
        }
        .padding(.bottom, 24)
    }

    private var appearanceRow: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Appearance")
                    .font(.subheadline.weight(.semibold))
                Text("Light or dark theme")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Picker("Appearance", selection: $themePreference) {
                ForEach(ThemePreference.allCases) { preference in
                    Text(preference.label).tag(preference)
                }
            }
            .pickerStyle(.segmented)
            .fixedSize()
        }
        .padding(.vertical, 14)
    }

    private var notificationsRow: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Alert notifications")
                    .font(.subheadline.weight(.semibold))
                Text("Push alerts when targets hit")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Toggle("Alert notifications", isOn: $notificationsEnabled)
                .labelsHidden()
        }
        .padding(.vertical, 14)
    }

    private func logout() {
        do {
            try authManager.logout()
        } catch {
            present(error.localizedDescription)
        }
    }

    private func deleteAccount() {
        let enteredPassword = password
        password = ""

        guard !enteredPassword.isEmpty else {
            present("Enter your password to delete your account.")
            return
        }

        deletingAccount = true
        Task {
            defer { deletingAccount = false }
            do {
                // Re-authenticate first, before anything is destroyed
                // Firebase rejects deletion when the last sign-in is over 5 minutes old
                try await authManager.reauthenticate(password: enteredPassword)
                try await watchlistManager.deleteAllData()
                try await alertManager.deleteAllData()
                try await authManager.deleteAccount()
            } catch {
                present(deleteAccountMessage(for: error))
            }
        }
    }

    private func deleteAccountMessage(for error: Error) -> String {
        let nsError = error as NSError
        guard nsError.domain == "FIRAuthErrorDomain" else {
            return "Couldn't delete your account. \(error.localizedDescription)"
        }

        switch nsError.code {
        case 17009, 17004:
            return "That password isn't right. Nothing has been deleted — try again."
        case 17010:
            return "Too many attempts. Wait a few minutes and try again."
        case 17014:
            return "For your security, deleting your account needs a recent sign-in. Log out, log back in, then try again."
        default:
            return "Couldn't delete your account. \(error.localizedDescription)"
        }
    }

    private func present(_ message: String) {
        errorMessage = message
        showError = true
    }
}

#Preview {
    SettingsView()
        .environment(AuthManager(authService: MockAuthService(user: .mock)))
        .environment(AlertManager(alertService: MockAlertService()))
        .environment(WatchlistManager(watchlistService: MockWatchlistService()))
}
