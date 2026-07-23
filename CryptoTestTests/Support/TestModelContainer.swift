//
//  TestModelContainer.swift
//  CryptoTestTests
//
//  Created by Kiko on 22/07/2026.
//

import Foundation
import SwiftData
@testable import CryptoTest

@MainActor
enum TestModelContainer {
    static func make() -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        return try! ModelContainer(
            for: CoinEntity.self, WatchlistEntity.self, AlertEntity.self,
            configurations: configuration
        )
    }

    // Plain `ModelContext`, not `container.mainContext` — `mainContext` requires the real
    // main thread, which Swift Testing tests don't guarantee, and that crashes.
    static func makeContext() -> ModelContext {
        ModelContext(make())
    }
}
