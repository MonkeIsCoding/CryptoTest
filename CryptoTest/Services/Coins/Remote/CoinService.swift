//
//  CoinService.swift
//  CryptoTest
//
//  Created by Kiko on 21/07/2026.
//

protocol CoinService {
    func fetchCoins() async throws -> [CoinModel]
    func updateCoins(_ coins: [CoinModel]) throws
}
