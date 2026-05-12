import SwiftUI

struct RecipeSuggestionsView: View {
    @ObservedObject var viewModel: RecetasViewModel
    @State private var currentPage = 0
    @State private var savedCards: Set<UUID> = []

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 18) {
                Text("Tus 3 recetas")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                Text("Desliza horizontalmente para comparar propuestas hechas con tus ingredientes seleccionados.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                TabView(selection: $currentPage) {
                    ForEach(Array(viewModel.suggestedRecipes.enumerated()), id: \.element.id) { index, card in
                        RecipeSuggestionCardView(
                            card: card,
                            isSaved: savedCards.contains(card.id)
                        ) {
                            if viewModel.userLikedGeneratedRecipe(card.receta) {
                                savedCards.insert(card.id)
                            }
                        }
                        .tag(index)
                        .padding(.bottom, 28)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .animation(.spring(response: 0.45, dampingFraction: 0.85), value: currentPage)
            }
            .padding(20)
            .background(Color.light)
        }
        .navigationTitle("Crear recetas")
        .navigationBarTitleDisplayMode(.inline)
    }
}
