import SwiftUI

struct IngredientCardView: View {
    let ingredient: Ingrediente
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(isSelected ? Color.contrastDark.opacity(0.16) : Color.white)
                        .frame(height: 88)
                    Image(systemName: ingredient.symbolName)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(isSelected ? Color.contrast : Color.contrastDark)
                }
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
