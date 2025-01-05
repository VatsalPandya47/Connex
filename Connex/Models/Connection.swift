import Foundation

struct Connection: Identifiable, Codable {
    let id: String
    let requesterId: String
    let recipientId: String
    let status: ConnectionStatus
    let createdAt: Date
    let updatedAt: Date
    
    enum ConnectionStatus: String, Codable {
        case pending
        case accepted
        case declined
        case blocked
    }
    
    var otherUserId: String {
        guard let currentUserId = AuthenticationService.shared.currentUser?.id else { return "" }
        return currentUserId == requesterId ? recipientId : requesterId
    }
}

extension Connection {
    static var mock: Connection {
        Connection(
            id: UUID().uuidString,
            requesterId: UUID().uuidString,
            recipientId: UUID().uuidString,
            status: .pending,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
} 