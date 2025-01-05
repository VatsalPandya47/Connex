import Foundation
import Combine

class DiscoverViewModel: ObservableObject {
    @Published private(set) var users: [User] = []
    @Published private(set) var currentUser: User?
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let userManager = UserManager.shared
    private let connectionManager = ConnectionManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        loadUsers()
    }
    
    private func setupBindings() {
        userManager.$discoveredUsers
            .assign(to: &$users)
        
        userManager.$isLoading
            .assign(to: &$isLoading)
        
        AuthenticationService.shared.$currentUser
            .assign(to: &$currentUser)
    }
    
    func loadUsers(refresh: Bool = false) {
        userManager.loadDiscoveredUsers(refresh: refresh)
    }
    
    func sendConnectionRequest(to user: User) {
        userManager.sendConnectionRequest(to: user.id)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                    self?.showError = true
                }
            }, receiveValue: { _ in
                // Handle successful connection request
            })
            .store(in: &cancellables)
    }
    
    func getCompatibilityScore(for user: User) -> Double {
        connectionManager.calculateCompatibilityScore(with: user)
    }
    
    func filterUsers(by interests: Set<String>? = nil, distance: Double? = nil) {
        // Implement filtering logic
    }
} 