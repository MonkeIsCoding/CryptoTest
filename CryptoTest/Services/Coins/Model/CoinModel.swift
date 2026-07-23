//
//  CoinModel.swift
//  CryptoTest
//
//  Created by Kiko on 18/07/2026.
//

import Foundation

struct CoinModel: Codable, Identifiable, Hashable {
    let id: String
    let symbol: String
    let name: String
    let image: URL?
    let currentPrice: Double?
    let marketCap: Double?
    let marketCapRank: Int?
    let priceChange24h: Double?
    let priceChangePercentage24h: Double?
    let lastUpdated: String?

    enum CodingKeys: String, CodingKey {
        case id
        case symbol
        case name
        case image
        case currentPrice = "current_price"
        case marketCap = "market_cap"
        case marketCapRank = "market_cap_rank"
        case priceChange24h = "price_change_24h"
        case priceChangePercentage24h = "price_change_percentage_24h"
        case lastUpdated = "last_updated"
    }
}

struct PriceHistoryPoint: Equatable, Hashable {
    let timestamp: Date
    let price: Double
}

extension CoinModel {
    static let mocks: [CoinModel] = [
        CoinModel(
            id: "bitcoin",
            symbol: "btc",
            name: "Bitcoin",
            image: URL(string: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png"),
            currentPrice: 64_506.29,
            marketCap: 1_293_873_352_416,
            marketCapRank: 1,
            priceChange24h: 7.3,
            priceChangePercentage24h: 0.99,
            lastUpdated: "2026-07-18T12:00:00.000Z"
        ),
        CoinModel(
            id: "ethereum",
            symbol: "eth",
            name: "Ethereum",
            image: URL(string: "https://assets.coingecko.com/coins/images/279/large/ethereum.png"),
            currentPrice: 1_859.50,
            marketCap: 224_407_784_531,
            marketCapRank: 2,
            priceChange24h: 7.3,
            priceChangePercentage24h: 1.30,
            lastUpdated: "2026-07-18T12:00:00.000Z"
        ),
        CoinModel(
            id: "tether",
            symbol: "usdt",
            name: "Tether",
            image: URL(string: "https://assets.coingecko.com/coins/images/325/large/Tether.png"),
            currentPrice: 0.9993,
            marketCap: 184_095_716_151,
            marketCapRank: 3,
            priceChange24h: 7.3,
            priceChangePercentage24h: 0.01,
            lastUpdated: "2026-07-18T12:00:00.000Z"
        ),
        CoinModel(
            id: "binancecoin",
            symbol: "bnb",
            name: "BNB",
            image: URL(string: "https://assets.coingecko.com/coins/images/825/large/bnb-icon2_2x.png"),
            currentPrice: 571.27,
            marketCap: 76_073_013_248,
            marketCapRank: 4,
            priceChange24h: 7.3,
            priceChangePercentage24h: 0.99,
            lastUpdated: "2026-07-18T12:00:00.000Z"
        ),
        CoinModel(
            id: "ripple",
            symbol: "xrp",
            name: "XRP",
            image: URL(string: "https://assets.coingecko.com/coins/images/44/large/xrp-symbol-white-128.png"),
            currentPrice: 1.09,
            marketCap: 68_267_622_688,
            marketCapRank: 5,
            priceChange24h: 7.3,
            priceChangePercentage24h: 0.30,
            lastUpdated: "2026-07-18T12:00:00.000Z"
        )
    ]

    static let mock = mocks[0]

    var formattedMarketCap: String {
        guard let marketCap else { return "—" }
        return marketCap.formatted(.currency(code: "EUR").notation(.compactName))
    }

    var formattedLastUpdated: String {
        guard let lastUpdated, let date = try? Date(lastUpdated, strategy: .iso8601) else { return "—" }
        return date.formatted(date: .abbreviated, time: .shortened)
    }
}
