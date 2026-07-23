//
//  SwiftDataWatchlistLocalPersistence.swift
//  CryptoTest
//
//  Created by Kiko on 22/07/2026.
//

import Foundation
import SwiftData

@MainActor
struct SwiftDataWatchlistLocalPersistence: WatchlistLocalPersistence {

    private let mainContext: ModelContext

    init(context: ModelContext) {
        self.mainContext = context
    }

    func getWatchlistCoinIds() throws -> [String] {
        try mainContext.fetch(FetchDescriptor<WatchlistEntity>()).map(\.coinId)
    }

    func addToWatchlist(coinId: String) throws {
        let descriptor = FetchDescriptor<WatchlistEntity>(
            predicate: #Predicate { $0.coinId == coinId }
        )
        guard try mainContext.fetch(descriptor).isEmpty else { return }
        mainContext.insert(WatchlistEntity(coinId: coinId))
        try mainContext.save()
    }

    func removeFromWatchlist(coinId: String) throws {
        let descriptor = FetchDescriptor<WatchlistEntity>(
            predicate: #Predicate { $0.coinId == coinId }
        )
        for entity in try mainContext.fetch(descriptor) {
            mainContext.delete(entity)
        }
        try mainContext.save()
    }

    func syncWatchlist(coinIds: [String]) throws {
        let existing = try mainContext.fetch(FetchDescriptor<WatchlistEntity>())
        let existingIds = Set(existing.map(\.coinId))
        let freshIds = Set(coinIds)

        for coinId in freshIds.subtracting(existingIds) {
            mainContext.insert(WatchlistEntity(coinId: coinId))
        }

        for entity in existing where !freshIds.contains(entity.coinId) {
            mainContext.delete(entity)
        }

        try mainContext.save()
    }
}
