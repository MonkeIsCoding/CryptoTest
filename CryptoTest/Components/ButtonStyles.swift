import SwiftUI

struct FilledCapsuleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.bold())
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 28)
            .padding(.vertical, 12)
            .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 18))
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

struct HairlineOutlinedButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.bold())
            .foregroundStyle(color)
            .frame(maxWidth: .infinity, minHeight: 28)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(color.opacity(configuration.isPressed ? 0.4 : 0.6), lineWidth: 2)
            )
    }
}

struct HairlineFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(Color.gray, lineWidth: 2)
            )
    }
}

#Preview("Buttons") {
    TextField("Email", text: .constant(""))
        .hairlineField()
        .padding()
    Button("Remove from Watchlist") {}
        .hairlineButton(color: .red)
        .padding()
    Button("Create alert") {}
        .filledButton()
        .padding()
}
