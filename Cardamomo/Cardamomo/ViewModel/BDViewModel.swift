//
//  BDViewModel.swift
//  Cardamomo
//
//  Created by Alexa Lara on 11/05/26.
//

import Foundation
import SwiftUI
import SwiftData
import Combine

@MainActor
class BDViewModel: ObservableObject {
    @Published var isGeneratingEmbeddings = false
    @Published var processedRecipes = 0
    @Published var totalRecipes = 0
    @Published var seedMessage: String?

    private let embeddingService = EmbeddingService()

    var seedProgress: Double {
        guard totalRecipes > 0 else { return 0 }
        return Double(processedRecipes) / Double(totalRecipes)
    }

    // inicializado (seed function)
    func seedDataIfNeeded(context: ModelContext) async {
        do {
            let recipes = try loadRecipesFromBundle()
            totalRecipes = recipes.count

            let fetchDescriptor = FetchDescriptor<RecipeEntity>()
            let savedRecipes = (try? context.fetch(fetchDescriptor)) ?? []
            let savedIds = Set(savedRecipes.map { $0.id })

            if savedIds.count >= recipes.count {
                print("!!!!!!!!!!! La base de datos ya tiene \(savedIds.count) recetas")
                return
            }

            print("BD incompleta. Generando embeddings")
            await loadAndEmbedJSON(recipes: recipes, savedIds: savedIds, context: context)
        } catch {
            seedMessage = "No se pudo cargar Recetas.json: \(error.localizedDescription)"
            print("Error al cargar Recetas.json: \(error)")
        }
    }

    private func loadRecipesFromBundle() throws -> [ModelosJson] {
        let resourceNames = ["recetas", "Recetas"]
        guard let url = resourceNames
            .compactMap({ Bundle.main.url(forResource: $0, withExtension: "json") })
            .first else {
            let jsonFiles = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) ?? []
            let jsonNames = jsonFiles.map { $0.lastPathComponent }.sorted().joined(separator: ", ")
            print("Recetas.json no esta en el bundle. Bundle: \(Bundle.main.bundleURL.path)")
            print("JSON disponibles en bundle: [\(jsonNames)]")
            throw BDSeedError.recipeJSONNotFound
        }

        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([ModelosJson].self, from: data)
    }

    private func loadAndEmbedJSON(
        recipes: [ModelosJson],
        savedIds: Set<Int>,
        context: ModelContext
    ) async {
        isGeneratingEmbeddings = true
        processedRecipes = savedIds.count
        seedMessage = "Preparando recetas..."
        defer {
            isGeneratingEmbeddings = false
            seedMessage = nil
        }

        await Task.yield()

        for recipe in recipes where !savedIds.contains(recipe.id) {
            seedMessage = "Vectorizando \(recipe.nombre)"
            if let vector = embeddingService.generateEmbedding(for: recipe),
               let vectorData = try? JSONEncoder().encode(vector) {

                let newEntity = RecipeEntity(
                    id: recipe.id,
                    nombre: recipe.nombre,
                    ingredientes: recipe.ingredientes,
                    pasos: recipe.pasos,
                    categoria: recipe.categoria,
                    valorNutricional: recipe.valorNutricional,
                    embeddingData: vectorData
                )
                context.insert(newEntity)
            }

            processedRecipes += 1
            if processedRecipes.isMultiple(of: 25) {
                await Task.yield()
            }
        }

        // Guardamos los cambios
        do {
            try context.save()
            print("Embeddings generados y guardados")
        } catch {
            seedMessage = "Error al guardar embeddings: \(error.localizedDescription)"
            print("Error: \(error)")
        }
    }
}

enum BDSeedError: LocalizedError {
    case recipeJSONNotFound

    var errorDescription: String? {
        switch self {
        case .recipeJSONNotFound:
            return "No se encontró recetas.json ni Recetas.json en el bundle."
        }
    }
}
