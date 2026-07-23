//
//  MockWatchlistService.swift
//  CryptoTest
//
//  Created by Kiko on 21/07/2026.
//

import Foundation

class MockWatchlistService: WatchlistService {

    private let coinIds: [String]
    private let shouldFail: Bool

    private(set) var addedCoinIds: [String] = []
    private(set) var removedCoinIds: [String] = []
    private(set) var didDeleteAllForCurrentUser = false

    init(coinIds: [String] = ["btc", "eth"], shouldFail: Bool = false) {
        self.coinIds = coinIds
        self.shouldFail = shouldFail
    }

    func fetchWatchlistCoins() async throws -> [String]  {
        if shouldFail { throw URLError(.notConnectedToInternet) }
        return coinIds
    }

    func addToWatchlist(coinId: String) async throws {
        if shouldFail { throw URLError(.notConnectedToInternet) }
        addedCoinIds.append(coinId)
    }

    func removeFromWatchlist(coinId: String) async throws {
        if shouldFail { throw URLError(.notConnectedToInternet) }
        removedCoinIds.append(coinId)
    }

    func deleteAllForCurrentUser() async throws {
        if shouldFail { throw URLError(.notConnectedToInternet) }
        didDeleteAllForCurrentUser = true
    }
}
