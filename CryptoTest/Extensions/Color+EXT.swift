import SwiftUI

extension Color {
    static let positive = Color.green
    static let negative = Color.red

    static func priceChange(_ value: Double) -> Color {
        value >= 0 ? .positive : .negative
    }
}
