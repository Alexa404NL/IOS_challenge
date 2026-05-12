//
//  Ingredientes.swift
//  Cardamomo
//
//  Created by Alexa Lara on 10/05/26.
//

import Foundation
import FirebaseFirestore

class IngredientesRecetas {
    static let shared = IngredientesRecetas()
    private let database = Firestore.firestore()
    private init() {}
    // guardar o actualizar
    func saveIngredient(_ ingrediente: Ingrediente) throws {
            let collection = database.collection("ingredients")
            if let id = ingrediente.id {
                try collection.document(id).setData(from: ingrediente, merge: true)
            } else {
                try collection.addDocument(from: ingrediente)
            }
    }
    func fetchIngredients(for userId: String) async throws -> [Ingrediente] {
            let query = database.collection("ingredients").whereFilter(Filter.orFilter([
                Filter.whereField("isGlobal", isEqualTo: true),
                Filter.whereField("ownerId", isEqualTo: userId)
            ]))
            let snapshot = try await query.getDocuments()
            return snapshot.documents.compactMap { try? $0.data(as: Ingrediente.self) }
    }
    func saveRecipe(_ receta: Receta) throws -> String {
            let docRef = database.collection("recipes").document()
            var newReceta = receta
            newReceta.id = docRef.documentID
            try docRef.setData(from: newReceta)
            return docRef.documentID
        }
    func saveRecipeForUser(userId: String, recipeId: String) throws {
            let savedRef = database.collection("users")
                .document(userId)
                .collection("saved_recipes")
                .document(recipeId) // id doc = id de la receta
            let savedData = RecetaGuardada(savedAt: Date())
            try savedRef.setData(from: savedData)
    }
    func fetchSavedRecipes(for userId: String) async throws -> [Receta] {
            let savedRefQuery = database.collection("users").document(userId).collection("saved_recipes")
            let snapshot = try await savedRefQuery.order(by: "savedAt", descending: true).getDocuments()
            let savedRefs = snapshot.documents.compactMap { try? $0.data(as: RecetaGuardada.self) }
            guard !savedRefs.isEmpty else { return [] }
            var fullRecipes: [Receta] = []
            for ref in savedRefs {
                guard let recipeId = ref.id else { continue }
                let recipeDoc = try await database.collection("recipes").document(recipeId).getDocument()
                if let recipe = try? recipeDoc.data(as: Receta.self) {
                    fullRecipes.append(recipe)
                }
            }
            return fullRecipes
        }
}
