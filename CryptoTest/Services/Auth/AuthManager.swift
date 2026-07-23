//
//  AuthManager.swift
//  CryptoTest
//
//  Created by Kiko on 18/07/2026.
//

import SwiftUI

@MainActor
@Observable
class AuthManager {
    
    private let authService: AuthService
    
    private(set) var authUser: AuthUser?
    private var listener: (any NSObjectProtocol)?
    
    init(authService: AuthService) {
        self.authService = authService
        self.authUser = authService.getCurrentUser()
        self.addAuthListener()
    }
    
    private func addAuthListener() {
        Task {
            for await auth in
                authService.addAuthListener(onListenerAttached: { listener in
                self.listener = listener
            }) {
                self.authUser = auth
            }
        }
    }
    
    func getAuthId() throws -> String {
        guard let userId = authUser?.id else {
            throw AuthError.userNotFound
        }
        return userId
    }
    
    func createAccount(email: String, password: String) async throws {
        authUser = try await authService.createAccount(email: email, password: password)
    }
    
    func login(email: String, password: String) async throws {
        authUser = try await authService.login(email: email, password: password)
    }
    
    func logout() throws {
        try authService.logout()
        authUser = nil
    }

    func reauthenticate(password: String) async throws {
        try await authService.reauthenticate(password: password)
    }

    func deleteAccount() async throws {
        try await authService.deleteAccount()
    }
    
    enum AuthError: LocalizedError {
        case userNotFound
        
        var errorDescription: String? {
            switch self {
            case .userNotFound:
                return "User not found"
            }
        }
    }
}
