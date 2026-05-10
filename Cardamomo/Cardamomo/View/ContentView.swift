//
//  ContentView.swift
//  Cardamomo
//
//  Created by Alexa Lara on 09/05/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var isActive = false
    var body: some View {
        NavigationStack {
            VStack {
                Button(action: { self.isActive = true}){
                    Text("Go to Details")
                }
                NavigationLink(destination: Text("Detail View"), isActive: $isActive){
                    EmptyView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
