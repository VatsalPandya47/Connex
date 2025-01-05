import Foundation
import Combine

class ConnectionsViewModel: ObservableObject {
    @Published private(set) var connections: [User] = []
    @Published private(set) var pendingConnections: [User] = []
    @Published private(set) var suggestions: [User] = []
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let userManager = UserManager.shared
    private let connectionManager = ConnectionManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        loadData()
    }
    
    private func setupBindings() {
        userManager.$connections
            .assign(to: &$connections)
        
        userManager.$pendingConnections
            .assign(to: &$pendingConnections)
        
        connectionManager.$connectionSuggestions
            .assign(to: &$suggestions)
        
        userManager.$isLoading
            .assign(to: &$isLoading)
    }
    
    func loadData() {
        userManager.loadConnections()
        userManager.loadPendingConnections()
        connectionManager.loadConnectionSuggestions()
    }
    
    func acceptConnection(from user: User) {
        userManager.acceptConnection(from: user.id)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                    self?.showError = true
                }
            }, receiveValue: { _ in
                // Handle successful acceptance
            })
            .store(in: &cancellables)
    }
    
    func getMutualConnections(for user: User) {
        connectionManager.loadMutualConnections(for: user.id)
    }
} 