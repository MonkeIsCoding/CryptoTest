//
//  WatchlistManagerTests.swift
//  CryptoTestTests
//
//  Created by Kiko on 22/07/2026.
//

import Testing
import Foundation
@testable import CryptoTest

@MainActor
struct WatchlistManagerTests {

    @Test func fetchWatchlist_onSuccess_updatesIdsAndSyncsLocal() async throws {
        let context = TestModelContainer.makeContext()
        let manager = WatchlistManager(
            watchlistService: MockWatchlistService(coinIds: ["btc", "eth"]),
            local: SwiftDataWatchlistLocalPersistence(context: context)
        )

        try await manager.fetchWatchlist()

        #expect(manager.watchlistCoinIds == ["btc", "eth"])

        let mirrored = Set(try SwiftDataWatchlistLocalPersistence(context: context).getWatchlistCoinIds())
        #expect(mirrored == ["btc", "eth"])
    }

    @Test func fetchWatchlist_onFailure_fallsBackToCachedIdsAndRethrows() async throws {
        let manager = WatchlistManager(
            watchlistService: MockWatchlistService(shouldFail: true),
            local: MockWatchlistLocalPersistence(coinIds: ["cached"])
        )

        do {
            try await manager.fetchWatchlist()
            Issue.record("Expected fetchWatchlist to rethrow the underlying error.")
        } catch is URLError {
            // success
        } catch {
            Issue.record("Wrong error thrown: \(error)")
        }

        #expect(manager.watchlistCoinIds == ["cached"])
    }

    @Test func isWatched_reflectsCurrentSet() async throws {
        let manager = WatchlistManager(
            watchlistService: MockWatchlistService(coinIds: ["btc"]),
            local: MockWatchlistLocalPersistence()
        )

        try await manager.fetchWatchlist()

        #expect(manager.isWatched(coinId: "btc") == true)
        #expect(manager.isWatched(coinId: "xrp") == false)
    }

    @Test func toggleWatchlist_addsWhenNotWatched() async throws {
        let context = TestModelContainer.makeContext()
        let watchlistService = MockWatchlistService()
        let manager = WatchlistManager(
            watchlistService: watchlistService,
            local: SwiftDataWatchlistLocalPersistence(context: context)
        )

        try await manager.toggleWatchlist(coinId: "btc")

        #expect(manager.isWatched(coinId: "btc") == true)
        #expect(watchlistService.addedCoinIds == ["btc"])

        let mirrored = try SwiftDataWatchlistLocalPersistence(context: context).getWatchlistCoinIds()
        #expect(mirrored == ["btc"])
    }

    @Test func toggleWatchlist_removesWhenWatched() async throws {
        let context = TestModelContainer.makeContext()
        let watchlistService = MockWatchlistService(coinIds: ["btc"])
        let manager = WatchlistManager(
            watchlistService: watchlistService,
            local: SwiftDataWatchlistLocalPersistence(context: context)
        )
        try await manager.fetchWatchlist()

        try await manager.toggleWatchlist(coinId: "btc")

        #expect(manager.isWatched(coinId: "btc") == false)
        #expect(watchlistService.removedCoinIds == ["btc"])

        let mirrored = try SwiftDataWatchlistLocalPersistence(context: context).getWatchlistCoinIds()
        #expect(mirrored.isEmpty)
    }

    @Test func deleteAllData_clearsRemoteLocalAndInMemoryState() async throws {
        let context = TestModelContainer.makeContext()
        let watchlistService = MockWatchlistService(coinIds: ["btc", "eth"])
        let manager = WatchlistManager(
            watchlistService: watchlistService,
            local: SwiftDataWatchlistLocalPersistence(context: context)
        )
        try await manager.fetchWatchlist()

        try await manager.deleteAllData()

        #expect(watchlistService.didDeleteAllForCurrentUser == true)
        #expect(manager.watchlistCoinIds.isEmpty)

        let mirrored = try SwiftDataWatchlistLocalPersistence(context: context).getWatchlistCoinIds()
        #expect(mirrored.isEmpty)
    }

    @Test func deleteAllData_onRemoteFailure_rethrows() async throws {
        let watchlistService = MockWatchlistService(coinIds: ["btc"], shouldFail: true)
        let manager = WatchlistManager(
            watchlistService: watchlistService,
            local: MockWatchlistLocalPersistence(coinIds: ["btc"])
        )

        do {
            try await manager.deleteAllData()
            Issue.record("Expected deleteAllData to rethrow the underlying error.")
        } catch is URLError {
            // success
        } catch {
            Issue.record("Wrong error thrown: \(error)")
        }
    }
}
