//
//  AlertModel.swift
//  CryptoTest
//
//  Created by Kiko on 18/07/2026.
//

enum AlertType: String, Codable {
    case above
    case below
}

import Foundation

struct AlertModel: Codable, Identifiable {
    let id: String
    let userId: String
    let coinId: String
    let targetPrice: Double
    let type: AlertType
    let addedAt: Date
    var triggered: Bool

    init(
        id: String,
        userId: String,
        coinId: String,
        targetPrice: Double,
        type: AlertType,
        addedAt: Date = .now,
        triggered: Bool = false
    ) {
        self.id = id
        self.userId = userId
        self.coinId = coinId
        self.targetPrice = targetPrice
        self.type = type
        self.addedAt = addedAt
        self.triggered = triggered
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case coinId = "coin_id"
        case targetPrice = "target_price"
        case type
        case addedAt = "added_at"
        case triggered
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        coinId = try container.decode(String.self, forKey: .coinId)
        targetPrice = try container.decode(Double.self, forKey: .targetPrice)
        type = try container.decode(AlertType.self, forKey: .type)
        addedAt = try container.decode(Date.self, forKey: .addedAt)
        triggered = try container.decodeIfPresent(Bool.self, forKey: .triggered) ?? false
    }
}
