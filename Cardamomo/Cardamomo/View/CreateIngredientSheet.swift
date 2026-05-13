import SwiftUI
import PhotosUI
import UIKit

struct CreateIngredientSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: RecetasViewModel
    let ingredientToEdit: Ingrediente?

    @State private var ingredientName = ""
    @State private var tagInput = ""
    @State private var selectedTags: [String] = []
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var selectedImageData: Data?
    @State private var didPreload = false

    init(viewModel: RecetasViewModel, ingredientToEdit: Ingrediente? = nil) {
        self.viewModel = viewModel
        self.ingredientToEdit = ingredientToEdit
    }

    private var isEditing: Bool { ingredientToEdit != nil }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(isEditing ? "Editar ingrediente" : "Nuevo ingrediente")
                            .font(.largeTitle.bold())
                        Text("Este ingrediente podrás encontrarlo por nombre o por tags.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    section(title: "Foto") {
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            photoPickerContent
                        }
                        .buttonStyle(.plain)
                    }

                    section(title: "Nombre") {
                        Text("Nombre")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                        TextField("Ej. Yogurt griego", text: $ingredientName)
                            .padding()
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }

                    section(title: "Etiquetas") {
                        Text("Etiquetas")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
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

                    section(title: "Sugerencias de etiquetas") {
                        Text("Sugerencias de etiquetas")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
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
            .onAppear { preloadIfNeeded() }
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    await loadPhoto(from: newItem)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(viewModel.isSavingIngredient ? "Guardando..." : "Guardar") {
                        Task {
                            let wasSaved: Bool
                            if let ingredientToEdit {
                                wasSaved = await viewModel.updateIngredient(
                                    ingredientToEdit,
                                    name: ingredientName,
                                    tags: selectedTags,
                                    imageData: selectedImageData
                                )
                            } else {
                                wasSaved = await viewModel.createIngredient(
                                    named: ingredientName,
                                    tags: selectedTags,
                                    imageData: selectedImageData
                                )
                            }
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

    private var photoPickerContent: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.white)
                .frame(height: 210)
                .overlay {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(Color.contrastDark.opacity(0.35), lineWidth: 4)
                }

            if let selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 210)
                    .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            } else {
                VStack(spacing: 14) {
                    Image(systemName: "photo")
                        .font(.system(size: 54, weight: .regular))
                    Text("Subir foto")
                        .font(.headline)
                }
                .foregroundStyle(Color.contrastDark.opacity(0.72))
            }
        }
        .overlay(alignment: .bottomTrailing) {
            Image(systemName: selectedImage == nil ? "plus" : "arrow.triangle.2.circlepath")
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.light)
                .frame(width: 44, height: 44)
                .background(Color.contrastDark)
                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                .padding(14)
        }
    }

    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.contrastDark)
            content()
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.dark.opacity(0.45))
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
    }

    private func preloadIfNeeded() {
        guard !didPreload, let ingredient = ingredientToEdit else { return }
        didPreload = true
        ingredientName = ingredient.name
        selectedTags = ingredient.tags
        if let data = ingredient.imageData {
            selectedImageData = data
            selectedImage = UIImage(data: data)
        }
    }

    private func loadPhoto(from item: PhotosPickerItem?) async {
        guard let item else { return }

        do {
            guard
                let imageData = try await item.loadTransferable(type: Data.self),
                let image = UIImage(data: imageData)
            else { return }

            await MainActor.run {
                selectedImage = image
                selectedImageData = viewModel.downgradeQuality(image: image)
            }
        } catch {
            await MainActor.run {
                viewModel.errorMessage = "No pudimos cargar la foto seleccionada."
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
