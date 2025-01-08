import SwiftUI

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