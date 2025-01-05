import Foundation
import Combine

class SignUpViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var dateOfBirth = Date()
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let authService = AuthenticationService.shared
    private var cancellables = Set<AnyCancellable>()
    
    var canSubmit: Bool {
        !email.isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty &&
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        password == confirmPassword &&
        !isLoading
    }
    
    func signUp() {
        guard canSubmit else { return }
        isLoading = true
        
        let details = SignUpDetails(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName,
            dateOfBirth: dateOfBirth
        )
        
        authService.signUp(with: details)
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
    
    func validateInput() -> Bool {
        guard email.contains("@") else {
            errorMessage = "Please enter a valid email address"
            showError = true
            return false
        }
        
        guard password.count >= 8 else {
            errorMessage = "Password must be at least 8 characters"
            showError = true
            return false
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            showError = true
            return false
        }
        
        guard !firstName.isEmpty && !lastName.isEmpty else {
            errorMessage = "Please enter your full name"
            showError = true
            return false
        }
        
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
        guard let age = ageComponents.year, age >= 18 else {
            errorMessage = "You must be at least 18 years old"
            showError = true
            return false
        }
        
        return true
    }
} 