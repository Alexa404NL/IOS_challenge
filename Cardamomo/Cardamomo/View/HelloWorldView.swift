import SwiftUI

struct HelloWorldView: View {
    var body: some View {
        ZStack {
            Color.light.ignoresSafeArea()

            Text("Hello World")
                .font(.system(size: 34, weight: .bold, design: .rounded))
        }
        .navigationTitle("Hello World")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        HelloWorldView()
    }
}
