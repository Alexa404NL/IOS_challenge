//
//  RecipeRAGService.swift
//  Cardamomo
//
//  Created by Alexa Lara on 11/05/26.
//

import Foundation
import SwiftData

#if canImport(FoundationModels)
import FoundationModels
#endif

struct RetrievedRecipe {
    let recipe: RecipeEntity
    let score: Double
}

@MainActor
final class RecipeRAGService {
    private let embeddingService = EmbeddingService()
    private let decoder = JSONDecoder()

    func generateSuggestions(
        ingredients: [Ingrediente],
        context: ModelContext,
        userId: String
    ) async throws -> [GeneratedRecipeCard] {
        guard !ingredients.isEmpty else {
            throw RecipeRAGError.emptyIngredients
        }

        guard let queryVector = embeddingService.generateEmbedding(for: ingredients) else {
            throw RecipeRAGError.embeddingUnavailable
        }

        let references = try retrieveSimilarRecipes(
            matching: queryVector,
            context: context,
            limit: 3
        )

        guard !references.isEmpty else {
            throw RecipeRAGError.emptyRecipeDatabase
        }

        let prompt = buildPrompt(
            userIngredients: ingredients,
            references: references
        )

        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            if let generatedRecipes = try? await generateWithFoundationModels(prompt: prompt),
               !generatedRecipes.isEmpty {
                let generatedCards = makeCards(
                    from: generatedRecipes,
                    ingredients: ingredients,
                    userId: userId
                )
                return completeCardsIfNeeded(
                    generatedCards,
                    ingredients: ingredients,
                    references: references,
                    userId: userId
                )
            }
        }
        #endif

        return makeFallbackCards(
            ingredients: ingredients,
            references: references,
            userId: userId
        )
    }

    private func retrieveSimilarRecipes(
        matching queryVector: [Double],
        context: ModelContext,
        limit: Int
    ) throws -> [RetrievedRecipe] {
        let descriptor = FetchDescriptor<RecipeEntity>()
        let recipes = try context.fetch(descriptor)

        return recipes
            .compactMap { recipe -> RetrievedRecipe? in
                guard let vector = recipe.embeddingVector else { return nil }
                let score = CosineSimilarity.calculate(queryVector, vector)
                return RetrievedRecipe(recipe: recipe, score: score)
            }
            .sorted { $0.score > $1.score }
            .prefix(limit)
            .map { $0 }
    }

    private func buildPrompt(
        userIngredients: [Ingrediente],
        references: [RetrievedRecipe]
    ) -> String {
        let ingredientNames = userIngredients.map { $0.name }.joined(separator: ", ")
        let referenceText = references.enumerated().map { index, retrieved in
            let recipe = retrieved.recipe
            return """
            R\(index + 1): \(recipe.nombre)
            Categoría: \(recipe.categoria)
            Ingredientes originales: \(recipe.ingredientes)
            Pasos de referencia: \(recipe.pasos.prefix(900))
            Valor nutricional: \(recipe.valorNutricional)
            Similitud: \(String(format: "%.3f", retrieved.score))
            """
        }
        .joined(separator: "\n\n")

        return """
        Eres un chef y cocinero experto en preparar alimentos.
        Aquí tienes 3 recetas de referencia:
        \(referenceText)

        Ahora genera 3 recetas nuevas usando solo estos ingredientes del usuario como ingredientes principales:
        \(ingredientNames)


        Mantén un estilo mexicano casero inspirado en las recetas de referencia.
        Puedes asumir básicos de cocina como agua, sal, pimienta, aceite y calor.
        Si los ingredientes incluidos mencionan estos o alguna especia NO los incluyas como parte del platillo principal.
        No agregues ingredientes principales que no estén en la lista del usuario.
        Dentro de las intstrucciones se claro y
        mayor detalle aquello que se tiene que realizar, desde preparación de instrumentos,
        cómo debe añadirse el alimento,
        si debe ser condimentado, esto siguiendo el formato extenso de las instrucciones de las recetas provistas como referencia. 
        En caso de ser necesario extiende las instrucciones lo que sea necesario.
        Responde únicamente JSON válido, sin markdown, con esta forma exacta:
        {
          "recipes": [
            {
              "name": "Nombre corto",
              "subtitle": "Una frase útil para comparar la receta",
              "heroTitle": "Etiqueta breve de estilo",
              "instructions": "Preparación clara en español, tan extensa como se requiera para la receta",
              "tags": ["tag1", "tag2"]
            }
          ]
        }

        Dentr
        """
    }

    private func makeCards(
        from recipes: [RAGGeneratedRecipe],
        ingredients: [Ingrediente],
        userId: String
    ) -> [GeneratedRecipeCard] {
        let fallbackTags = Array(Set(ingredients.flatMap { $0.normalizedTags })).sorted()
        let featuredIngredients = Array(ingredients.prefix(6))

        return recipes.prefix(3).map { recipe in
            GeneratedRecipeCard(
                name: recipe.name,
                subtitle: recipe.subtitle,
                heroTitle: recipe.heroTitle,
                instructions: recipe.instructions,
                featuredIngredients: featuredIngredients,
                tags: recipe.tags.isEmpty ? fallbackTags : recipe.tags,
                generatedByUserId: userId,
                createdAt: Date()
            )
        }
    }

    private func makeFallbackCards(
        ingredients: [Ingrediente],
        references: [RetrievedRecipe],
        userId: String
    ) -> [GeneratedRecipeCard] {
        let baseName = ingredients.first?.name.capitalized ?? "la casa"
        let ingredientList = ingredients.map { $0.name }.joined(separator: ", ")
        let combinedTags = Array(Set(ingredients.flatMap { $0.normalizedTags })).sorted()
        let featuredIngredients = Array(ingredients.prefix(6))

        return references.prefix(3).enumerated().map { index, reference in
            GeneratedRecipeCard(
                name: "\(reference.recipe.nombre) con \(baseName)",
                subtitle: "Inspirada en \(reference.recipe.nombre), adaptada a lo que tienes.",
                heroTitle: ["Casera", "Doradita", "Mexicana"][safe: index] ?? "Casera",
                instructions: fallbackInstructions(
                    ingredientList: ingredientList,
                    referenceName: reference.recipe.nombre
                ),
                featuredIngredients: featuredIngredients,
                tags: combinedTags,
                generatedByUserId: userId,
                createdAt: Date()
            )
        }
    }

    private func completeCardsIfNeeded(
        _ cards: [GeneratedRecipeCard],
        ingredients: [Ingrediente],
        references: [RetrievedRecipe],
        userId: String
    ) -> [GeneratedRecipeCard] {
        guard cards.count < 3 else {
            return Array(cards.prefix(3))
        }

        let fallbackCards = makeFallbackCards(
            ingredients: ingredients,
            references: references,
            userId: userId
        )
        let existingNames = Set(cards.map { $0.name.lowercased() })
        let additions = fallbackCards.filter { !existingNames.contains($0.name.lowercased()) }
        return Array((cards + additions).prefix(3))
    }

    #if canImport(FoundationModels)
    @available(iOS 26.0, *)
    private func generateWithFoundationModels(prompt: String) async throws -> [RAGGeneratedRecipe] {
        let model = SystemLanguageModel.default
        guard model.isAvailable else {
            throw RecipeRAGError.foundationModelUnavailable
        }

        let session = LanguageModelSession(
            model: model,
            instructions: """
            Eres un chef mexicano. Generas recetas prácticas, claras y fieles a los ingredientes del usuario.
            """
        )
        let response = try await session.respond(
            to: prompt,
            options: GenerationOptions(temperature: 0.7, maximumResponseTokens: 1400)
        )

        let json = extractJSONObject(from: response.content)
        let result = try decoder.decode(RAGGeneratedRecipeResponse.self, from: Data(json.utf8))
        return result.recipes
    }
    #endif

    private func fallbackInstructions(ingredientList: String, referenceName: String) -> String {
        """
        Usa como base: \(ingredientList). Toma el estilo de \(referenceName): prepara los ingredientes por capas, \
        cocina hasta integrar sabores y ajusta sal, textura y acidez al final.
        """
    }

    private func extractJSONObject(from text: String) -> String {
        if let start = text.firstIndex(of: "{"),
           let end = text.lastIndex(of: "}") {
            return String(text[start...end])
        }
        return text
    }
}

enum RecipeRAGError: LocalizedError {
    case emptyIngredients
    case embeddingUnavailable
    case emptyRecipeDatabase
    case foundationModelUnavailable

    var errorDescription: String? {
        switch self {
        case .emptyIngredients:
            return "Selecciona al menos un ingrediente para crear recetas."
        case .embeddingUnavailable:
            return "No se pudo crear el vector semántico de tus ingredientes en este dispositivo."
        case .emptyRecipeDatabase:
            return "La base local de recetas todavía no tiene embeddings para comparar."
        case .foundationModelUnavailable:
            return "El modelo de Apple Intelligence no está disponible en este dispositivo."
        }
    }
}

private struct RAGGeneratedRecipeResponse: Decodable {
    let recipes: [RAGGeneratedRecipe]
}

private struct RAGGeneratedRecipe: Decodable {
    let name: String
    let subtitle: String
    let heroTitle: String
    let instructions: String
    let tags: [String]
}

private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
