//
//  CoinManagerTests.swift
//  CryptoTestTests
//
//  Created by Kiko on 22/07/2026.
//

import Testing
import Foundation
@testable import CryptoTest

private struct MarketChartFixture: Encodable {
    let prices: [[Double]]
}

@MainActor
struct CoinManagerTests {

    @Test func fetchCoins_onSuccess_updatesCoinsAndSyncsLocal() async throws {
        let context = TestModelContainer.makeContext()
        let manager = CoinManager(
            coinService: MockCoinService(),
            local: SwiftDataCoinLocalPersistence(context: context)
        )

        try await manager.fetchCoins()

        #expect(manager.coins.map(\.id) == CoinModel.mocks.map(\.id))

        let mirrored = try SwiftDataCoinLocalPersistence(context: context).getCoins()
        #expect(mirrored.count == CoinModel.mocks.count)
    }

    @Test func fetchCoins_onFailure_fallsBackToCachedCoinsAndRethrows() async throws {
        let manager = CoinManager(
            coinService: MockCoinService(shouldFail: true),
            local: MockCoinLocalPersistence(coins: [CoinModel.mock])
        )

        do {
            try await manager.fetchCoins()
            Issue.record("Expected fetchCoins to rethrow the underlying error.")
        } catch is URLError {
            // success
        } catch {
            Issue.record("Wrong error thrown: \(error)")
        }

        #expect(manager.coins == [CoinModel.mock])
    }

    @Test func fetchCoins_whenRemoteReturnsEmpty_keepsCachedCoinsAndDoesNotWipeLocalStore() async throws {
        let context = TestModelContainer.makeContext()
        let store = SwiftDataCoinLocalPersistence(context: context)
        try store.syncCoins(CoinModel.mocks)

        let manager = CoinManager(
            coinService: MockCoinService(coins: []),
            local: store
        )

        try await manager.fetchCoins()

        #expect(
            manager.coins.count == CoinModel.mocks.count,
            "An empty remote result should leave the cached coins on screen, not blank the list."
        )
        #expect(
            try store.getCoins().count == CoinModel.mocks.count,
            "An empty remote result must not delete the persisted coins."
        )
    }

    @Test(.tags(.networking)) func fetchPriceHistory_cachesResultWithinTTL() async throws {
        let counter = CallCounter()
        let session = URLSessionStub { request in
            counter.increment()
            let url = try #require(request.url)
            let data = try JSONEncoder().encode(MarketChartFixture(prices: [[1_700_000_000_000, 100]]))
            return (data, HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!)
        }
        let manager = CoinManager(
            coinService: MockCoinService(),
            coinGeckoService: CoinGeckoService(client: APIClient(session: session))
        )

        let first = try await manager.fetchPriceHistory(coinId: "bitcoin", days: 7)
        let second = try await manager.fetchPriceHistory(coinId: "bitcoin", days: 7)

        #expect(first.count == second.count)
        #expect(counter.count == 1, "Second call within the TTL should be served from cache, not the network.")
    }

    @Test(.tags(.networking)) func fetchPriceHistory_usesSeparateCacheKeyPerDays() async throws {
        let counter = CallCounter()
        let session = URLSessionStub { request in
            counter.increment()
            let url = try #require(request.url)
            let data = try JSONEncoder().encode(MarketChartFixture(prices: [[1_700_000_000_000, 100]]))
            return (data, HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!)
        }
        let manager = CoinManager(
            coinService: MockCoinService(),
            coinGeckoService: CoinGeckoService(client: APIClient(session: session))
        )

        _ = try await manager.fetchPriceHistory(coinId: "bitcoin", days: 7)
        _ = try await manager.fetchPriceHistory(coinId: "bitcoin", days: 14)

        #expect(counter.count == 2, "Different `days` values should be cached separately, not share a cache entry.")
    }

    @Test(.tags(.networking)) func seedCoins_onFirstCall_alwaysSeedsFromCoinGecko() async throws {
        let session = URLSessionStub.json(CoinModel.mocks)
        let coinService = MockCoinService(coins: [CoinModel.mock])
        let context = TestModelContainer.makeContext()
        let manager = CoinManager(
            coinService: coinService,
            coinGeckoService: CoinGeckoService(client: APIClient(session: session)),
            local: SwiftDataCoinLocalPersistence(context: context)
        )

        try await manager.seedCoins()

        #expect(manager.coins.count == CoinModel.mocks.count)
        #expect(coinService.updatedCoins?.count == CoinModel.mocks.count)

        let mirrored = try SwiftDataCoinLocalPersistence(context: context).getCoins()
        #expect(mirrored.count == CoinModel.mocks.count)
    }

    @Test(.tags(.networking)) func seedCoins_onImmediateSecondCall_fallsBackToFetchCoins() async throws {
        let session = URLSessionStub.json(CoinModel.mocks)
        let coinService = MockCoinService(coins: [CoinModel.mock])
        let manager = CoinManager(
            coinService: coinService,
            coinGeckoService: CoinGeckoService(client: APIClient(session: session)),
            local: MockCoinLocalPersistence()
        )

        try await manager.seedCoins()
        #expect(manager.coins.count == CoinModel.mocks.count)

        try await manager.seedCoins()
        #expect(manager.coins.count == 1, "Seeding again within the TTL should defer to fetchCoins() instead of re-seeding from CoinGecko.")
    }
}
