//
//  Auth.swift
//  Cardamomo
//
//  Created by Alexa Lara on 10/05/26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthS{
    static let shared = AuthS()
    
    private let service=Auth.auth()
    private let db=Firestore.firestore()
    
    private init() {}
    
    func signUp (email:String, password: String, name: String, Bday: Date) async throws {
        let authRes = try await service.createUser(withEmail: email, password: password)
        let uuid = authRes.user.uid
        
        let user = AppUser(id: uuid, name: name, email: email, dateOfBirth: Bday, createdAt: Date())
        //!guarda en firestore
        let userRef = db.collection("users").document(uuid)
        try userRef.setData(from: user)
        
    }
}


