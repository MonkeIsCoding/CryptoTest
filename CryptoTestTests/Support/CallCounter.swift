//
//  CallCounter.swift
//  CryptoTestTests
//
//  Created by Kiko on 22/07/2026.
//

import Synchronization

// Thread-safe counter for checking how many times a stub was called.
final class CallCounter: Sendable {
    private let storage = Mutex(0)

    func increment() {
        storage.withLock { $0 += 1 }
    }

    var count: Int {
        storage.withLock { $0 }
    }
}
