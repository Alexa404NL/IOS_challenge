//
//  AuthViewModel.swift
//  Cardamomo
//
//  Created by Alexa Lara on 10/05/26.
//

import Foundation
import Combine
//import UIKit

@MainActor
class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var name = ""
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    func registrarUsuario() {
        isLoading = true
        Task {
            do {
                try await AuthS.shared.signUp(
                    email: email,
                    password: password,
                    name: name,
                    Bday: Date()
                )
                isLoading = false
// !                UIView.transition(from: SignUpView(), to: ContentView(), duration: 0.5, options: .transitionCrossDissolve)
            } catch {
                self.errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}
