import Foundation

struct Conversation: Identifiable, Codable {
    let id: UUID
    let participants: [UUID]
    var lastMessage: Message?
    var unreadCount: Int
    var isActive: Bool
    var createdAt: Date
    
    var otherUser: User // Computed property, not stored
}

struct Message: Identifiable, Codable {
    let id: UUID
    let conversationId: UUID
    let senderId: UUID
    let content: String
    let timestamp: Date
    var isRead: Bool
    let type: MessageType
    
    enum MessageType: String, Codable {
        case text
        case image
        case voice
        case location
    }
} 