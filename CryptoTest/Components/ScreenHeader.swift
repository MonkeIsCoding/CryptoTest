import SwiftUI

struct ScreenHeader: View {
    let title: String
    var isOffline: Bool = false
    var offlineMessage: String = "Offline — showing last synced data"

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.largeTitle.bold())
                .padding(.horizontal, 10)
                .padding(.top, 8)

            if isOffline {
                OfflineBanner(message: offlineMessage)
            }
        }
        .padding(.bottom, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    VStack(spacing: 24) {
        ScreenHeader(title: "Home")
        ScreenHeader(title: "Home", isOffline: true, offlineMessage: "Offline — showing last synced watchlist")
    }
}
