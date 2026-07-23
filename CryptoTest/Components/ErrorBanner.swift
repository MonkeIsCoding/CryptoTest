import SwiftUI

struct ErrorBanner: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Label(message, systemImage: "exclamationmark.triangle.fill")
                .font(.footnote.weight(.medium))
                .foregroundStyle(Color.negative)
                .lineLimit(2)

            Spacer(minLength: 8)

            Button("Retry", action: retry)
                .font(.footnote.weight(.semibold))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.negative.opacity(0.1))
    }
}

#Preview {
    ErrorBanner(message: "Couldn't refresh — showing cached data") {}
}
