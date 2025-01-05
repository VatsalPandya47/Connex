import Foundation
import Combine

class PasswordChangeViewModel: ObservableObject {
    @Published var currentPassword = ""
    @Published var newPassword = ""
    @Published var confirmPassword = ""
    @Published var showSuccessAlert = false
    @Published var showErrorAlert = false
    @Published var errorMessage = ""
    
    private var cancellables = Set<AnyCancellable>()
    private let networkService = NetworkService.shared
    
    var passwordRequirementsMet: Bool {
        newPassword.count >= 8 &&
        newPassword.contains(where: \.isUppercase) &&
        newPassword.contains(where: \.isNumber) &&
        newPassword.contains(where: { !$0.isLetterOrNumber })
    }
    
    var isValid: Bool {
        !currentPassword.isEmpty &&
        !newPassword.isEmpty &&
        newPassword == confirmPassword &&
        passwordRequirementsMet &&
        newPassword != currentPassword
    }
    
    func updatePassword() {
        networkService.updatePassword(
            currentPassword: currentPassword,
            newPassword: newPassword
        )
        .sink(receiveCompletion: { [weak self] completion in
            if case .failure(let error) = completion {
                self?.errorMessage = error.localizedDescription
                self?.showErrorAlert = true
            }
        }, receiveValue: { [weak self] _ in
            self?.showSuccessAlert = true
        })
        .store(in: &cancellables)
    }
} 