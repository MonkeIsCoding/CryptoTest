//
//  CoinManager.swift
//  CryptoTest
//
//  Created by Kiko on 18/07/2026.
//

import Foundation

@MainActor
@Observable
class CoinManager {

    private let coinService: CoinService
    private let coinGeckoService: CoinGeckoService
    private let local: CoinLocalPersistence

    private let priceHistoryCacheTTL: TimeInterval = 300
    private let seedCoinsTTL: TimeInterval = 60

    private var priceHistoryCache: [String: (fetchedAt: Date, points: [PriceHistoryPoint])] = [:]
    private var lastSeedAt: Date?

    private(set) var coins: [CoinModel] = []

    init(
        coinService: CoinService,
        coinGeckoService: CoinGeckoService = CoinGeckoService(),
        local: CoinLocalPersistence = MockCoinLocalPersistence()
    ) {
        self.coinService = coinService
        self.coinGeckoService = coinGeckoService
        self.local = local
    }

    func fetchCoins() async throws {
        do {
            let fetched = try await coinService.fetchCoins()
            guard !fetched.isEmpty else {
                coins = try local.getCoins()
                return
            }
            coins = fetched
            try local.syncCoins(fetched)
        } catch {
            coins = try local.getCoins()
            throw error
        }
    }

    func fetchPriceHistory(coinId: String, days: Int = 7) async throws -> [PriceHistoryPoint] {
        let cacheKey = "\(coinId)_\(days)"
        if let cached = priceHistoryCache[cacheKey],
           Date.now.timeIntervalSince(cached.fetchedAt) < priceHistoryCacheTTL {
            return cached.points
        }
        let points = try await coinGeckoService.fetchMarketChart(coinId: coinId, days: days)
        priceHistoryCache[cacheKey] = (.now, points)
        return points
    }

    func seedCoins() async throws {
        guard shouldSeedCoins else {
            try await fetchCoins()
            return
        }
        let updatedCoins = try await coinGeckoService.fetchCoins()
        coins = updatedCoins
        try coinService.updateCoins(updatedCoins)
        try local.syncCoins(updatedCoins)
        lastSeedAt = .now
    }

    private var shouldSeedCoins: Bool {
        guard let lastSeedAt else { return true }
        return Date.now.timeIntervalSince(lastSeedAt) > seedCoinsTTL
    }
}

enum DBError: LocalizedError {
    case dataFetchError

    var errorDescription: String? {
        switch self {
        case .dataFetchError:
            return "DB Error"
        }
    }
}
