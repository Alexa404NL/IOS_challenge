//
//  Receta.swift
//  Cardamomo
//
//  Created by Alexa Lara on 10/05/26.
//

import Foundation
import FirebaseFirestore

struct Receta: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var instructions: String
    var createdAt: Date
    var generatedByUserId: String
    var imageUrl: String?
    var ingredients: [Ingrediente]
    var tags: [String]
}
