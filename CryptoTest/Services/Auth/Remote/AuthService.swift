//
//  AuthService.swift
//  CryptoTest
//
//  Created by Kiko on 23/07/2026.
//

import Foundation

protocol AuthService {
    func addAuthListener(onListenerAttached: (any NSObjectProtocol) -> Void) -> AsyncStream<AuthUser?>
    func getCurrentUser() -> AuthUser?
    func createAccount(email: String, password: String) async throws -> AuthUser
    func login(email: String, password: String) async throws -> AuthUser
    func logout() throws
    func reauthenticate(password: String) async throws
    func deleteAccount() async throws
}
