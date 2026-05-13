import SwiftUI
import SwiftData

struct IngredientSelectionView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var viewModel: RecetasViewModel
    @StateObject private var bdViewModel = BDViewModel()
    @State private var showCreateIngredientSheet = false
    @State private var editingIngredient: Ingrediente?
    let onRecipesGenerated: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                LazyVStack(spacing: 0) {
                    topBanner
                    VStack(alignment: .leading, spacing: 24) {
                        selectedIngredients
                        feedbackBlock
                        ingredientSections
                        Color.clear.frame(height: 110)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 24)
                }
            }
            .scrollIndicators(.hidden)

            if !viewModel.selectedIngredients.isEmpty {
                Button {
                    Task {
                        await viewModel.generateRecipeSuggestions(context: modelContext)
                        if !viewModel.suggestedRecipes.isEmpty {
                            await MainActor.run {
                                onRecipesGenerated()
                            }
                        }
                    }
                } label: {
                    if viewModel.isGeneratingRecipeSuggestions {
                        ProgressView()
                            .tint(.light)
                    } else {
                        Text("Crear recetas")
                    }
                }
                .buttonStyle(Boton(backgroundColor: .contrastDark, textColor: .light))
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
                .disabled(
                    viewModel.selectedIngredients.isEmpty ||
                    viewModel.isGeneratingRecipeSuggestions ||
                    bdViewModel.isGeneratingEmbeddings
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            if bdViewModel.isGeneratingEmbeddings {
                EmbeddingLoadingView(
                    progress: bdViewModel.seedProgress,
                    processedRecipes: bdViewModel.processedRecipes,
                    totalRecipes: bdViewModel.totalRecipes,
                    message: bdViewModel.seedMessage
                )
                .transition(.opacity)
            }
        }
        .background(Color.light)
        .animation(.easeInOut(duration: 0.25), value: viewModel.selectedIngredients.isEmpty)
        .navigationTitle("Ingredientes")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.accent, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .task {
            await bdViewModel.seedDataIfNeeded(context: modelContext)
            await viewModel.loadIngredients()
        }
        .sheet(isPresented: $showCreateIngredientSheet) {
            CreateIngredientSheet(viewModel: viewModel)
        }
        .sheet(item: $editingIngredient) { ingredient in
            CreateIngredientSheet(viewModel: viewModel, ingredientToEdit: ingredient)
        }
    }
    private var topBanner: some View {
        VStack(alignment: .leading, spacing: 18) {
            header
            searchBar
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accent)
        .cornerRadius(36, corners: [.bottomLeft, .bottomRight])
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Selecciona los ingredientes que tienes")
                .font(.system(size: 34, weight: .bold, design: .rounded))
            Text("Busca por nombre o tag, selecciona varios ingredientes y genera tres ideas de receta con ese combo.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }

    private var searchBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.contrast)
                TextField("Buscar ingredientes o tags", text: $viewModel.searchText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            .padding()
            .background(Color.dark)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: Color.black.opacity(0.04), radius: 10, y: 6)

            Button {
                showCreateIngredientSheet = true
            } label: {
                Image(systemName: "plus")
                    .font(.title3.weight(.bold))
                    .frame(width: 54, height: 54)
                    .background(Color.contrast)
                    .foregroundStyle(Color.light)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
    }

    @ViewBuilder
    private var selectedIngredients: some View {
        if !viewModel.selectedIngredients.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Seleccionados")
                    .font(.headline)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(viewModel.selectedIngredients) { ingredient in
                            TagChipView(title: ingredient.name.capitalized, isSelected: true) {
                                viewModel.toggleSelection(for: ingredient)
                            }
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
    }

    @ViewBuilder
    private var feedbackBlock: some View {
        if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
                .font(.footnote)
                .foregroundStyle(.red)
                .padding(.horizontal, 2)
        } else if let seedMessage = bdViewModel.seedMessage {
            Text(seedMessage)
                .font(.footnote)
                .foregroundStyle(.red)
                .padding(.horizontal, 2)
        } else if viewModel.isLoadingIngredients && viewModel.availableIngredients.isEmpty {
            HStack(spacing: 12) {
                ProgressView()
                Text("Cargando ingredientes...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        } else if viewModel.isGeneratingRecipeSuggestions {
            HStack(spacing: 12) {
                ProgressView()
                Text("Generando recetas con tus ingredientes...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private var ingredientSections: some View {
        if viewModel.groupedIngredients.isEmpty, !viewModel.isLoadingIngredients {
            VStack(alignment: .leading, spacing: 10) {
                Text("No encontramos coincidencias")
                    .font(.headline)
                Text("Prueba otro término de búsqueda o crea un ingrediente nuevo para tu cuenta.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.dark.opacity(0.50))
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        } else {
            ForEach(viewModel.groupedIngredients) { section in
                IngredientSectionView(
                    section: section,
                    isSelected: viewModel.isSelected,
                    onToggle: viewModel.toggleSelection(for:),
                    onEdit: { editingIngredient = $0 },
                    canEdit: viewModel.canEditIngredient
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        IngredientSelectionView(viewModel: RecetasViewModel(), onRecipesGenerated: {})
    }
}
