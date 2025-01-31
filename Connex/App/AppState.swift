import Foundation

class AppState: ObservableObject {
    @Published var showingError = false
    @Published var errorMessage = ""
} 