//
//  AlertsView.swift
//  CryptoTest
//
//  Created by Kiko on 18/07/2026.
//

import SwiftUI

struct AlertsView: View {

    @Environment(AlertManager.self) private var alertManager
    @Environment(CoinManager.self) private var coinManager

    @State private var errorMessage: String?
    @State private var showError = false

    var body: some View {
        NavigationStack {
            ScreenStateWrapper(
                title: "Alerts",
                offlineMessage: "Offline — showing last synced alerts",
                isEmpty: alertManager.alerts.isEmpty,
                emptyTitle: "No Alerts",
                emptySystemImage: "bell",
                emptyDescription: "Create a price alert from a coin's detail screen.",
                load: alertManager.fetchAlerts
            ) {
                List(alertManager.alerts) { alert in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(coinName(for: alert))
                                .font(.body.bold())
                            Text("\(alert.type == .above ? "Above" : "Below") \(alert.targetPrice.formatted(.currency(code: "EUR")))")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                        Spacer()
                        PillBadge(status: alert.triggered ? .triggered : .watching)
                    }
                    .listRowSeparatorTint(Color.primary.opacity(0.08))
                    .swipeActions {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            delete(alert)
                        }
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(accessibilityLabel(for: alert))
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .toolbar(.hidden, for: .navigationBar)
            .alert(errorMessage ?? "", isPresented: $showError) {}
        }
    }

    private func coinName(for alert: AlertModel) -> String {
        coinManager.coins.first(where: { $0.id == alert.coinId })?.name ?? alert.coinId.capitalized
    }

    private func accessibilityLabel(for alert: AlertModel) -> String {
        let condition = alert.type == .above ? "Above" : "Below"
        let price = alert.targetPrice.formatted(.currency(code: "EUR"))
        let status = alert.triggered ? "Triggered" : "Watching"
        return "\(coinName(for: alert)), \(condition) \(price), \(status)"
    }

    private func delete(_ alert: AlertModel) {
        Task {
            do {
                try await alertManager.removeAlert(alertId: alert.id)
            } catch {
                errorMessage = "Couldn't delete the alert. Please try again."
                showError = true
            }
        }
    }
}

#Preview {
    AlertsView()
        .environment(AlertManager(alertService: MockAlertService()))
        .environment(CoinManager(coinService: MockCoinService()))
        .environment(NetworkMonitor())
}
