import Foundation
import Combine

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let authService = AuthenticationService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        authService.$isAuthenticated
            .assign(to: &$isAuthenticated)
        
        authService.$currentUser
            .assign(to: &$currentUser)
    }
    
    func signOut() {
        authService.signOut()
    }
    
    func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
    }
} 