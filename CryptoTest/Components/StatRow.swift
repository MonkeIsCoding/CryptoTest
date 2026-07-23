import SwiftUI

struct StatRow: View {
    let label: String
    let value: String

    var body: some View {
        LabeledContent(label, value: value)
            .padding(.vertical, 6)
    }
}

#Preview {
    VStack(spacing: 0) {
        StatRow(label: "Market cap", value: "US$1.3T")
        StatRow(label: "Last updated", value: "Jul 6 at 12:00")
    }
    .padding()
}
