//
//  SignUpView.swift
//  Cardamomo
//
//  Created by Alexa Lara on 10/05/26.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AuthViewModel()

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
                    Text("Registro").bold()
                }
                .padding(.horizontal)
                VStack(alignment: .leading, spacing: 10) {
                    Text("Regístrate")
                        .font(.largeTitle)
                        .bold()
                    Text("Favor de llenar el siguiente formulario")
                        .font(.subheadline)
                }
                .padding(.horizontal)
                .padding(20)
                VStack {
                    Image("Cooked")
                        .resizable()
                        .scaledToFit()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 12)

                // forms
                VStack(alignment: .leading, spacing: 20) {
                    VStack{
                        TextField("Nombre", text: $viewModel.name)
                            .padding()
                            .background(Color(.light))
                            .cornerRadius(25)
                        TextField("Correo", text: $viewModel.email)
                            .padding()
                            .background(Color(.light))
                            .cornerRadius(25)
                        SecureField("Contraseña", text: $viewModel.password)
                            .padding()
                            .background(Color(.light))
                            .cornerRadius(25)
                        DatePicker("Fecha de nacimiento", selection: $viewModel.bday, displayedComponents: .date)
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

                    Button("Crear cuenta") {
                        viewModel.registrarUsuario {
                            dismiss()
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
    }
}
#Preview {
    SignUpView()
}
