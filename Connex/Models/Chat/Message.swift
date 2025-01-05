import Foundation

struct Message: Identifiable, Codable {
    let id: String
    let conversationId: String
    let senderId: String
    let content: String
    let type: MessageType
    let createdAt: Date
    var status: MessageStatus
    var reactions: [MessageReaction]
    var isDeleted: Bool
    
    enum MessageType: String, Codable {
        case text
        case image
        case audio
    }
    
    enum MessageStatus: String, Codable {
        case sending
        case sent
        case delivered
        case read
        case failed
    }
}

extension Message {
    static var mock: Message {
        Message(
            id: UUID().uuidString,
            conversationId: UUID().uuidString,
            senderId: UUID().uuidString,
            content: "Hello, how are you?",
            type: .text,
            createdAt: Date(),
            status: .sent
        )
    }
} 