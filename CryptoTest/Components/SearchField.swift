import SwiftUI

struct SearchField: View {
    @Binding var text: String
    var prompt: String = "Search"

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField(prompt, text: $text)
                .focused($isFocused)
                .submitLabel(.search)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(.quaternary, in: .rect(cornerRadius: 10))
        .padding(.horizontal, 10)
        .padding(.bottom, 8)
    }
}

#Preview {
    @Previewable @State var text = ""
    SearchField(text: $text, prompt: "Search coins")
}
