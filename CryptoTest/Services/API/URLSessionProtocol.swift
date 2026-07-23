//
//  URLSessionProtocol.swift
//  CryptoTest
//
//  Created by Kiko on 22/07/2026.
//

import Foundation

protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}
