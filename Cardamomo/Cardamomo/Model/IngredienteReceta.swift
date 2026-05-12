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
