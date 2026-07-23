//
//  CoinDetailView.swift
//  CryptoTest
//
//  Created by Kiko on 19/07/2026.
//

import SwiftUI

struct CoinDetailView: View {

    @Environment(CoinManager.self) private var coinManager
    @Environment(WatchlistManager.self) private var listManager
    @Environment(AlertManager.self) private var alertManager

    let coin: CoinModel

    @State private var chartLabels: [String] = []
    @State private var chartPrices: [Double] = []
    @State private var isLoadingChart = false
    @State private var chartErrorMessage: String?

    @State private var alertType: AlertType = .above
    @State private var targetPrice: Double?
    @State private var creatingAlert = false

    @State private var infoMessage: String?
    @State private var showInfoAlert = false

    private var isWatchlisted: Bool {
        listManager.isWatched(coinId: coin.id)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(coin.name) · \(coin.symbol.uppercased())")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(coin.currentPrice ?? 0, format: .currency(code: "EUR"))
                        .font(.largeTitle.bold())

                    if let change = coin.priceChangePercentage24h {
                        Text("\(change >= 0 ? "+" : "")\(change, specifier: "%.2f")% Today")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.priceChange(change))
                    }
                }

                chartSection

                VStack(spacing: 0) {
                    StatRow(label: "Market cap", value: coin.formattedMarketCap)
                    StatRow(label: "Last updated", value: coin.formattedLastUpdated)
                }

                Button(
                    isWatchlisted ? "Remove from Watchlist" : "Add to Watchlist",
                    action: toggleWatchlist
                )
                .hairlineButton(color: isWatchlisted ? .negative : .accent)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Create alert")
                        .font(.headline)

                    HStack(spacing: 12) {
                        TextField("Target price (EUR)", value: $targetPrice, format: .number)
                            .keyboardType(.decimalPad)
                            .hairlineField()

                        AlertDirectionButton(
                            label: "Above",
                            systemImage: "arrow.up",
                            isSelected: alertType == .above
                        ) {
                            alertType = .above
                        }

                        AlertDirectionButton(
                            label: "Below",
                            systemImage: "arrow.down",
                            isSelected: alertType == .below
                        ) {
                            alertType = .below
                        }
                    }

                    Button(creatingAlert ? "Creating…" : "Create Alert", action: createAlert)
                        .filledButton()
                        .disabled(creatingAlert)
                }
            }
            .padding()
        }
        .navigationTitle(coin.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadChart()
        }
        .alert(infoMessage ?? "", isPresented: $showInfoAlert) {}
    }

    @ViewBuilder
    private var chartSection: some View {
        if isLoadingChart && chartPrices.isEmpty {
            ProgressView()
                .frame(maxWidth: .infinity, minHeight: 220)
        } else if let chartErrorMessage, chartPrices.isEmpty {
            VStack(spacing: 8) {
                Text(chartErrorMessage)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Button("Retry") {
                    Task { await loadChart() }
                }
                .font(.footnote.weight(.semibold))
            }
            .frame(maxWidth: .infinity, minHeight: 220)
        } else {
            PriceChartView(labels: chartLabels, prices: chartPrices)
        }
    }

    private func loadChart() async {
        isLoadingChart = true
        defer { isLoadingChart = false }
        do {
            let history = try await coinManager.fetchPriceHistory(coinId: coin.id)
            chartLabels = history.map { $0.timestamp.formatted(.dateTime.weekday(.abbreviated)) }
            chartPrices = history.map(\.price)
            chartErrorMessage = nil
        } catch {
            chartErrorMessage = error.localizedDescription
        }
    }

    private func toggleWatchlist() {
        let removing = isWatchlisted
        Task {
            do {
                try await listManager.toggleWatchlist(coinId: coin.id)
            } catch {
                infoMessage = "Couldn't \(removing ? "remove from" : "add to") watchlist."
                showInfoAlert = true
            }
        }
    }

    private func createAlert() {
        guard let targetPrice, targetPrice > 0 else {
            infoMessage = "Enter a positive target price."
            showInfoAlert = true
            return
        }
        creatingAlert = true
        Task {
            defer { creatingAlert = false }
            do {
                try await alertManager.addAlert(coinId: coin.id, price: targetPrice, type: alertType, coins: coinManager.coins)
                infoMessage = "You'll be notified when \(coin.name) goes \(alertType == .above ? "above" : "below") \(targetPrice.formatted(.currency(code: "EUR")))."
                self.targetPrice = nil
            } catch {
                infoMessage = "Couldn't create the alert."
            }
            showInfoAlert = true
        }
    }
}

private struct AlertDirectionButton: View {
    let label: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(label, systemImage: systemImage, action: action)
            .labelStyle(.iconOnly)
            .font(.body.bold())
            .foregroundStyle(isSelected ? .white : Color.accentColor)
            .frame(width: 44, height: 44)
            .background {
                Circle().fill(isSelected ? Color.accentColor : Color.clear)
                Circle().strokeBorder(Color.accentColor, lineWidth: 2)
            }
            .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    NavigationStack {
        CoinDetailView(coin: .mock)
            .environment(CoinManager(coinService: MockCoinService()))
            .environment(WatchlistManager(watchlistService: MockWatchlistService()))
            .environment(AlertManager(alertService: MockAlertService()))
    }
}
