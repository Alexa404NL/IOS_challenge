//
//  WelcomeView.swift
//  Cardamomo
//
//  Created by Alexa Lara on 10/05/26.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 0) {
            // Logo
            VStack {
                Spacer()
                Image("Cooked")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80)
                Text("Cardamomo")
                    .font(.system(size: 40, weight: .bold))
                Text("por Alexa L")
                    .font(.caption)
                    .tracking(4)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.light)

            // Sección Inferior (Amarilla)
            VStack(alignment: .leading, spacing: 20) {
                Text("Bienvenido")
                    .font(.largeTitle)
                    .bold()
                Text("Cardamomo es una app que busca facilitar el uso de la coina para cualquiera. Su nombre proviene de la misma especia que, por sus características, es versátil y aromática.")
                    .font(.body)
                    .opacity(0.8)
                HStack(spacing: 15) {
                    Button("Inicia sesión") { }
                        .buttonStyle(Boton(backgroundColor: .contrast, textColor: .light))
                    Button("Regístrate") { SignUpView() }
                        .buttonStyle(Boton(backgroundColor: .light, textColor: .black))
                } .padding(.top, 10)
            }
            .padding(40)
            .background(Color.accent)
            .cornerRadius(40, corners: [.topLeft, .topRight]) // Custom extension necesaria
        }
        .ignoresSafeArea()
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
    WelcomeView()
}
