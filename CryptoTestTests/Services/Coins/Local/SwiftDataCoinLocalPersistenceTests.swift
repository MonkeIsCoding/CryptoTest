//
//  SwiftDataCoinLocalPersistenceTests.swift
//  CryptoTestTests
//
//  Created by Kiko on 22/07/2026.
//

import Testing
import SwiftData
@testable import CryptoTest

extension SwiftDataPersistenceTests {

    @MainActor
    struct CoinLocalPersistenceTests {

        let store: SwiftDataCoinLocalPersistence

        init() {
            store = SwiftDataCoinLocalPersistence(context: TestModelContainer.makeContext())
        }

        @Test func getCoins_whenEmpty_returnsEmpty() throws {
            #expect(try store.getCoins().isEmpty)
        }

        @Test func syncCoins_insertsNewCoins() throws {
            try store.syncCoins(CoinModel.mocks)
            let saved = try store.getCoins()
            #expect(saved.count == CoinModel.mocks.count)
            #expect(Set(saved.map(\.id)) == Set(CoinModel.mocks.map(\.id)))
        }

        @Test func syncCoins_updatesExistingCoin() throws {
            try store.syncCoins([CoinModel.mock])

            let updatedPrice = CoinModel(
                id: CoinModel.mock.id,
                symbol: CoinModel.mock.symbol,
                name: CoinModel.mock.name,
                image: CoinModel.mock.image,
                currentPrice: 99_999,
                marketCap: CoinModel.mock.marketCap,
                marketCapRank: CoinModel.mock.marketCapRank,
                priceChange24h: CoinModel.mock.priceChange24h,
                priceChangePercentage24h: CoinModel.mock.priceChangePercentage24h,
                lastUpdated: CoinModel.mock.lastUpdated
            )
            try store.syncCoins([updatedPrice])

            let saved = try store.getCoins()
            let coin = try #require(saved.first)
            #expect(saved.count == 1)
            #expect(coin.currentPrice == 99_999)
        }

        @Test func syncCoins_removesStaleCoins() throws {
            try store.syncCoins(CoinModel.mocks)
            try store.syncCoins([CoinModel.mock])

            let saved = try store.getCoins()
            let coin = try #require(saved.first)
            #expect(saved.count == 1)
            #expect(coin.id == CoinModel.mock.id)
        }

        @Test func syncCoins_withEmptyList_preservesCachedCoins() throws {
            try store.syncCoins(CoinModel.mocks)

            try store.syncCoins([])

            let saved = try store.getCoins()
            #expect(
                saved.count == CoinModel.mocks.count,
                "An empty sync must not wipe the offline cache — it means the fetch returned nothing useful, not that there are zero coins."
            )
        }

        @Test func getCoins_sortedByMarketCapRank() throws {
            try store.syncCoins(CoinModel.mocks.shuffled())

            let ranks = try store.getCoins().compactMap(\.marketCapRank)
            #expect(ranks == ranks.sorted(), "Coins should be returned in ascending market cap rank order")
        }
    }
}
