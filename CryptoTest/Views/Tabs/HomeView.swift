//
//  HomeView.swift
//  CryptoTest
//
//  Created by Kiko on 18/07/2026.
//

import SwiftUI

private enum CoinSortOption: String, CaseIterable, Identifiable {
    case rank
    case name
    case priceChange

    var id: String { rawValue }

    var label: String {
        switch self {
        case .rank: "Rank"
        case .name: "Name"
        case .priceChange: "24h Change"
        }
    }
}

struct HomeView: View {

    @Environment(CoinManager.self) private var coinManager
    @State private var searchText = ""
    @State private var sortOption: CoinSortOption = .rank

    private var filteredCoins: [CoinModel] {
        let base: [CoinModel]
        if searchText.isEmpty {
            base = coinManager.coins
        } else {
            base = coinManager.coins.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.symbol.localizedCaseInsensitiveContains(searchText)
            }
        }

        switch sortOption {
        case .rank:
            return base.sorted { ($0.marketCapRank ?? .max) < ($1.marketCapRank ?? .max) }
        case .name:
            return base.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .priceChange:
            return base.sorted { ($0.priceChangePercentage24h ?? -.infinity) > ($1.priceChangePercentage24h ?? -.infinity) }
        }
    }

    var body: some View {
        NavigationStack {
            ScreenStateWrapper(
                title: "Home",
                offlineMessage: "Offline — showing last synced prices",
                isEmpty: coinManager.coins.isEmpty,
                emptyTitle: "No Coins",
                emptySystemImage: "chart.line.uptrend.xyaxis",
                emptyDescription: "Pull to refresh to load the latest prices.",
                load: coinManager.fetchCoins,
                refresh: coinManager.seedCoins
            ) {
                VStack(spacing: 0) {
                    HStack(spacing: 4) {
                        SearchField(text: $searchText, prompt: "Search coins")
                        sortMenu
                    }
                    List(filteredCoins) { coin in
                        NavigationLink(value: coin) {
                            CoinRowView(coin)
                        }
                        .listRowSeparatorTint(Color.primary.opacity(0.08))
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: CoinModel.self) { coin in
                CoinDetailView(coin: coin)
            }
        }
    }

    private var sortMenu: some View {
        Picker(selection: $sortOption) {
            ForEach(CoinSortOption.allCases) { option in
                Text(option.label).tag(option)
            }
        } label: {
            Text("Sort")
        }
        .pickerStyle(.menu)
        .padding(.trailing, 14)
    }
}

#Preview {
    HomeView()
        .environment(CoinManager(coinService: MockCoinService()))
        .environment(WatchlistManager(watchlistService: MockWatchlistService()))
        .environment(AuthManager(authService: MockAuthService()))
        .environment(NetworkMonitor())
}
