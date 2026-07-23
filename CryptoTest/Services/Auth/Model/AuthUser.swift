//
//  UserModel.swift
//  CryptoTest
//
//  Created by Kiko on 18/07/2026.
//

struct AuthUser: Identifiable {
    let id: String
    let email: String
    
    init(id: String, email: String) {
        self.id = id
        self.email = email
    }
    
    static let mock = AuthUser(id: "1", email: "test@test.com")
}

import FirebaseAuth

extension AuthUser {
    init(user: User) {
        id = user.uid
        email = user.email ?? ""
    }
}
