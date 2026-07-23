//
//  SwiftDataPersistenceTests.swift
//  CryptoTestTests
//
//  Created by Kiko on 22/07/2026.
//

import Testing

// Shared namespace for all SwiftData persistence suites. `.serialized` stops the nested
// suites from creating in-memory `ModelContainer`s at the same time, which crashes.
@Suite(.serialized)
struct SwiftDataPersistenceTests {}
