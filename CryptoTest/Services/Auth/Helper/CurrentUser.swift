//
//  CurrentUser.swift
//  CryptoTest
//
//  Created by Kiko on 21/07/2026.
//

import FirebaseAuth

enum CurrentUser {
    static func id() throws -> String {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw CurrentUserError.notAuthenticated
        }
        return uid
    }

    enum CurrentUserError: LocalizedError {
        case notAuthenticated

        var errorDescription: String? {
            switch self {
            case .notAuthenticated:
                return "No authenticated user found."
            }
        }
    }
}
