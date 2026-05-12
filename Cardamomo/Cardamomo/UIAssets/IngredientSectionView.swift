import SwiftUI

struct IngredientSectionView: View {
    let section: IngredientSection
    let isSelected: (Ingrediente) -> Bool
    let onToggle: (Ingrediente) -> Void

    private let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 140), spacing: 14)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: sectionIcon)
                    .foregroundStyle(Color.contrast)
                Text(section.title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.primary)
            }

            LazyVGrid(columns: columns, alignment: .leading, spacing: 14) {
                ForEach(section.ingredients) { ingredient in
                    IngredientCardView(
                        ingredient: ingredient,
                        isSelected: isSelected(ingredient)
                    ) {
                        onToggle(ingredient)
                    }
                }
            }
        }
    }

    private var sectionIcon: String {
        switch section.title.lowercased() {
        case let title where title.contains("verd"):
            return "carrot.fill"
        case let title where title.contains("frut"):
            return "basket.fill"
        case let title where title.contains("láct") || title.contains("lact"):
            return "drop.fill"
        case let title where title.contains("carne") || title.contains("prote"):
            return "fish.fill"
        default:
            return "square.grid.2x2.fill"
        }
    }
}
