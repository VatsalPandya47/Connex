import Foundation
import Combine

class UserManager: ObservableObject {
    static let shared = UserManager()
    private let networkService = NetworkService.shared
    private var cancellables = Set<AnyCancellable>()
    
    @Published private(set) var discoveredUsers: [User] = []
    @Published private(set) var connections: [User] = []
    @Published private(set) var pendingConnections: [User] = []
    @Published var isLoading = false
    
    // Pagination
    private var currentPage = 1
    private let pageSize = 20
    private var hasMorePages = true
    
    func loadDiscoveredUsers(refresh: Bool = false) {
        if refresh {
            currentPage = 1
            hasMorePages = true
            discoveredUsers.removeAll()
        }
        
        guard hasMorePages else { return }
        isLoading = true
        
        networkService.makeRequest(
            endpoint: .discover(page: currentPage, limit: pageSize)
        )
        .sink(receiveCompletion: { [weak self] completion in
            self?.isLoading = false
            if case .failure(let error) = completion {
                print("Failed to load users: \(error)")
            }
        }, receiveValue: { [weak self] (users: [User]) in
            guard let self = self else { return }
            self.discoveredUsers.append(contentsOf: users)
            self.hasMorePages = users.count == self.pageSize
            self.currentPage += 1
        })
        .store(in: &cancellables)
    }
    
    func sendConnectionRequest(to userId: UUID) -> AnyPublisher<Void, Error> {
        networkService.makeRequest(
            endpoint: .sendConnectionRequest(userId: userId)
        )
    }
    
    func acceptConnection(from userId: UUID) -> AnyPublisher<Void, Error> {
        networkService.makeRequest(
            endpoint: .acceptConnection(userId: userId)
        )
        .handleEvents(receiveOutput: { [weak self] _ in
            self?.loadPendingConnections()
        })
        .eraseToAnyPublisher()
    }
    
    func loadConnections() {
        networkService.makeRequest(endpoint: .connections)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Failed to load connections: \(error)")
                }
            }, receiveValue: { [weak self] (users: [User]) in
                self?.connections = users
            })
            .store(in: &cancellables)
    }
    
    func loadPendingConnections() {
        networkService.makeRequest(endpoint: .pendingConnections)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Failed to load pending connections: \(error)")
                }
            }, receiveValue: { [weak self] (users: [User]) in
                self?.pendingConnections = users
            })
            .store(in: &cancellables)
    }
    
    func updateUserProfile(_ user: User) -> AnyPublisher<User, Error> {
        networkService.makeRequest(
            endpoint: .updateProfile(user.id),
            body: user
        )
    }
} 