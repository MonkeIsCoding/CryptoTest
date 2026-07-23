//
//  SwiftDataWatchlistLocalPersistenceTests.swift
//  CryptoTestTests
//
//  Created by Kiko on 22/07/2026.
//

import Testing
import SwiftData
@testable import CryptoTest

extension SwiftDataPersistenceTests {

    @MainActor
    struct WatchlistLocalPersistenceTests {

        let store: SwiftDataWatchlistLocalPersistence

        init() {
            store = SwiftDataWatchlistLocalPersistence(context: TestModelContainer.makeContext())
        }

        @Test func getWatchlistCoinIds_whenEmpty_returnsEmpty() throws {
            #expect(try store.getWatchlistCoinIds().isEmpty)
        }

        @Test func addToWatchlist_addsCoin() throws {
            try store.addToWatchlist(coinId: "bitcoin")
            #expect(try store.getWatchlistCoinIds() == ["bitcoin"])
        }

        @Test func addToWatchlist_isIdempotent() throws {
            try store.addToWatchlist(coinId: "bitcoin")
            try store.addToWatchlist(coinId: "bitcoin")
            #expect(try store.getWatchlistCoinIds().count == 1)
        }

        @Test func removeFromWatchlist_removesCoin() throws {
            try store.addToWatchlist(coinId: "bitcoin")
            try store.removeFromWatchlist(coinId: "bitcoin")
            #expect(try store.getWatchlistCoinIds().isEmpty)
        }

        @Test func removeFromWatchlist_withUnknownCoin_doesNothing() throws {
            try store.removeFromWatchlist(coinId: "missing")
            #expect(try store.getWatchlistCoinIds().isEmpty)
        }

        @Test func syncWatchlist_addsMissingAndRemovesStale() throws {
            try store.addToWatchlist(coinId: "bitcoin")
            try store.syncWatchlist(coinIds: ["ethereum", "ripple"])

            let saved = Set(try store.getWatchlistCoinIds())
            #expect(saved == ["ethereum", "ripple"])
        }
    }
}
