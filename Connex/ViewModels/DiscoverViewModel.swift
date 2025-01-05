import Foundation
import Combine

class DiscoverViewModel: ObservableObject {
    @Published var potentialConnections: [User] = []
    @Published var isLoading = false
    private var currentPage = 1
    private var cancellables = Set<AnyCancellable>()
    
    private let networkService = NetworkService.shared
    
    init() {
        loadPotentialConnections()
    }
    
    func loadPotentialConnections() {
        isLoading = true
        
        networkService.fetchPotentialConnections(page: currentPage)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    print("Failed to load connections: \(error)")
                }
            }, receiveValue: { [weak self] users in
                self?.potentialConnections.append(contentsOf: users)
                self?.currentPage += 1
            })
            .store(in: &cancellables)
    }
    
    func handleLike(_ user: User) {
        // Implement like logic
        removeUser(user)
    }
    
    func handlePass(_ user: User) {
        // Implement pass logic
        removeUser(user)
    }
    
    private func removeUser(_ user: User) {
        potentialConnections.removeAll { $0.id == user.id }
        if potentialConnections.count < 5 {
            loadPotentialConnections()
        }
    }
    
    func showFilters() {
        // Implement filter sheet presentation
    }
} 