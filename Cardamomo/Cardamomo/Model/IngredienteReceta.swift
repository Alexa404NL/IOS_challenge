//
//  IngredienteReceta.swift
//  Cardamomo
//
//  Created by Alexa Lara on 10/05/26.
//

import Foundation

struct IngredienteReceta: Codable {
    var ingredientId: String?
    var name: String
    var quantity: String
    var unit: String
}

extension IngredienteReceta {
    init(ingredient: Ingrediente, quantity: String = "1", unit: String = "porción") {
        self.ingredientId = ingredient.id
        self.name = ingredient.name
        self.quantity = quantity
        self.unit = unit
    }
}
