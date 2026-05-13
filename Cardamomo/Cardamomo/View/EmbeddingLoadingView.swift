import SwiftUI

struct EmbeddingLoadingView: View {
    let progress: Double
    let processedRecipes: Int
    let totalRecipes: Int
    let message: String?

    var body: some View {
        ZStack {
            Color.light
                .ignoresSafeArea()

            VStack(spacing: 22) {
                Image(systemName: "arrowtriangle.down.2.fill")
                    .symbolEffect(.bounce.up.byLayer, options: .repeat(.periodic(delay: 0.0)))
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundStyle(Color.contrast)

                VStack(spacing: 8) {
                    Text("Preparando recetas")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                    Text(message ?? "Generando embeddings semánticos...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, 24)
                }

                VStack(spacing: 10) {
                    ProgressView(value: progress)
                        .tint(Color.contrast)
                    Text("\(processedRecipes) de \(totalRecipes) recetas")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 44)
            }
        }
    }
}

#Preview {
    EmbeddingLoadingView(
        progress: 0.35,
        processedRecipes: 700,
        totalRecipes: 2000,
        message: "Vectorizando tacos dorados"
    )
}
