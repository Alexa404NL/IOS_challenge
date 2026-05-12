import SwiftUI

struct CreateIngredientSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: RecetasViewModel

    @State private var ingredientName = ""
    @State private var tagInput = ""
    @State private var selectedTags: [String] = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nuevo ingrediente")
                            .font(.largeTitle.bold())
                        Text("Este ingrediente podrás encontrarlo por nombre o por tags.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Nombre")
                            .font(.headline)
                        TextField("Ej. Yogurt griego", text: $ingredientName)
                            .padding()
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Etiquetas")
                            .font(.headline)
                        HStack(spacing: 12) {
                            TextField("Ej. lácteo", text: $tagInput)
                                .padding()
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                            Button("Añadir Etiqueta") {
                                addTag(tagInput)
                            }
                            .buttonStyle(Boton(backgroundColor: .contrastDark, textColor: .light))
                            .frame(width: 120)
                        }

                        if !selectedTags.isEmpty {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 10)], spacing: 10) {
                                ForEach(selectedTags, id: \.self) { tag in
                                    TagChipView(title: tag.capitalized, isSelected: true) {
                                        selectedTags.removeAll { $0 == tag }
                                    }
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Sugerencias de etiquetas")
                            .font(.headline)
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 10)], spacing: 10) {
                            ForEach(viewModel.availableTags, id: \.self) { tag in
                                TagChipView(title: tag.capitalized, isSelected: selectedTags.contains(tag)) {
                                    toggleTag(tag)
                                }
                            }
                        }
                    }

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }
                .padding(24)
            }
            .background(Color.light.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(viewModel.isSavingIngredient ? "Guardando..." : "Guardar") {
                        Task {
                            let wasSaved = await viewModel.createIngredient(
                                named: ingredientName,
                                tags: selectedTags
                            )
                            if wasSaved {
                                dismiss()
                            }
                        }
                    }
                    .disabled(
                        ingredientName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        || viewModel.isSavingIngredient
                    )
                }
            }
        }
    }

    private func addTag(_ rawTag: String) {
        let cleaned = rawTag
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        guard !cleaned.isEmpty, !selectedTags.contains(cleaned) else { return }
        selectedTags.append(cleaned)
        tagInput = ""
    }

    private func toggleTag(_ tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.removeAll { $0 == tag }
        } else {
            selectedTags.append(tag)
        }
    }
}
