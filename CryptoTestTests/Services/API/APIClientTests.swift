//
//  APIClientTests.swift
//  CryptoTestTests
//
//  Created by Kiko on 22/07/2026.
//

import Testing
import Foundation
@testable import CryptoTest

private struct DummyPayload: Codable, Equatable {
    let value: Int
}

@Suite(.tags(.networking))
struct APIClientTests {

    @Test func get_onSuccess_decodesResponse() async throws {
        let session = URLSessionStub.json(DummyPayload(value: 42))
        let client = APIClient(session: session)

        let result: DummyPayload = try await client.get("/ping")
        #expect(result == DummyPayload(value: 42))
    }

    @Test func get_appendsQueryItemsToURL() async throws {
        let session = URLSessionStub { request in
            let url = try #require(request.url)
            let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems
            #expect(items?.contains(URLQueryItem(name: "vs_currency", value: "eur")) == true)
            let data = try JSONEncoder().encode(DummyPayload(value: 1))
            return (data, HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!)
        }
        let client = APIClient(session: session)

        let _: DummyPayload = try await client.get("/ping", query: [URLQueryItem(name: "vs_currency", value: "eur")])
    }

    @Test func get_buildsRequestWithCorrectPath() async throws {
        let session = URLSessionStub { request in
            let url = try #require(request.url)
            #expect(url.path.hasSuffix("/coins/markets"))
            let data = try JSONEncoder().encode(DummyPayload(value: 1))
            return (data, HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!)
        }
        let client = APIClient(session: session)

        let _: DummyPayload = try await client.get("/coins/markets")
    }

    @Test func get_withApiKey_setsHeader() async throws {
        let session = URLSessionStub { request in
            #expect(request.value(forHTTPHeaderField: "x-cg-demo-api-key") == "test-key")
            let url = try #require(request.url)
            let data = try JSONEncoder().encode(DummyPayload(value: 1))
            return (data, HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!)
        }
        let client = APIClient(session: session, apiKey: "test-key")

        let _: DummyPayload = try await client.get("/ping")
    }

    @Test func get_onNon2xxStatus_throwsServerError() async throws {
        let client = APIClient(session: URLSessionStub.status(404))

        do {
            let _: DummyPayload = try await client.get("/ping")
            Issue.record("Expected APIError.server to be thrown.")
        } catch APIError.server(let statusCode) {
            #expect(statusCode == 404)
        } catch {
            Issue.record("Wrong error thrown: \(error)")
        }
    }

    @Test func get_on429_throwsRateLimited() async throws {
        let client = APIClient(session: URLSessionStub.status(429))

        do {
            let _: DummyPayload = try await client.get("/ping")
            Issue.record("Expected APIError.rateLimited to be thrown.")
        } catch APIError.rateLimited {
            // success
        } catch {
            Issue.record("Wrong error thrown: \(error)")
        }
    }

    @Test func get_onMalformedJSON_throwsDecodingError() async throws {
        let session = URLSessionStub { request in
            let url = try #require(request.url)
            let data = Data("not json".utf8)
            return (data, HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!)
        }
        let client = APIClient(session: session)

        do {
            let _: DummyPayload = try await client.get("/ping")
            Issue.record("Expected APIError.decoding to be thrown.")
        } catch APIError.decoding {
            // success
        } catch {
            Issue.record("Wrong error thrown: \(error)")
        }
    }

    @Test func get_onNonHTTPResponse_throwsInvalidResponse() async throws {
        let session = URLSessionStub { request in
            let url = try #require(request.url)
            let data = try JSONEncoder().encode(DummyPayload(value: 1))
            let response = URLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
            return (data, response)
        }
        let client = APIClient(session: session)

        do {
            let _: DummyPayload = try await client.get("/ping")
            Issue.record("Expected APIError.invalidResponse to be thrown.")
        } catch APIError.invalidResponse {
            // success
        } catch {
            Issue.record("Wrong error thrown: \(error)")
        }
    }
}
