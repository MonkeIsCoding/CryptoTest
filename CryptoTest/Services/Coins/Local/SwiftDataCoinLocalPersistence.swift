//
//  SwiftDataCoinLocalPersistence.swift
//  CryptoTest
//
//  Created by Kiko on 22/07/2026.
//

import Foundation
import SwiftData


@MainActor
struct SwiftDataCoinLocalPersistence: CoinLocalPersistence {
    
    private let mainContext: ModelContext
    
    init(context: ModelContext) {
        self.mainContext = context
    }
    
    func getCoins() throws -> [CoinModel] {
        let descriptor = FetchDescriptor<CoinEntity>(sortBy: [SortDescriptor(\.marketCapRank)])
        return try mainContext.fetch(descriptor).map { $0.toModel() }
    }
    
    func syncCoins(_ coins: [CoinModel]) throws {
        guard !coins.isEmpty else { return }

        let existing = try mainContext.fetch(FetchDescriptor<CoinEntity>())
        var existingByID = Dictionary(
            uniqueKeysWithValues: existing.map { ($0.id, $0) }
        )
        
        for coin in coins {
            if let entity = existingByID.removeValue(forKey: coin.id) {
                entity.update(from: coin)
            } else {
                mainContext.insert(CoinEntity(from: coin))
            }
        }
        
        existingByID.values.forEach(mainContext.delete)
        
        if mainContext.hasChanges {
            try mainContext.save()
        }
    }
}
