//
//  AlertEntity.swift
//  CryptoTest
//
//  Created by Kiko on 22/07/2026.
//

import Foundation
import SwiftData

@Model
class AlertEntity {
    @Attribute(.unique) var id: String
    var userId: String
    var coinId: String
    var targetPrice: Double
    var type: AlertType
    var addedAt: Date
    var triggered: Bool = false

    init(from model: AlertModel) {
        id = model.id
        userId = model.userId
        coinId = model.coinId
        targetPrice = model.targetPrice
        type = model.type
        addedAt = model.addedAt
        triggered = model.triggered
    }

    func toModel() -> AlertModel {
        AlertModel(
            id: id,
            userId: userId,
            coinId: coinId,
            targetPrice: targetPrice,
            type: type,
            addedAt: addedAt,
            triggered: triggered
        )
    }
}
