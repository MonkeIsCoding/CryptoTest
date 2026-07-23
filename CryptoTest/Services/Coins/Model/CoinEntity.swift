//
//  CoinEntity.swift
//  CryptoTest
//
//  Created by Kiko on 22/07/2026.
//

import Foundation
import SwiftData

@Model
class CoinEntity {
    @Attribute(.unique) var id: String
    var symbol: String
    var name: String
    var image: URL?
    var currentPrice: Double?
    var marketCap: Double?
    var marketCapRank: Int?
    var priceChange24h: Double?
    var priceChangePercentage24h: Double?
    var lastUpdated: String?

    init(from model: CoinModel) {
        id = model.id
        symbol = model.symbol
        name = model.name
        image = model.image
        currentPrice = model.currentPrice
        marketCap = model.marketCap
        marketCapRank = model.marketCapRank
        priceChange24h = model.priceChange24h
        priceChangePercentage24h = model.priceChangePercentage24h
        lastUpdated = model.lastUpdated
    }

    func update(from model: CoinModel) {
        symbol = model.symbol
        name = model.name
        image = model.image
        currentPrice = model.currentPrice
        marketCap = model.marketCap
        marketCapRank = model.marketCapRank
        priceChange24h = model.priceChange24h
        priceChangePercentage24h = model.priceChangePercentage24h
        lastUpdated = model.lastUpdated
    }

    func toModel() -> CoinModel {
        CoinModel(
            id: id,
            symbol: symbol,
            name: name,
            image: image,
            currentPrice: currentPrice,
            marketCap: marketCap,
            marketCapRank: marketCapRank,
            priceChange24h: priceChange24h,
            priceChangePercentage24h: priceChangePercentage24h,
            lastUpdated: lastUpdated
        )
    }
}
