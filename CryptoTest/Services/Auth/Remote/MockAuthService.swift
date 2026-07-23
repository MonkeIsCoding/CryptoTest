//
//  MockAuthService.swift
//  CryptoTest
//
//  Created by Kiko on 23/07/2026.
//

import Foundation

class MockAuthService: AuthService {
    
    let currentUser: AuthUser?
    
    init(user: AuthUser? = nil) {
        self.currentUser = user
    }
    
    func addAuthListener(onListenerAttached: (any NSObjectProtocol) -> Void) -> AsyncStream<AuthUser?> {
        AsyncStream { continuation in
            continuation.yield(currentUser)
        }
    }
    
    func getCurrentUser() -> AuthUser? {
        currentUser
    }
    
    func createAccount(email: String, password: String) async throws -> AuthUser {
        AuthUser.mock
    }
    
    func login(email: String, password: String) async throws -> AuthUser {
        AuthUser.mock
    }
    
    func logout() throws {

    }

    func reauthenticate(password: String) async throws {

    }

    func deleteAccount() async throws {

    }
}
