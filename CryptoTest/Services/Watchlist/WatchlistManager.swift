//
//  WatchlistManager.swift
//  CryptoTest
//
//  Created by Kiko on 18/07/2026.
//

import Foundation

@MainActor
@Observable
class WatchlistManager {

    private let watchlistService: WatchlistService
    private let local: WatchlistLocalPersistence

    private(set) var watchlistCoinIds: Set<String> = []

    init(watchlistService: WatchlistService, local: WatchlistLocalPersistence = MockWatchlistLocalPersistence()) {
        self.watchlistService = watchlistService
        self.local = local
    }

    func fetchWatchlist() async throws {
        do {
            let fetched = try await watchlistService.fetchWatchlistCoins()
            watchlistCoinIds = Set(fetched)
            try local.syncWatchlist(coinIds: fetched)
        } catch {
            watchlistCoinIds = Set(try local.getWatchlistCoinIds())
            throw error
        }
    }

    func isWatched(coinId: String) -> Bool {
        watchlistCoinIds.contains(coinId)
    }

    func toggleWatchlist(coinId: String) async throws {
        if watchlistCoinIds.contains(coinId) {
            watchlistCoinIds.remove(coinId)
            try local.removeFromWatchlist(coinId: coinId)
            try await watchlistService.removeFromWatchlist(coinId: coinId)
        } else {
            watchlistCoinIds.insert(coinId)
            try local.addToWatchlist(coinId: coinId)
            try await watchlistService.addToWatchlist(coinId: coinId)
        }
    }

    func deleteAllData() async throws {
        try await watchlistService.deleteAllForCurrentUser()
        try local.syncWatchlist(coinIds: [])
        watchlistCoinIds = []
    }
}
