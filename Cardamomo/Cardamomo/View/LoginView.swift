//
//  SignUpView.swift
//  Cardamomo
//
//  Created by Alexa Lara on 10/05/26.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AuthViewModel()
    @State private var showContentView = false

    var body: some View {
        ZStack {
            Color.light.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.left")
                    }
                    .foregroundStyle(.black)
                    Spacer()
                }
                .padding(.horizontal)
                VStack(alignment: .leading, spacing: 10) {
                    Text("Inicio de sesión")
                        .font(.largeTitle)
                        .bold()
                }
                .padding(.horizontal)
                .padding(20)
                VStack {
                    Image("Cooked")
                        .resizable()
                        .scaledToFit()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 400, height: 300)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 12)

                // forms
                VStack(alignment: .leading, spacing: 20) {
                    VStack {
                        TextField("Correo", text: $viewModel.email)
                            .padding()
                            .background(Color(.light))
                            .cornerRadius(25)
                        SecureField("Contraseña", text: $viewModel.password)
                            .padding()
                            .background(Color(.light))
                            .cornerRadius(25)
                    }
                    .padding(20)

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                    }

                    Text("Forgot Password?")
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding()
                    Button("Ingresar") {
                        viewModel.iniciarSesion {
                            showContentView = true
                        }
                    }
                    .disabled(viewModel.isLoading)
                    .buttonStyle(Boton(backgroundColor: .contrastDark, textColor: .light))
                    Divider().padding(.vertical)
                    Spacer(minLength: 0)
                }
                .padding(20)
                .background {
                    UnevenRoundedRectangle(
                        cornerRadii: RectangleCornerRadii(
                            topLeading: 40,
                            bottomLeading: 0,
                            bottomTrailing: 0,
                            topTrailing: 40
                        ),
                        style: .continuous
                    )
                    .fill(Color.accent)
                    .ignoresSafeArea(edges: .bottom)
                }
            }
        }
        .navigationDestination(isPresented: $showContentView) {
            ContentView()
                .navigationBarBackButtonHidden(true)
        }
    }
}
#Preview {
    LoginView()
}
