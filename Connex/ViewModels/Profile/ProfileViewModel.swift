import Foundation
import Combine

class ProfileViewModel: ObservableObject {
    @Published private(set) var user: User
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let networkService = NetworkService.shared
    private let authService = AuthenticationService.shared
    private var cancellables = Set<AnyCancellable>()
    
    var isCurrentUser: Bool {
        authService.currentUser?.id == user.id
    }
    
    init(user: User) {
        self.user = user
        setupBindings()
    }
    
    private func setupBindings() {
        // Listen for user updates if this is the current user
        if isCurrentUser {
            authService.$currentUser
                .compactMap { $0 }
                .assign(to: &$user)
        }
    }
    
    func refreshProfile() {
        isLoading = true
        
        networkService.makeRequest(endpoint: .updateProfile(user.id))
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        self?.showError = true
                    }
                },
                receiveValue: { [weak self] (user: User) in
                    self?.user = user
                }
            )
            .store(in: &cancellables)
    }
} 