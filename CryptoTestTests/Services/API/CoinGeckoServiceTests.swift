//
//  CoinGeckoServiceTests.swift
//  CryptoTestTests
//
//  Created by Kiko on 22/07/2026.
//

import Testing
import Foundation
@testable import CryptoTest

private struct MarketChartFixture: Encodable {
    let prices: [[Double]]
}

@Suite(.tags(.networking))
struct CoinGeckoServiceTests {

    @Test func fetchCoins_decodesResponse() async throws {
        let session = URLSessionStub.json(CoinModel.mocks)
        let service = CoinGeckoService(client: APIClient(session: session))

        let coins = try await service.fetchCoins()
        #expect(coins.map(\.id) == CoinModel.mocks.map(\.id))
    }

    @Test func fetchCoins_buildsExpectedQueryItems() async throws {
        let session = URLSessionStub { request in
            let url = try #require(request.url)
            let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
            #expect(items.contains(URLQueryItem(name: "vs_currency", value: "eur")))
            #expect(items.contains(URLQueryItem(name: "order", value: "market_cap_desc")))
            #expect(items.contains(URLQueryItem(name: "per_page", value: "50")))
            #expect(items.contains(URLQueryItem(name: "page", value: "2")))
            let data = try JSONEncoder().encode(CoinModel.mocks)
            return (data, HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!)
        }
        let service = CoinGeckoService(client: APIClient(session: session))

        _ = try await service.fetchCoins(page: 2, perPage: 50)
    }

    @Test func fetchMarketChart_buildsExpectedPathAndQueryItems() async throws {
        let session = URLSessionStub { request in
            let url = try #require(request.url)
            #expect(url.path.hasSuffix("/coins/bitcoin/market_chart"))
            let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
            #expect(items.contains(URLQueryItem(name: "vs_currency", value: "eur")))
            #expect(items.contains(URLQueryItem(name: "days", value: "14")))
            let data = try JSONEncoder().encode(MarketChartFixture(prices: []))
            return (data, HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!)
        }
        let service = CoinGeckoService(client: APIClient(session: session))

        _ = try await service.fetchMarketChart(coinId: "bitcoin", days: 14)
    }

    @Test func fetchMarketChart_parsesPricesIntoPoints() async throws {
        let fixture = MarketChartFixture(prices: [
            [1_700_000_000_000, 64_500.5],
            [1_700_003_600_000, 64_600.25]
        ])
        let session = URLSessionStub.json(fixture)
        let service = CoinGeckoService(client: APIClient(session: session))

        let points = try await service.fetchMarketChart(coinId: "bitcoin")
        #expect(points.count == 2)
        #expect(points[0].price == 64_500.5)
        #expect(points[0].timestamp == Date(timeIntervalSince1970: 1_700_000_000_000 / 1000))
        #expect(points[1].price == 64_600.25)
    }

    @Test func fetchMarketChart_skipsMalformedPoints() async throws {
        let fixture = MarketChartFixture(prices: [
            [1_700_000_000_000, 64_500.5],
            [1_700_003_600_000],
            [1, 2, 3]
        ])
        let session = URLSessionStub.json(fixture)
        let service = CoinGeckoService(client: APIClient(session: session))

        let points = try await service.fetchMarketChart(coinId: "bitcoin")
        #expect(points.count == 1)
    }
}
