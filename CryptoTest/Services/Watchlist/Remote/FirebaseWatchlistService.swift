//
//  FirebaseWatchlistService.swift
//  CryptoTest
//
//  Created by Kiko on 21/07/2026.
//

import FirebaseFirestore

class FirebaseWatchlistService: WatchlistService {

    private var collection: CollectionReference {
        Firestore.firestore().collection("watchlist")
    }

    func fetchWatchlistCoins() async throws -> [String]  {
        let userId = try CurrentUser.id()
        let snapshot = try await collection.whereField("user_id", isEqualTo: userId).getDocuments(source: .server)
        return try snapshot.documents.map {
            try $0.data(as: WatchListModel.self).coinId
        }
    }

    func addToWatchlist(coinId: String) async throws {
        let userId = try CurrentUser.id()
        let docId = "\(userId)_\(coinId)"
        let item = WatchListModel(userId: userId, coinId: coinId)
        try collection.document(docId).setData(from: item)
    }

    func removeFromWatchlist(coinId: String) async throws {
        let userId = try CurrentUser.id()
        let docId = "\(userId)_\(coinId)"
        try await collection.document(docId).delete()
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
