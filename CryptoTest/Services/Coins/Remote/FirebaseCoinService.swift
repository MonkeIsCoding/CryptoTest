//
//  FirebaseCoinService.swift
//  CryptoTest
//
//  Created by Kiko on 21/07/2026.
//

import FirebaseFirestore

final class FirebaseCoinService: CoinService {
    
    private var collection: CollectionReference {
        Firestore.firestore().collection("coins")
    }
    
    func fetchCoins() async throws -> [CoinModel]  {
        let snapshot = try await collection.getDocuments(source: .server)
        return try snapshot.documents.map { doc in
            try doc.data(as: CoinModel.self)
        }
    }
    
    func updateCoins(_ coins: [CoinModel]) throws {
        for coin in coins {
            try collection.document(coin.id).setData(from: coin)
        }
    }
}
