import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            Text("Main Tab View")
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
} 