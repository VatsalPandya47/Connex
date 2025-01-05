import Foundation
import Combine

class ConnectionsViewModel: ObservableObject {
    @Published private(set) var connections: [Connection] = []
    @Published private(set) var pendingRequests: [Connection] = []
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let connectionService = ConnectionService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        connectionService.$connections
            .assign(to: &$connections)
        
        connectionService.$pendingRequests
            .assign(to: &$pendingRequests)
    }
    
    func acceptConnection(_ connectionId: String) {
        connectionService.acceptConnection(connectionId)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        self?.showError = true
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
    
    func declineConnection(_ connectionId: String) {
        connectionService.declineConnection(connectionId)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        self?.showError = true
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
    
    func blockUser(_ userId: String) {
        connectionService.blockUser(userId)
            .sink(
                receiveCompletion: { [weak self] completion in
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