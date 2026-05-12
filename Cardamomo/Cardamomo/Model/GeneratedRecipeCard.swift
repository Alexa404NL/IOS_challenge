import Foundation

struct GeneratedRecipeCard: Identifiable {
    let id = UUID()
    let name: String
    let subtitle: String
    let heroTitle: String
    let instructions: String
    let featuredIngredients: [Ingrediente]
    let tags: [String]
    let generatedByUserId: String
    let createdAt: Date

    var receta: Receta {
        Receta(
            id: nil,
            name: name,
            instructions: instructions,
            createdAt: createdAt,
            generatedByUserId: generatedByUserId,
            imageUrl: nil,
            ingredients: featuredIngredients.map {
                IngredienteReceta(
                    ingredientId: $0.id,
                    name: $0.name,
                    quantity: "1",
                    unit: "porción"
                )
            },
            tags: tags
        )
    }
}
