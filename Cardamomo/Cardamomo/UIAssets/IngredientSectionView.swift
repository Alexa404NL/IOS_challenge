import SwiftUI

struct IngredientSectionView: View {
    let section: IngredientSection
    let isSelected: (Ingrediente) -> Bool
    let onToggle: (Ingrediente) -> Void
    var onEdit: ((Ingrediente) -> Void)?
    var canEdit: ((Ingrediente) -> Bool)?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: sectionIcon)
                    .foregroundStyle(Color.contrast)
                Text(section.title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.primary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(section.ingredients) { ingredient in
                        IngredientCardView(
                            ingredient: ingredient,
                            isSelected: isSelected(ingredient),
                            action: { onToggle(ingredient) },
                            onEdit: editClosure(for: ingredient)
                        )
                    }
                }
                .padding(.vertical, 2)
                .padding(.horizontal, 2)
            }
        }
    }

    private func editClosure(for ingredient: Ingrediente) -> (() -> Void)? {
        guard let onEdit else { return nil }
        if let canEdit, !canEdit(ingredient) { return nil }
        return { onEdit(ingredient) }
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
