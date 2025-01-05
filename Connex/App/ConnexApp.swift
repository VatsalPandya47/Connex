import SwiftUI

@main
struct ConnexApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(appState)
                .preferredColorScheme(appState.colorScheme)
        }
    }
}

class AppState: ObservableObject {
    @Published var colorScheme: ColorScheme? = nil
    @Published var isOnboarding = false
    @Published var showingError = false
    @Published var errorMessage = ""
    
    func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
} 