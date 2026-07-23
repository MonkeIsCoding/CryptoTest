//
//  WatchlistEntity.swift
//  CryptoTest
//
//  Created by Kiko on 22/07/2026.
//

import SwiftData

@Model
class WatchlistEntity {
    @Attribute(.unique) var coinId: String

    init(coinId: String) {
        self.coinId = coinId
    }
}
