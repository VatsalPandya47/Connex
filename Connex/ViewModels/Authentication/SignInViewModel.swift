import Foundation
import Combine

class SignInViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let authService = AuthenticationService.shared
    private var cancellables = Set<AnyCancellable>()
    
    var canSubmit: Bool {
        !email.isEmpty && !password.isEmpty && !isLoading
    }
    
    func signIn() {
        isLoading = true
        
        authService.signIn(email: email, password: password)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        self?.showError = true
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
} 