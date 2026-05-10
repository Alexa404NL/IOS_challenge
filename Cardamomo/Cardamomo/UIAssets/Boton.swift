//
//  Botones.swift
//  Cardamomo
//
//  Created by Alexa Lara on 10/05/26.
//

import Foundation
import SwiftUI

struct Boton: ButtonStyle {
    var backgroundColor: Color
    var textColor: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(backgroundColor)
            .foregroundColor(textColor)
            .cornerRadius(30)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}
