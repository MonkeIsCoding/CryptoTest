//
//  LoginView.swift
//  CryptoTest
//
//  Created by Kiko on 22/07/2026.
//

import SwiftUI

struct LoginView: View {

    @Environment(AuthManager.self) private var authManager

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoggingIn = false
    @State private var errorMessage: String?
    @State private var showError = false

    let onSwitchToCreateAccount: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Log In")
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 12)

            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .hairlineField()

            SecureField("Password", text: $password)
                .textContentType(.password)
                .hairlineField()

            Button(isLoggingIn ? "Logging in…" : "Log In", action: logIn)
                .filledButton()
                .disabled(isLoggingIn)

            Button("Need an account? Register", action: onSwitchToCreateAccount)
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(.top, 10)
        }
        .padding()
        .alert(errorMessage ?? "", isPresented: $showError) {}
    }

    private func logIn() {
        isLoggingIn = true
        Task {
            defer { isLoggingIn = false }
            do {
                try await authManager.login(email: email, password: password)
            } catch {
                errorMessage = "Couldn't log in. Check your email and password and try again."
                showError = true
            }
        }
    }
}

#Preview {
    LoginView(onSwitchToCreateAccount: {})
        .environment(AuthManager(authService: MockAuthService(user: AuthUser.mock)))
}
