//
//  CoinLocalPersistence.swift
//  CryptoTest
//
//  Created by Kiko on 22/07/2026.
//

@MainActor
protocol CoinLocalPersistence {
    func getCoins() throws -> [CoinModel]
    func syncCoins(_ coins: [CoinModel]) throws
}
