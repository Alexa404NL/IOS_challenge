import SwiftUI

struct IngredientCardView: View {
    let ingredient: Ingrediente
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
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
            .background(Color.white.opacity(0.98))
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(isSelected ? Color.contrastDark : Color.clear, lineWidth: 2)
            }
        }
        .buttonStyle(.plain)
    }
}
