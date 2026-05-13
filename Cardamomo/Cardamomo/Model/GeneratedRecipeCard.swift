import Foundation

struct GeneratedRecipeCard: Identifiable {
    let id = UUID()
    let receta: Receta
    let subtitle: String
    let heroTitle: String
    let featuredIngredients: [Ingrediente]

    init(
        receta: Receta,
        subtitle: String,
        heroTitle: String,
        featuredIngredients: [Ingrediente]
    ) {
        self.receta = receta
        self.subtitle = subtitle
        self.heroTitle = heroTitle
        self.featuredIngredients = featuredIngredients
    }

    init(
        name: String,
        subtitle: String,
        heroTitle: String,
        instructions: String,
        featuredIngredients: [Ingrediente],
        tags: [String],
        generatedByUserId: String,
        createdAt: Date = Date()
    ) {
        self.init(
            receta: Receta(
                id: nil,
                name: name,
                instructions: instructions,
                createdAt: createdAt,
                generatedByUserId: generatedByUserId,
                ingredients: featuredIngredients.map { IngredienteReceta(ingredient: $0) },
                tags: tags
            ),
            subtitle: subtitle,
            heroTitle: heroTitle,
            featuredIngredients: featuredIngredients
        )
    }
}
