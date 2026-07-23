//
//  SwiftDataAlertLocalPersistence.swift
//  CryptoTest
//
//  Created by Kiko on 22/07/2026.
//

import Foundation
import SwiftData

@MainActor
struct SwiftDataAlertLocalPersistence: AlertLocalPersistence {

    private let mainContext: ModelContext

    init(context: ModelContext) {
        self.mainContext = context
    }

    func getAlerts() throws -> [AlertModel] {
        let descriptor = FetchDescriptor<AlertEntity>(sortBy: [SortDescriptor(\.addedAt, order: .reverse)])
        return try mainContext.fetch(descriptor).map { $0.toModel() }
    }

    func addAlert(_ alert: AlertModel) throws {
        mainContext.insert(AlertEntity(from: alert))
        try mainContext.save()
    }

    func removeAlert(alertId: String) throws {
        let descriptor = FetchDescriptor<AlertEntity>(
            predicate: #Predicate { $0.id == alertId }
        )
        for entity in try mainContext.fetch(descriptor) {
            mainContext.delete(entity)
        }
        try mainContext.save()
    }

    func syncAlerts(_ alerts: [AlertModel]) throws {
        let existing = try mainContext.fetch(FetchDescriptor<AlertEntity>())
        var existingById = Dictionary(uniqueKeysWithValues: existing.map { ($0.id, $0) })

        for alert in alerts {
            if let entity = existingById.removeValue(forKey: alert.id) {
                entity.triggered = alert.triggered
            } else {
                mainContext.insert(AlertEntity(from: alert))
            }
        }

        for stale in existingById.values {
            mainContext.delete(stale)
        }

        try mainContext.save()
    }

    func markTriggered(alertId: String) throws {
        let descriptor = FetchDescriptor<AlertEntity>(
            predicate: #Predicate { $0.id == alertId }
        )
        guard let entity = try mainContext.fetch(descriptor).first else { return }
        entity.triggered = true
        try mainContext.save()
    }
}
