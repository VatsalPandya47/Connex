import Foundation
import Combine

class EmailChangeViewModel: ObservableObject {
    @Published var currentEmail = ""
    @Published var newEmail = ""
    @Published var password = ""
    @Published var showSuccessAlert = false
    @Published var showErrorAlert = false
    @Published var errorMessage = ""
    
    private var cancellables = Set<AnyCancellable>()
    private let networkService = NetworkService.shared
    
    var isValid: Bool {
        !newEmail.isEmpty && 
        newEmail.contains("@") && 
        !password.isEmpty &&
        newEmail != currentEmail
    }
    
    init() {
        // Load current email from UserDefaults or AuthViewModel
        if let user = AuthenticationService.shared.currentUser {
            currentEmail = user.email
        }
    }
    
    func updateEmail() {
        networkService.updateEmail(newEmail: newEmail, password: password)
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