import Foundation
import UIKit

extension Ingrediente {
    var normalizedTags: [String] {
        tags
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { !$0.isEmpty }
    }

    var primaryTag: String {
        normalizedTags.first ?? "sin categoría"
    }

    var sectionTitle: String {
        primaryTag.capitalized
    }

    var symbolName: String {
        let tag = primaryTag
        let name = name.lowercased()

        if tag.contains("verd") || name.contains("lech") || name.contains("espin") || name.contains("zanah") {
            return "leaf"
        }
        if tag.contains("frut") || name.contains("manzana") || name.contains("fresa")
            || name.contains("plát") || name.contains("plat") {
            return "basket.fill"
        }
        if tag.contains("lact") || name.contains("queso") || name.contains("leche") || name.contains("yog") {
            return "drop.fill"
        }
        if tag.contains("carne") || tag.contains("prote") || name.contains("pollo") || name.contains("carne") {
            return "flame.fill"
        }
        if tag.contains("sal") || tag.contains("cond") || name.contains("sal") || name.contains("pim") {
            return "sparkles"
        }
        if tag.contains("dul") || name.contains("choco") || name.contains("miel") {
            return "birthday.cake.fill"
        }
        return "fork.knife"
    }

    var uiImage: UIImage? {
        guard let imageData else { return nil }
        return UIImage(data: imageData)
    }
}
