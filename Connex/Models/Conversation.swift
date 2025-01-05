import Foundation

struct Conversation: Identifiable {
    let id: UUID
    let otherUser: User
    var lastMessage: Message?
    var unreadCount: Int
    var isActive: Bool
    
    struct Message: Identifiable {
        let id: UUID
        let senderId: UUID
        let content: String
        let timestamp: Date
        var isRead: Bool
        var type: MessageType
        
        enum MessageType: String, Codable {
            case text
            case image
            case voice
            case location
        }
    }
} 