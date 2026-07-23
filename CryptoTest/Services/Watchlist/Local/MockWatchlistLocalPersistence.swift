//
//  MockWatchlistLocalPersistence.swift
//  CryptoTest
//
//  Created by Kiko on 22/07/2026.
//

@MainActor
struct MockWatchlistLocalPersistence: WatchlistLocalPersistence {

    let coinIds: [String]

    init(coinIds: [String] = []) {
        self.coinIds = coinIds
    }

    func getWatchlistCoinIds() throws -> [String] {
        coinIds
    }

    func addToWatchlist(coinId: String) throws {}

    func removeFromWatchlist(coinId: String) throws {}

    func syncWatchlist(coinIds: [String]) throws {}
}
