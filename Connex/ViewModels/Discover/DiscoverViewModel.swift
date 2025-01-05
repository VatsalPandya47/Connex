import Foundation
import Combine

class DiscoverViewModel: ObservableObject {
    @Published private(set) var suggestions: [User] = []
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var currentIndex = 0
    
    private let networkService = NetworkService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadSuggestions()
    }
    
    func loadSuggestions() {
        isLoading = true
        
        networkService.makeRequest(endpoint: .connectionSuggestions)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        self?.showError = true
                    }
                },
                receiveValue: { [weak self] (users: [User]) in
                    self?.suggestions = users
                }
            )
            .store(in: &cancellables)
    }
    
    func sendConnectionRequest(to user: User) {
        networkService.makeRequest(
            endpoint: .createConnection,
            body: ["userId": user.id]
        )
        .sink(
            receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                    self?.showError = true
                }
            },
            receiveValue: { (_: Connection) in
                // Remove user from suggestions
                self.suggestions.removeAll { $0.id == user.id }
                if self.currentIndex >= self.suggestions.count {
                    self.currentIndex = max(0, self.suggestions.count - 1)
                }
            }
        )
        .store(in: &cancellables)
    }
    
    func skipUser() {
        if currentIndex < suggestions.count - 1 {
            currentIndex += 1
        }
    }
} 