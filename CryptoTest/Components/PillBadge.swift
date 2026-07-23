import SwiftUI

struct PillBadge: View {
    enum Status {
        case triggered
        case watching

        var text: String {
            switch self {
            case .triggered: "Triggered"
            case .watching: "Watching"
            }
        }

        var color: Color {
            switch self {
            case .triggered: .positive
            case .watching: .gray
            }
        }
    }

    let status: Status

    var body: some View {
        Text(status.text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(status.color)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(status.color.opacity(0.2), in: Capsule())
    }
}

#Preview {
    PillBadge(status: .triggered)
    PillBadge(status: .watching)
}
