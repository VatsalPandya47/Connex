import Foundation

struct Conversation: Identifiable, Codable {
    let id: String
    let participants: [User]
    let lastMessage: Message?
    let createdAt: Date
    let updatedAt: Date
    var unreadCount: Int
    
    var otherParticipant: User? {
        guard let currentUserId = AuthenticationService.shared.currentUser?.id else { return nil }
        return participants.first { $0.id != currentUserId }
    }
}

extension Conversation {
    static var mock: Conversation {
        Conversation(
            id: UUID().uuidString,
            participants: [.mock, .mock],
            lastMessage: .mock,
            createdAt: Date(),
            updatedAt: Date(),
            unreadCount: 0
        )
    }
} 