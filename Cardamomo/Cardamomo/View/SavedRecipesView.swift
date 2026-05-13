import SwiftUI

struct SavedRecipesView: View {
    @ObservedObject var viewModel: RecetasViewModel
    @State private var selectedRecipe: Receta?
    @State private var recipeToDelete: Receta?
    @State private var showDeleteAlert = false

    var body: some View {
        ZStack(alignment: .top) {
            Color.light.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    topBanner
                    VStack(alignment: .leading, spacing: 16) {
                        feedbackBlock
                        recipeList
                        Color.clear.frame(height: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("Guardadas")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.accent, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .task {
            await viewModel.loadSavedRecipes()
        }
        .refreshable {
            await viewModel.loadSavedRecipes()
        }
        .sheet(item: $selectedRecipe) { recipe in
            NavigationStack {
                SavedRecipeDetailView(
                    viewModel: viewModel,
                    recipe: recipe,
                    onDeleted: { selectedRecipe = nil },
                    onDismiss: { selectedRecipe = nil }
                )
            }
        }
        .alert("Eliminar receta", isPresented: $showDeleteAlert, presenting: recipeToDelete) { recipe in
            Button("Eliminar", role: .destructive) {
                Task {
                    _ = await viewModel.deleteSavedRecipe(recipe)
                    recipeToDelete = nil
                }
            }
            Button("Cancelar", role: .cancel) { recipeToDelete = nil }
        } message: { recipe in
            Text("¿Seguro que deseas quitar \"\(recipe.name)\" de tus guardadas?")
        }
    }

    private var topBanner: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tus recetas guardadas")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(Color.black)
            Text("Toca cualquier receta para verla a detalle o eliminarla.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accent)
        .cornerRadius(36, corners: [.bottomLeft, .bottomRight])
    }

    @ViewBuilder
    private var feedbackBlock: some View {
        if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
                .font(.footnote)
                .foregroundStyle(.red)
                .padding(.horizontal, 2)
        } else if viewModel.isLoadingSavedRecipes && viewModel.savedRecipes.isEmpty {
            HStack(spacing: 12) {
                ProgressView()
                Text("Cargando recetas guardadas...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private var recipeList: some View {
        if viewModel.savedRecipes.isEmpty && !viewModel.isLoadingSavedRecipes {
            emptyState
        } else {
            LazyVStack(spacing: 14) {
                ForEach(viewModel.savedRecipes) { recipe in
                    SavedRecipeRowView(recipe: recipe)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedRecipe = recipe
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                recipeToDelete = recipe
                                showDeleteAlert = true
                            } label: {
                                Label("Eliminar", systemImage: "trash")
                            }
                        }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Aún no tienes recetas guardadas")
                .font(.headline)
            Text("Cuando guardes una receta desde el generador aparecerá en esta lista.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.dark.opacity(0.50))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}

private struct SavedRecipeRowView: View {
    let recipe: Receta

    private var summary: String {
        let trimmed = recipe.instructions.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return "Sin instrucciones registradas."
        }
        return trimmed
    }

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text(recipe.name)
                    .font(.headline)
                    .foregroundStyle(Color.black)
                    .lineLimit(2)
                Text(summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                if !recipe.tags.isEmpty {
                    Text(recipe.tags.prefix(3).map { "#\($0)" }.joined(separator: " "))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.contrast)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            ZStack {
                Circle()
                    .fill(Color.contrast.opacity(0.18))
                    .frame(width: 58, height: 58)
                Image(systemName: "fork.knife")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color.contrast)
            }
        }
        .padding(16)
        .background(Color.accent.opacity(0.45))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

struct SavedRecipeDetailView: View {
    @ObservedObject var viewModel: RecetasViewModel
    let recipe: Receta
    let onDeleted: () -> Void
    let onDismiss: () -> Void

    @State private var showDeleteAlert = false

    private var currentRecipe: Receta {
        viewModel.savedRecipes.first(where: { $0.id == recipe.id }) ?? recipe
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                headerCard
                ingredientsCard
                instructionsCard
                actionButtons
            }
            .padding(20)
        }
        .scrollIndicators(.hidden)
        .background(Color.light.ignoresSafeArea())
        .navigationTitle(currentRecipe.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundStyle(Color.contrastDark)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .foregroundStyle(Color.contrastDark)
                }
            }
        }
        .toolbarBackground(Color.accent, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .alert("Eliminar receta", isPresented: $showDeleteAlert) {
            Button("Eliminar", role: .destructive) {
                Task {
                    if await viewModel.deleteSavedRecipe(currentRecipe) {
                        onDeleted()
                    }
                }
            }
            Button("Cancelar", role: .cancel) { }
        } message: {
            Text("¿Seguro que deseas quitar \"\(currentRecipe.name)\" de tus guardadas?")
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(currentRecipe.name)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(Color.black)
            if !currentRecipe.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(currentRecipe.tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.contrast)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.contrast.opacity(0.15))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            Text("Guardada el \(currentRecipe.createdAt.formatted(date: .abbreviated, time: .omitted))")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accent.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var ingredientsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ingredientes")
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.black)
            if currentRecipe.ingredients.isEmpty {
                Text("Sin ingredientes registrados.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(currentRecipe.ingredients, id: \.name) { ingredient in
                    HStack(spacing: 10) {
                        Circle()
                            .fill(Color.contrast.opacity(0.18))
                            .frame(width: 8, height: 8)
                        Text("\(ingredient.quantity) \(ingredient.unit) · \(ingredient.name)")
                            .font(.subheadline)
                            .foregroundStyle(Color.black)
                        Spacer()
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.dark.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var instructionsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Preparación")
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.black)
            Text(currentRecipe.instructions)
                .font(.subheadline)
                .foregroundStyle(Color.black)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.dark.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var actionButtons: some View {
        Button("Eliminar") {
            showDeleteAlert = true
        }
        .buttonStyle(Boton(backgroundColor: .contrastDark, textColor: .light))
        .padding(.top, 4)
    }
}

#Preview {
    NavigationStack {
        SavedRecipesView(viewModel: RecetasViewModel())
    }
}
