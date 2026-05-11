import SwiftUI

struct TagChipView: View {
    let title: String
    var isSelected: Bool = false
    var action: (() -> Void)? = nil

    var body: some View {
        let content = Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(isSelected ? Color.light : Color.contrast)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isSelected ? Color.contrastDark : Color.white.opacity(0.95))
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(isSelected ? Color.clear : Color.contrast.opacity(0.15), lineWidth: 1)
            }

        if let action {
            Button(action: action) {
                content
            }
            .buttonStyle(.plain)
        } else {
            content
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        TagChipView(title: "Lácteo")
        TagChipView(title: "Condimento", isSelected: true)
    }
    .padding()
    .background(Color.light)
}
