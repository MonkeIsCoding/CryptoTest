//
//  CoinGeckoCoinService.swift
//  CryptoTest
//
//  Created by Kiko on 22/07/2026.
//

import Foundation

struct CoinGeckoService {

    private let client: APIClient

    init(client: APIClient = APIClient()) {
        self.client = client
    }

    func fetchCoins(page: Int = 1, perPage: Int = 100) async throws -> [CoinModel] {
        try await client.get("/coins/markets", query: [
            URLQueryItem(name: "vs_currency", value: "eur"),
            URLQueryItem(name: "order", value: "market_cap_desc"),
            URLQueryItem(name: "per_page", value: String(perPage)),
            URLQueryItem(name: "page", value: String(page))
        ])
    }

    func fetchMarketChart(coinId: String, days: Int = 7) async throws -> [PriceHistoryPoint] {
        let chart: MarketChartResponse = try await client.get("/coins/\(coinId)/market_chart", query: [
            URLQueryItem(name: "vs_currency", value: "eur"),
            URLQueryItem(name: "days", value: String(days))
        ])
        return chart.prices.compactMap { point in
            guard point.count == 2 else { return nil }
            return PriceHistoryPoint(
                timestamp: Date(timeIntervalSince1970: point[0] / 1000),
                price: point[1]
            )
        }
    }

    private struct MarketChartResponse: Decodable {
        let prices: [[Double]]
    }
}
