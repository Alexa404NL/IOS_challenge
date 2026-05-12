//
//  User.swift
//  Cardamomo
//
//  Created by Alexa Lara on 10/05/26.
//

import Foundation
import FirebaseFirestore

struct AppUser: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var email: String
    var dateOfBirth: Date
    var createdAt: Date
}
