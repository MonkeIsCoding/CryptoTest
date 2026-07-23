//
//  FirebaseAlertService.swift
//  CryptoTest
//
//  Created by Kiko on 21/07/2026.
//

import FirebaseFirestore

class FirebaseAlertService: AlertService {

    private var collection: CollectionReference {
        Firestore.firestore().collection("alerts")
    }

    func fetchAlerts() async throws -> [AlertModel]  {
        let userId = try CurrentUser.id()
        let snapshot = try await collection.whereField("user_id", isEqualTo: userId).getDocuments(source: .server)
        return try snapshot.documents.map {
            try $0.data(as: AlertModel.self)
        }
    }

    func addAlert(coinId: String, price: Double, type: AlertType) async throws -> AlertModel {
        let userId = try CurrentUser.id()
        let alert = AlertModel(id: UUID().uuidString, userId: userId, coinId: coinId, targetPrice: price, type: type)
        try collection.document(alert.id).setData(from: alert)
        return alert
    }

    func removeAlert(alertId: String) async throws {
        try await collection.document(alertId).delete()
    }

    func markTriggered(alertId: String) async throws {
        try await collection.document(alertId).updateData(["triggered": true])
    }

    func deleteAllForCurrentUser() async throws {
        let userId = try CurrentUser.id()
        let snapshot = try await collection.whereField("user_id", isEqualTo: userId).getDocuments()
        guard !snapshot.documents.isEmpty else { return }
        let batch = Firestore.firestore().batch()
        for document in snapshot.documents {
            batch.deleteDocument(document.reference)
        }
        try await batch.commit()
    }
}
