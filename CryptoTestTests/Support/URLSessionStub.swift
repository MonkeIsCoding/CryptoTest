//
//  URLSessionStub.swift
//  CryptoTestTests
//
//  Created by Kiko on 22/07/2026.
//

import Foundation
@testable import CryptoTest

/// Stub with no mutable state. The handler closure gets the request directly.
struct URLSessionStub: URLSessionProtocol, Sendable {
    let handler: @Sendable (URLRequest) throws -> (Data, URLResponse)

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try handler(request)
    }
}

extension URLSessionStub {
    static func json(
        _ value: some Encodable,
        statusCode: Int = 200,
        url: URL = URL(string: "https://api.coingecko.com/api/v3")!
    ) -> URLSessionStub {
        URLSessionStub { request in
            let data = try JSONEncoder().encode(value)
            let response = HTTPURLResponse(
                url: request.url ?? url,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )!
            return (data, response)
        }
    }

    static func status(
        _ statusCode: Int,
        url: URL = URL(string: "https://api.coingecko.com/api/v3")!
    ) -> URLSessionStub {
        URLSessionStub { request in
            let response = HTTPURLResponse(
                url: request.url ?? url,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )!
            return (Data(), response)
        }
    }
}
