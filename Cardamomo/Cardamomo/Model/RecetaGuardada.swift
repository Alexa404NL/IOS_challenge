//
//  RecetaGuardada.swift
//  Cardamomo
//
//  Created by Alexa Lara on 10/05/26.
//

import Foundation
import FirebaseFirestore

struct RecetaGuardada: Codable, Identifiable {
    @DocumentID var id: String?
    var savedAt: Date
}
