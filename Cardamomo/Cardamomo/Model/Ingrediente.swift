//
//  Ingrediente.swift
//  Cardamomo
//
//  Created by Alexa Lara on 10/05/26.
//

import Foundation
import FirebaseFirestore

struct Ingrediente: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var createdAt: Date
    var ownerId: String?
    var isGlobal: Bool
    var tags: [String]
    var imageData: Data?
}
