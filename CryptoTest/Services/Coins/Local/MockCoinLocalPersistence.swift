//
//  MockCoinLocalPersistence.swift
//  CryptoTest
//
//  Created by Kiko on 22/07/2026.
//

@MainActor
struct MockCoinLocalPersistence: CoinLocalPersistence {

    let coins: [CoinModel]

    init(coins: [CoinModel] = []) {
        self.coins = coins
    }

    func getCoins() throws -> [CoinModel] {
        coins
    }

    func syncCoins(_ coins: [CoinModel]) throws {}
}
