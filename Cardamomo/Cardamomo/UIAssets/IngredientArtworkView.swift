import SwiftUI

struct IngredientArtworkView: View {
    let ingredient: Ingrediente
    let isSelected: Bool
    let height: CGFloat
    let cornerRadius: CGFloat
    let iconSize: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(isSelected ? Color.contrastDark.opacity(0.16) : Color.white)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .overlay {
                if let image = ingredient.uiImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: ingredient.symbolName)
                        .font(.system(size: iconSize, weight: .semibold))
                        .foregroundStyle(isSelected ? Color.contrast : Color.contrastDark)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}
