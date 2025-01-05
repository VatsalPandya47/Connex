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
    @Published var currentStep = 0
    
    private let authService = AuthenticationService.shared
    private var cancellables = Set<AnyCancellable>()
    
    var canProceed: Bool {
        switch currentStep {
        case 0:
            return validateEmailPassword()
        case 1:
            return validatePersonalInfo()
        default:
            return false
        }
    }
    
    func proceedToNextStep() {
        guard canProceed else { return }
        currentStep += 1
    }
    
    func signUp(completion: @escaping (Bool) -> Void) {
        guard validateAll() else { return }
        isLoading = true
        
        let signUpData = SignUpData(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName,
            dateOfBirth: dateOfBirth
        )
        
        authService.signUp(with: signUpData)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                    self?.showError = true
                    completion(false)
                }
            }, receiveValue: { _ in
                completion(true)
            })
            .store(in: &cancellables)
    }
    
    private func validateEmailPassword() -> Bool {
        guard email.contains("@") else {
            errorMessage = "Please enter a valid email"
            showError = true
            return false
        }
        
        guard password.count >= 8 else {
            errorMessage = "Password must be at least 8 characters"
            showError = true
            return false
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords don't match"
            showError = true
            return false
        }
        
        return true
    }
    
    private func validatePersonalInfo() -> Bool {
        guard !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter your first name"
            showError = true
            return false
        }
        
        guard !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter your last name"
            showError = true
            return false
        }
        
        let calendar = Calendar.current
        let age = calendar.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
        
        guard age >= 18 else {
            errorMessage = "You must be at least 18 years old"
            showError = true
            return false
        }
        
        return true
    }
    
    private func validateAll() -> Bool {
        validateEmailPassword() && validatePersonalInfo()
    }
} 