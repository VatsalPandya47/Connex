import Foundation
import Combine

class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published private(set) var isAuthenticated = false
    
    private let authService = AuthenticationService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        authService.$currentUser
            .map { $0 != nil }
            .assign(to: &$isAuthenticated)
    }
    
    func signIn() {
        guard validateInputs() else { return }
        isLoading = true
        
        let credentials = AuthCredentials(email: email, password: password)
        authService.signIn(with: credentials)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                    self?.showError = true
                }
            }, receiveValue: { _ in
                // Successfully signed in
            })
            .store(in: &cancellables)
    }
    
    private func validateInputs() -> Bool {
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter your email"
            showError = true
            return false
        }
        
        guard !password.isEmpty else {
            errorMessage = "Please enter your password"
            showError = true
            return false
        }
        
        return true
    }
} 