//
//  CreateAccountView.swift
//  CryptoTest
//
//  Created by Kiko on 22/07/2026.
//

import SwiftUI

struct CreateAccountView: View {

    @Environment(AuthManager.self) private var authManager

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isCreatingAccount = false
    @State private var errorMessage: String?
    @State private var showError = false

    let onSwitchToLogin: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Create Account")
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 12)

            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .hairlineField()

            SecureField("Password", text: $password)
                .textContentType(.newPassword)
                .hairlineField()

            Button(isCreatingAccount ? "Creating account…" : "Create Account", action: createAccount)
                .filledButton()
                .disabled(isCreatingAccount)

            Button("Have an account? Log in", action: onSwitchToLogin)
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(.top, 10)
        }
        .padding()
        .alert(errorMessage ?? "", isPresented: $showError) {}
    }

    private func createAccount() {
        isCreatingAccount = true
        Task {
            defer { isCreatingAccount = false }
            do {
                try await authManager.createAccount(email: email, password: password)
            } catch {
                errorMessage = "Couldn't create your account. \(error.localizedDescription)"
                showError = true
            }
        }
    }
}

#Preview {
    CreateAccountView(onSwitchToLogin: {})
        .environment(AuthManager(authService: MockAuthService(user: AuthUser.mock)))
}
