import Foundation
import Combine

class ConnectionService: ObservableObject {
    static let shared = ConnectionService()
    
    @Published private(set) var connections: [Connection] = []
    @Published private(set) var pendingRequests: [Connection] = []
    
    private let networkService = NetworkService.shared
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        loadConnections()
    }
    
    func loadConnections() {
        networkService.makeRequest(endpoint: .connections)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] (connections: [Connection]) in
                    self?.connections = connections.filter { $0.status == .accepted }
                    self?.pendingRequests = connections.filter { $0.status == .pending }
                }
            )
            .store(in: &cancellables)
    }
    
    func sendConnectionRequest(to userId: String) -> AnyPublisher<Connection, Error> {
        networkService.makeRequest(
            endpoint: .createConnection,
            body: ["userId": userId]
        )
        .handleEvents(receiveOutput: { [weak self] connection in
            self?.pendingRequests.append(connection)
        })
        .eraseToAnyPublisher()
    }
    
    func acceptConnection(_ connectionId: String) -> AnyPublisher<Connection, Error> {
        networkService.makeRequest(endpoint: .acceptConnection(connectionId))
            .handleEvents(receiveOutput: { [weak self] connection in
                self?.updateConnection(connection)
            })
            .eraseToAnyPublisher()
    }
    
    func declineConnection(_ connectionId: String) -> AnyPublisher<Connection, Error> {
        networkService.makeRequest(endpoint: .declineConnection(connectionId))
            .handleEvents(receiveOutput: { [weak self] connection in
                self?.updateConnection(connection)
            })
            .eraseToAnyPublisher()
    }
    
    func blockUser(_ userId: String) -> AnyPublisher<Connection, Error> {
        networkService.makeRequest(
            endpoint: .blockUser,
            body: ["userId": userId]
        )
        .handleEvents(receiveOutput: { [weak self] connection in
            self?.updateConnection(connection)
        })
        .eraseToAnyPublisher()
    }
    
    private func updateConnection(_ connection: Connection) {
        // Remove from pending if it was there
        pendingRequests.removeAll { $0.id == connection.id }
        
        // Update or add to connections if accepted
        if connection.status == .accepted {
            if let index = connections.firstIndex(where: { $0.id == connection.id }) {
                connections[index] = connection
            } else {
                connections.append(connection)
            }
        } else {
            // Remove from connections if not accepted
            connections.removeAll { $0.id == connection.id }
        }
    }
} 