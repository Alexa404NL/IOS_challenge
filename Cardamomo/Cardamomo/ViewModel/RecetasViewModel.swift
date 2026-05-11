import Foundation
import Combine
import FirebaseAuth

@MainActor
final class RecetasViewModel: ObservableObject {
    @Published var availableIngredients: [Ingrediente] = []
    @Published var searchText = ""
    @Published var errorMessage: String?
    @Published var isLoadingIngredients = false
    @Published var isSavingIngredient = false
    @Published var selectedIngredientKeys: Set<String> = []
    @Published var suggestedRecipes: [GeneratedRecipeCard] = []

    private let fallbackTags = [
        "verdura", "fruta", "lácteo", "proteína", "dulce", "salado", "grano", "picante"
    ]

    private var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }

    var selectedIngredients: [Ingrediente] {
        availableIngredients.filter { selectedIngredientKeys.contains(selectionKey(for: $0)) }
    }

    var availableTags: [String] {
        let tags = Set(fallbackTags + availableIngredients.flatMap { $0.normalizedTags })
        return tags.sorted()
    }

    var groupedIngredients: [IngredientSection] {
        let grouped = Dictionary(grouping: filteredIngredients) { $0.sectionTitle }
        return grouped
            .map { key, value in
                IngredientSection(
                    title: key,
                    ingredients: value.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
                )
            }
            .sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }

    var filteredIngredients: [Ingrediente] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return availableIngredients }

        return availableIngredients.filter { ingredient in
            ingredient.name.lowercased().contains(query)
            || ingredient.normalizedTags.contains(where: { $0.contains(query) })
        }
    }

    func loadIngredients() async {
        guard let currentUserId else {
            errorMessage = "No encontramos un usuario autenticado para cargar ingredientes."
            availableIngredients = []
            return
        }

        isLoadingIngredients = true
        errorMessage = nil
        defer { isLoadingIngredients = false }

        do {
            availableIngredients = try await IngredientesRecetas.shared
                .fetchIngredients(for: currentUserId)
                .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        } catch {
            errorMessage = "Error al cargar ingredientes: \(error.localizedDescription)"
            availableIngredients = []
        }
    }

    func toggleSelection(for ingredient: Ingrediente) {
        let key = selectionKey(for: ingredient)
        if selectedIngredientKeys.contains(key) {
            selectedIngredientKeys.remove(key)
        } else {
            selectedIngredientKeys.insert(key)
        }
    }

    func isSelected(_ ingredient: Ingrediente) -> Bool {
        selectedIngredientKeys.contains(selectionKey(for: ingredient))
    }

    func createIngredient(named name: String, tags: [String]) async -> Bool {
        guard let currentUserId else {
            errorMessage = "Necesitas iniciar sesión para crear ingredientes personales."
            return false
        }

        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanTags = Array(Set(tags.map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        }.filter { !$0.isEmpty })).sorted()

        guard !cleanName.isEmpty else {
            errorMessage = "Escribe un nombre válido para el ingrediente."
            return false
        }

        isSavingIngredient = true
        errorMessage = nil
        defer { isSavingIngredient = false }

        do {
            let ingredient = Ingrediente(
                id: nil,
                name: cleanName,
                createdAt: Date(),
                ownerId: currentUserId,
                isGlobal: false,
                tags: cleanTags
            )
            try IngredientesRecetas.shared.saveIngredient(ingredient)
            await loadIngredients()

            if let newIngredient = availableIngredients.first(where: {
                $0.name.compare(cleanName, options: .caseInsensitive) == .orderedSame
            }) {
                selectedIngredientKeys.insert(selectionKey(for: newIngredient))
            }
            return true
        } catch {
            errorMessage = "No se pudo guardar el ingrediente: \(error.localizedDescription)"
            return false
        }
    }

    func generateRecipeSuggestions() {
        let chosenIngredients = selectedIngredients

        guard !chosenIngredients.isEmpty else {
            errorMessage = "Selecciona al menos un ingrediente para crear recetas."
            suggestedRecipes = []
            return
        }

        errorMessage = nil
        let baseName = chosenIngredients.first?.name.capitalized ?? "la casa"
        let combinedTags = Array(Set(chosenIngredients.flatMap { $0.normalizedTags })).sorted()
        let userId = currentUserId ?? "preview-user"

        let recipes: [GeneratedRecipeCard] = [
            GeneratedRecipeCard(
                name: "Bowl de \(baseName)",
                subtitle: "Ligera, fresca y pensada para aprovechar lo que ya tienes.",
                heroTitle: "Fresco y balanceado",
                instructions: buildInstructions(
                    prefix: "Saltea una parte de los ingredientes y termina el bowl con elementos frescos",
                    ingredients: chosenIngredients
                ),
                featuredIngredients: Array(chosenIngredients.shuffled().prefix(6)),
                tags: combinedTags,
                generatedByUserId: userId,
                createdAt: Date()
            ),
            GeneratedRecipeCard(
                name: "Salteado cremoso de \(baseName)",
                subtitle: "Una opción reconfortante con textura suave y acabado dorado.",
                heroTitle: "Cálido y cremoso",
                instructions: buildInstructions(
                    prefix: "Lleva los ingredientes a un sartén caliente, agrega una base cremosa y cocina hasta integrar sabores",
                    ingredients: chosenIngredients
                ),
                featuredIngredients: Array(chosenIngredients.shuffled().prefix(6)),
                tags: combinedTags,
                generatedByUserId: userId,
                createdAt: Date()
            ),
            GeneratedRecipeCard(
                name: "Tacos de \(baseName)",
                subtitle: "Más atrevida, con contraste entre toppings y un cierre especiado.",
                heroTitle: "Crujiente y especiado",
                instructions: buildInstructions(
                    prefix: "Arma por capas, agrega un toque ácido y termina con los ingredientes de mayor textura",
                    ingredients: chosenIngredients
                ),
                featuredIngredients: Array(chosenIngredients.shuffled().prefix(6)),
                tags: combinedTags,
                generatedByUserId: userId,
                createdAt: Date()
            )
        ]
        suggestedRecipes = recipes
    }

    func userLikedGeneratedRecipe(_ recipe: Receta) -> Bool {
        guard let currentUserId else {
            errorMessage = "Necesitas iniciar sesión para guardar recetas."
            return false
        }

        do {
            let recipeId = try IngredientesRecetas.shared.saveRecipe(recipe)
            try IngredientesRecetas.shared.saveRecipeForUser(userId: currentUserId, recipeId: recipeId)
            return true
        } catch {
            errorMessage = "Error al guardar receta: \(error.localizedDescription)"
            return false
        }
    }

    private func selectionKey(for ingredient: Ingrediente) -> String {
        ingredient.id ?? "\(ingredient.name.lowercased())-\(ingredient.createdAt.timeIntervalSince1970)"
    }

    private func buildInstructions(prefix: String, ingredients: [Ingrediente]) -> String {
        let names = ingredients.map { $0.name }
        let ingredientList = names.joined(separator: ", ")
        return "\(prefix). Usa como base: \(ingredientList). Ajusta sal, textura y toppings al gusto para cerrar la receta con un perfil casero y flexible."
    }
}
