//
//  FirebaseAuthService.swift
//  CryptoTest
//
//  Created by Kiko on 23/07/2026.
//

import FirebaseAuth

class FirebaseAuthService: AuthService {
    
    func addAuthListener(onListenerAttached: (any NSObjectProtocol) -> Void) -> AsyncStream<AuthUser?> {
        AsyncStream { continuation in
            let listener = Auth.auth().addStateDidChangeListener{ _, user in
                if let user {
                    let authUser = AuthUser(user: user)
                    continuation.yield(authUser)
                } else {
                    continuation.yield(nil)
                }
            }
            
            onListenerAttached(listener)
        }
    }
    
    func getCurrentUser() -> AuthUser? {
        if let user = Auth.auth().currentUser {
            return AuthUser(user: user)
        }
        return nil
    }
    
    func createAccount(email: String, password: String) async throws -> AuthUser {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthUser(user: result.user)
    }
    
    func login(email: String, password: String) async throws -> AuthUser {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthUser(user: result.user)
    }
    
    func logout() throws {
       try Auth.auth().signOut()
    }

    func reauthenticate(password: String) async throws {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            throw FirebaseError.userNotFound
        }
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        _ = try await user.reauthenticate(with: credential)
    }

    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw FirebaseError.userNotFound
        }
        try await user.delete()
    }
    
    enum FirebaseError: LocalizedError {
        case userNotFound
        
        var errorDescription: String? {
            switch self {
            case .userNotFound:
                return "User not found"
            }
        }
    }
}
