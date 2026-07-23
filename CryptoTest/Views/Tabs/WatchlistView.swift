//
//  WatchlistView.swift
//  CryptoTest
//
//  Created by Kiko on 18/07/2026.
//

import SwiftUI

struct WatchlistView: View {

    @Environment(CoinManager.self) private var coinManager
    @Environment(WatchlistManager.self) private var listManager

    private var watchlistCoins: [CoinModel] {
        coinManager.coins.filter { listManager.watchlistCoinIds.contains($0.id) }
    }

    var body: some View {
        NavigationStack {
            ScreenStateWrapper(
                title: "Watchlist",
                offlineMessage: "Offline — showing last synced watchlist",
                isEmpty: watchlistCoins.isEmpty,
                emptyTitle: "No Coins in Watchlist",
                emptySystemImage: "star",
                emptyDescription: "Add coins from Home to see them here.",
                load: listManager.fetchWatchlist
            ) {
                List(watchlistCoins) { coin in
                    NavigationLink(value: coin) {
                        CoinRowView(coin)
                    }
                    .listRowSeparatorTint(Color.primary.opacity(0.08))
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: CoinModel.self) { coin in
                CoinDetailView(coin: coin)
            }
        }
    }
}

#Preview {
    WatchlistView()
        .environment(CoinManager(coinService: MockCoinService()))
        .environment(WatchlistManager(watchlistService: MockWatchlistService()))
        .environment(NetworkMonitor())
}
