//
//  WatchlistService.swift
//  CryptoTest
//
//  Created by Kiko on 21/07/2026.
//

protocol WatchlistService {
    func fetchWatchlistCoins() async throws -> [String]
    func addToWatchlist(coinId: String) async throws
    func removeFromWatchlist(coinId: String) async throws
    func deleteAllForCurrentUser() async throws
}
