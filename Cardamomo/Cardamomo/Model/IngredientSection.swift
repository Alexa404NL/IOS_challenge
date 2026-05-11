import Foundation

struct IngredientSection: Identifiable {
    let title: String
    let ingredients: [Ingrediente]
    var id: String { title }
}
