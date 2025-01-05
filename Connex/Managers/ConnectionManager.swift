import Foundation
import Combine

class ConnectionManager: ObservableObject {
    static let shared = ConnectionManager()
    
    @Published private(set) var connections: [Connection] = []
    
    private let networkService = NetworkService.shared
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupBindings()
    }
    
    private func setupBindings() {
        // Listen for real-time connection updates
        NetworkService.shared.connectionUpdates
            .sink { [weak self] connection in
                self?.handleConnectionUpdate(connection)
            }
            .store(in: &cancellables)
    }
    
    func loadConnections() {
        networkService.makeRequest(endpoint: .connections)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error loading connections: \(error)")
                }
            }, receiveValue: { [weak self] (connections: [Connection]) in
                self?.connections = connections
            })
            .store(in: &cancellables)
    }
    
    func sendConnectionRequest(to user: User) -> AnyPublisher<Connection, Error> {
        networkService.makeRequest(
            endpoint: .createConnection,
            body: ["userId": user.id]
        )
    }
    
    func acceptConnection(_ connection: Connection) -> AnyPublisher<Connection, Error> {
        networkService.makeRequest(
            endpoint: .updateConnection(connection.id),
            body: ["status": Connection.Status.connected.rawValue]
        )
    }
    
    func declineConnection(_ connection: Connection) -> AnyPublisher<Connection, Error> {
        networkService.makeRequest(
            endpoint: .updateConnection(connection.id),
            body: ["status": Connection.Status.declined.rawValue]
        )
    }
    
    private func handleConnectionUpdate(_ connection: Connection) {
        if let index = connections.firstIndex(where: { $0.id == connection.id }) {
            connections[index] = connection
        } else {
            connections.append(connection)
        }
    }
} 