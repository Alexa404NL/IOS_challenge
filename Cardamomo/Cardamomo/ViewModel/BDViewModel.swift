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
    private let embeddingService = EmbeddingService()
    // inicializado (seed function)
    func seedDataIfNeeded(context: ModelContext) {
        // verificar si ya hay datos
        let fetchDescriptor = FetchDescriptor<RecipeEntity>()
        let count = (try? context.fetchCount(fetchDescriptor)) ?? 0
        if count > 0 {
            print("!!!!!!!!!!! La base de datos ya tiene \(count) recetas")
            return
        }
        print("BD VACIAA. Generando embeddings")
        loadAndEmbedJSON(context: context)
    }
    private func loadAndEmbedJSON(context: ModelContext) {
        guard let url = Bundle.main.url(forResource: "Recetas", withExtension: "json") else {
            let jsonFiles = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) ?? []
            let jsonNames = jsonFiles.map { $0.lastPathComponent }.sorted().joined(separator: ", ")
            print("Recetas.json no esta en el bundle. Bundle: \(Bundle.main.bundleURL.path)")
            print("JSON disponibles en bundle: [\(jsonNames)]")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let recipes = try JSONDecoder().decode([ModelosJson].self, from: data)

            for recipe in recipes {
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
            }
        } catch {
            print("Error cargando Recetas.json: \(error.localizedDescription)")
            return
        }

        // Guardamos los cambios
        do {
            try context.save()
            print("Embeddings generados y guardados")
        } catch {
            print("Error: \(error)")
        }
    }
}
