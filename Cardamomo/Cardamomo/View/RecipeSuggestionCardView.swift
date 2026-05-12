import SwiftUI

struct RecipeSuggestionCardView: View {
    let card: GeneratedRecipeCard
    let isSaved: Bool
    let onSave: () -> Void

    private let gridColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                hero

                VStack(alignment: .leading, spacing: 14) {
                    Text(card.receta.name)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                    Text(card.subtitle)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                LazyVGrid(columns: gridColumns, spacing: 12) {
                    ForEach(card.featuredIngredients) { ingredient in
                        VStack(spacing: 10) {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color.light.opacity(0.5))
                                .frame(height: 78)
                                .overlay {
                                    Image(systemName: ingredient.symbolName)
                                        .font(.system(size: 24, weight: .semibold))
                                        .foregroundStyle(Color.contrast)
                                }
                            Text(ingredient.name)
                                .font(.footnote.weight(.semibold))
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                        .padding(12)
                        .background(Color.contrast.opacity(0.10))
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Preparación")
                        .font(.title3.weight(.bold))
                    Text(card.receta.instructions)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 14) {
                    Text(card.heroTitle)
                        .font(.headline)
                        .foregroundStyle(Color.contrast)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.92))
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

                    Button(isSaved ? "Guardada" : "Guardar receta") {
                        onSave()
                    }
                    .buttonStyle(Boton(backgroundColor: isSaved ? .contrast : .contrastDark, textColor: .light))
                    .disabled(isSaved)
                    .frame(maxWidth: .infinity)
                }
                .padding(.bottom, 8)
            }
            .padding(24)
        }
        .scrollIndicators(.hidden)
        .background(
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .fill(Color.accentColor.opacity(0.4))
        )
        .padding(.vertical, 16)
        .padding(.horizontal, 6)
    }

    private var hero: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .fill(Color.contrast.opacity(0.4))
                .frame(height: 290)

            Circle()
                .fill(Color.dark)
                .frame(width: 215, height: 215)

            ForEach(Array(card.featuredIngredients.prefix(5).enumerated()), id: \.offset) { index, ingredient in
                ingredientOrb(for: ingredient)
                    .offset(offsets[index])
            }
        }
    }

    private var offsets: [CGSize] {
        [
            CGSize(width: -66, height: -40),
            CGSize(width: 0, height: -72),
            CGSize(width: 68, height: -18),
            CGSize(width: -52, height: 54),
            CGSize(width: 54, height: 58)
        ]
    }

    private func ingredientOrb(for ingredient: Ingrediente) -> some View {
        VStack(spacing: 8) {
            Image(systemName: ingredient.symbolName)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.contrast)
            Text(ingredient.name)
                .font(.caption.weight(.semibold))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .padding(12)
        .frame(width: 92, height: 92)
        .background(Color.light)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}
