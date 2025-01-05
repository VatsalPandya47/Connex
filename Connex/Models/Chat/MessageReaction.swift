import Foundation

struct MessageReaction: Codable, Equatable {
    let userId: String
    let reaction: String
    let createdAt: Date
}

extension Message {
    var reactions: [MessageReaction] = []
} 