//
//  WatchListModel.swift
//  CryptoTest
//
//  Created by Kiko on 18/07/2026.
//

struct WatchListModel: Codable {
    let userId: String
    let coinId: String

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case coinId = "coin_id"
    }
}
