//
//  APIClient.swift
//  CryptoTest
//
//  Created by Kiko on 21/07/2026.
//

import Foundation

struct APIClient {
    private let baseURL: URL
    private let session: any URLSessionProtocol
    private let decoder: JSONDecoder
    private let apiKey: String?

    init(
        baseURL: URL = URL(string: "https://api.coingecko.com/api/v3")!,
        session: any URLSessionProtocol = URLSession.shared,
        apiKey: String? = nil
    ) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = JSONDecoder()
        self.apiKey = apiKey
    }

    func get<Response: Decodable>(_ path: String, query: [URLQueryItem] = []) async throws -> Response {
        let request = try makeRequest(path: path, query: query)
        let (data, response) = try await session.data(for: request)
        try validate(response)
        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }

    private func makeRequest(path: String, query: [URLQueryItem]) throws -> URLRequest {
        guard var components = URLComponents(
            url: baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        ) else {
            throw APIError.invalidResponse
        }
        if !query.isEmpty {
            components.queryItems = query
        }
        guard let url = components.url else {
            throw APIError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.cachePolicy = .reloadIgnoringLocalCacheData
        if let apiKey {
            request.setValue(apiKey, forHTTPHeaderField: "x-cg-demo-api-key")
        }
        return request
    }

    private func validate(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 429 {
                throw APIError.rateLimited
            }
            throw APIError.server(statusCode: httpResponse.statusCode)
        }
    }
}

enum APIError: Error, LocalizedError {
    case invalidResponse
    case rateLimited
    case server(statusCode: Int)
    case decoding(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Received an invalid response from the server."
        case .rateLimited:
            return "Too many requests to CoinGecko — please wait a moment and try again."
        case .server(let statusCode):
            return "Server returned status code \(statusCode)."
        case .decoding(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}
