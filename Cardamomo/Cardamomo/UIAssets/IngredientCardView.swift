import SwiftUI

struct IngredientCardView: View {
    let ingredient: Ingrediente
    let isSelected: Bool
    let action: () -> Void
    var onEdit: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 12) {
            IngredientArtworkView(
                ingredient: ingredient,
                isSelected: isSelected,
                height: 88,
                cornerRadius: 22,
                iconSize: 28
            )
            Text(ingredient.name)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(maxWidth: .infinity)
        }
        .padding(10)
        .frame(width: 130)
        .background(Color.white.opacity(0.98))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(isSelected ? Color.contrastDark : Color.clear, lineWidth: 2)
        }
        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .onTapGesture(perform: action)
        .overlay(alignment: .topTrailing) {
            if let onEdit {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.light)
                        .frame(width: 26, height: 26)
                        .background(Color.contrastDark)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .padding(6)
            }
        }
    }
}
