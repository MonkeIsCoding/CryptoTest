import SwiftUI

struct OfflineBanner: View {
    var message: String = "Offline — showing last synced data"

    var body: some View {
        Label(message, systemImage: "wifi.slash")
            .font(.footnote.weight(.medium))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.background)
    }
}

#Preview {
    OfflineBanner()
}
