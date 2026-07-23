import SwiftUI

enum AuthDestination {
    case login
    case createAccount
}

struct WelcomeView: View {

    @State private var mode: AuthDestination = .login
    @State private var showAuthForm = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 24) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.accentColor)
                        .frame(width: 80, height: 80)
                        .overlay {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 36, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                        .accessibilityHidden(true)

                    VStack(spacing: 8) {
                        Text("Track crypto, simply")
                            .font(.title.bold())
                            .multilineTextAlignment(.center)

                        Text("Live prices, watchlists, and price alerts — all in one clean view")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                    }
                }

                Spacer()

                VStack(spacing: 12) {
                    Button("Create account") {
                        mode = .createAccount
                        showAuthForm = true
                    }
                    .filledButton()

                    Button("Log in") {
                        mode = .login
                        showAuthForm = true
                    }
                    .hairlineButton(color: .primary)
                }
            }
            .padding()
            .navigationDestination(isPresented: $showAuthForm) {
                Group {
                    switch mode {
                    case .login:
                        LoginView(onSwitchToCreateAccount: { mode = .createAccount })
                    case .createAccount:
                        CreateAccountView(onSwitchToLogin: { mode = .login })
                    }
                }
                .navigationBarBackButtonHidden()
            }
        }
    }
}

#Preview {
    WelcomeView()
        .environment(AuthManager(authService: MockAuthService()))
}
