import Foundation

struct GeneratedRecipeCard: Identifiable {
    let id = UUID()
    let receta: Receta
    let subtitle: String
    let priceText: String
    let caloriesText: String
    let featuredIngredients: [Ingrediente]
    let heroTitle: String
}
