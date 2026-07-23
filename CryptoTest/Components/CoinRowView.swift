import SwiftUI

struct CoinRowView: View {
    let coin: CoinModel

    @Environment(NetworkMonitor.self) private var networkMonitor

    private var isPositive: Bool { coin.priceChangePercentage24h ?? 0 >= 0 }

    init(_ coin: CoinModel) {
        self.coin = coin
    }
    
    var body: some View {
        HStack {
            coinImage
            VStack(alignment: .leading, spacing: 2) {
                Text(coin.symbol.uppercased())
                    .font(.body.bold())
                Text(coin.name)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(coin.currentPrice ?? 0, format: .currency(code: "EUR"))
                    .font(.body.bold())

                if let change = coin.priceChangePercentage24h {
                    Text("\(isPositive ? "+" : "")\(change, specifier: "%.2f")%")
                        .font(.subheadline)
                        .foregroundStyle(isPositive ? Color.green : Color.red)
                }
            }
        }
        .listRowSeparatorTint(Color.primary.opacity(0.08))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        var parts = ["\(coin.name), \(coin.symbol.uppercased())"]
        parts.append((coin.currentPrice ?? 0).formatted(.currency(code: "EUR")))
        if let change = coin.priceChangePercentage24h {
            parts.append("\(isPositive ? "up" : "down") \(abs(change).formatted(.number.precision(.fractionLength(2)))) percent")
        }
        return parts.joined(separator: ", ")
    }

    private var coinImage: some View {
        AsyncImage(url: coin.image) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(.white))
                    .clipShape(Circle())
                    .overlay {
                        Circle()
                            .strokeBorder(Color.accentColor, lineWidth: 2)
                            .frame(width: 32, height: 32)
                    }
            case .failure:
                symbolPlaceholder
            default:
                ProgressView()
            }
        }
        // image wasnt loading when coming back from airplane mode
        // this refreshes it
        .id(networkMonitor.isConnected)
        .frame(width: 32, height: 32)
    }

    private var symbolPlaceholder: some View {
        Circle()
            .fill(Color.secondary.opacity(0.15))
            .frame(width: 28, height: 28)
            .overlay {
                Text(coin.symbol.prefix(1).uppercased())
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }
    }
}

#Preview {
    List {
        CoinRowView(.mock)
        CoinRowView(.mock)
        CoinRowView(.mock)
        CoinRowView(.mock)
    }
    .listStyle(.plain)
    .environment(NetworkMonitor())
}
