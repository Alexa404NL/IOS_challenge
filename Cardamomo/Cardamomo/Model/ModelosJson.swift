//
//  ModelosJson.swift
//  Cardamomo
//
//  Created by Alexa Lara on 11/05/26.
//

import Foundation
import SwiftData

struct ModelosJson: Codable {
    let id: Int
    let nombre: String
    let ingredientes: String
    let pasos: String
    let categoria: String
    let valorNutricional: String

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case nombre = "Nombre"
        case ingredientes = "Ingredientes"
        case pasos = "Pasos"
        case categoria = "Categoria"
        case valorNutricional = "Valor nutricional"
    }
}

// guardar en local
@Model
class RecipeEntity {
    @Attribute(.unique) var id: Int
    var nombre: String
    var ingredientes: String
    var pasos: String
    var categoria: String
    var valorNutricional: String
    // como doubkle
    var embeddingData: Data

    init(
        id: Int,
        nombre: String,
        ingredientes: String,
        pasos: String,
        categoria: String,
        valorNutricional: String,
        embeddingData: Data
    ) {
        self.id = id
        self.nombre = nombre
        self.ingredientes = ingredientes
        self.pasos = pasos
        self.categoria = categoria
        self.valorNutricional = valorNutricional
        self.embeddingData = embeddingData
    }

    // Helper para recuperar el vector
    var embeddingVector: [Double]? {
        try? JSONDecoder().decode([Double].self, from: embeddingData)
    }
}
