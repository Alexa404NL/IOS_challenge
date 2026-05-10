//
//  AuthViewModel.swift
//  Cardamomo
//
//  Created by Alexa Lara on 10/05/26.
//

import Foundation
import Combine
// import UIKit

@MainActor
class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var name = ""
    @Published var bday = Date()
    @Published var errorMessage: String?
    @Published var isLoading = false
    func registrarUsuario(onSuccess: @escaping () -> Void = {}) {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                try await AuthS.shared.signUp(
                    email: email,
                    password: password,
                    name: name,
                    bday: bday
                )
                isLoading = false
                onSuccess()
            } catch {
                self.errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }

    func iniciarSesion(onSuccess: @escaping () -> Void = {}) {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                try await AuthS.shared.signIn(email: email, password: password)
                isLoading = false
                onSuccess()
            } catch {
                self.errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}
