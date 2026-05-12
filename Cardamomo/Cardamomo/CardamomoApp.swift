//
//  CardamomoApp.swift
//  Cardamomo
//
//  Created by Alexa Lara on 09/05/26.
//

import SwiftUI
import SwiftData
import FirebaseCore

@main
struct CardamomoApp: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            WelcomeView()
        }
        .modelContainer(for: RecipeEntity.self)
    }
}
