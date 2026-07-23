//
//  WatchlistLocalPersistence.swift
//  CryptoTest
//
//  Created by Kiko on 22/07/2026.
//


@MainActor
protocol WatchlistLocalPersistence {
    func getWatchlistCoinIds() throws -> [String]
    func addToWatchlist(coinId: String) throws
    func removeFromWatchlist(coinId: String) throws
    func syncWatchlist(coinIds: [String]) throws
}
