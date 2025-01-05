import Foundation
import Combine

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    private var cancellables = Set<AnyCancellable>()
    
    private let authService = AuthenticationService.shared
    
    func signInWithApple() {
        authService.signInWithApple()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Sign in failed: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] user in
                self?.currentUser = user
                self?.isAuthenticated = true
            })
            .store(in: &cancellables)
    }
    
    func signOut() {
        // Implement sign out logic
        isAuthenticated = false
        currentUser = nil
    }
} 