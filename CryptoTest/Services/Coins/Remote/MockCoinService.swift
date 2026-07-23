//
//  MockCoinService.swift
//  CryptoTest
//
//  Created by Kiko on 21/07/2026.
//

import Foundation

final class MockCoinService: CoinService {

    private let coins: [CoinModel]
    private let delay: Duration?
    private let shouldFail: Bool

    private(set) var updatedCoins: [CoinModel]?

    init(coins: [CoinModel] = CoinModel.mocks, delay: Duration? = nil, shouldFail: Bool = false) {
        self.coins = coins
        self.delay = delay
        self.shouldFail = shouldFail
    }

    func fetchCoins() async throws -> [CoinModel] {
        if let delay {
            try await Task.sleep(for: delay)
        }
        if shouldFail {
            throw URLError(.notConnectedToInternet)
        }
        return coins
    }

    func updateCoins(_ coins: [CoinModel]) throws {
        updatedCoins = coins
    }
}
