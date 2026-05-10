//
//  Auth.swift
//  Cardamomo
//
//  Created by Alexa Lara on 10/05/26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthS {
    static let shared = AuthS()
    private let service = Auth.auth()
    private let database = Firestore.firestore()
    private init() {}
    func signUp(email: String, password: String, name: String, bday: Date) async throws {
        let authRes = try await service.createUser(withEmail: email, password: password)
        let uuid = authRes.user.uid
        print("Usuario creado con UID: \(uuid)")
        let user = AppUser(id: uuid, name: name, email: email, dateOfBirth: bday, createdAt: Date())
        // ! guarda en firestore
        let userRef = database.collection("users").document(uuid)
        try userRef.setData(from: user)
    }

    func signIn(email: String, password: String) async throws {
        try await service.signIn(withEmail: email, password: password)
    }
}
