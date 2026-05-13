import SwiftUI

private enum ContentTab: Hashable {
    case ingredientSelection
    case helloWorld
}

private enum AppRoute: Hashable {
    case login
    case signUp
    case recipeSuggestions
}

struct ContentView: View {
    @StateObject private var recetasViewModel = RecetasViewModel()
    @State private var path: [AppRoute] = []
    @State private var selectedTab: ContentTab = .ingredientSelection
    @State private var isAuthenticated = false

    var body: some View {
        NavigationStack(path: $path) {
            rootContent
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .login:
                        LoginView {
                            showMainContent()
                        }
                    case .signUp:
                        SignUpView()
                    case .recipeSuggestions:
                        RecipeSuggestionsView(viewModel: recetasViewModel)
                    }
                }
        }
    }

    @ViewBuilder
    private var rootContent: some View {
        if isAuthenticated {
            mainContent
        } else {
            WelcomeView(
                onLoginTapped: {
                    path.append(.login)
                },
                onSignUpTapped: {
                    path.append(.signUp)
                }
            )
        }
    }

    private var mainContent: some View {
        Group {
            TabView(selection: $selectedTab) {
                IngredientSelectionView(viewModel: recetasViewModel) {
                    path.append(.recipeSuggestions)
                }
                .tabItem {
                    Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                    Text("Generar")
                }
                .tag(ContentTab.ingredientSelection)

                HelloWorldView()
                    .tabItem {
                        Image(systemName: "rectangle.stack")
                        Text("Guardadas")
                    }
                    .tag(ContentTab.helloWorld)
            }
            .toolbarBackground(Color.accent, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .toolbar(.visible, for: .navigationBar)
            .navigationBarBackButtonHidden(true)
        }
    }

    private func showMainContent() {
        path.removeAll()
        isAuthenticated = true
    }
}

#Preview {
    ContentView()
}
