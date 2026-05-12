//
//  EmbeddingS.swift
//  Cardamomo
//
//  Created by Alexa Lara on 11/05/26.
//

import NaturalLanguage
import Foundation

class EmbeddingService {
    private let embeddingModel = NLEmbedding.sentenceEmbedding(for: .spanish)

    func generateEmbedding(for recipe: ModelosJson) -> [Double]? {
        let textToEmbed = """
        Receta: \(recipe.nombre).
        Categoría: \(recipe.categoria).
        Nutrición: \(recipe.valorNutricional).
        Ingredientes: \(recipe.ingredientes)
        """
        return generateEmbedding(for: textToEmbed)
    }

    func generateEmbedding(for ingredients: [Ingrediente]) -> [Double]? {
        let ingredientText = ingredients.map { ingredient in
            let tags = ingredient.normalizedTags.joined(separator: ", ")
            return "\(ingredient.name). Tags: \(tags)"
        }
        .joined(separator: ". ")

        return generateEmbedding(for: "Ingredientes disponibles del usuario: \(ingredientText)")
    }

    func generateEmbedding(for text: String) -> [Double]? {
        guard let model = embeddingModel else {
            print("Modelo de embeddings no soportado en este dispositivo.")
            return nil
        }
        // generar vector !!!!
        if let vector = model.vector(for: text) {
            return vector
        }
        return nil
    }
}
