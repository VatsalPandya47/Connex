import Foundation

struct Moment: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let type: MomentType
    let content: String
    let mediaURL: URL?
    let createdAt: Date
    var likes: Int
    var comments: [Comment]
    var isPublic: Bool
    
    enum MomentType: String, Codable {
        case text
        case image
        case video
        case story // 24-hour temporary
    }
    
    struct Comment: Identifiable, Codable {
        let id: UUID
        let userId: UUID
        let content: String
        let createdAt: Date
    }
    
    init(id: UUID = UUID(),
         userId: UUID,
         type: MomentType,
         content: String,
         mediaURL: URL? = nil,
         isPublic: Bool = true) {
        self.id = id
        self.userId = userId
        self.type = type
        self.content = content
        self.mediaURL = mediaURL
        self.createdAt = Date()
        self.likes = 0
        self.comments = []
        self.isPublic = isPublic
    }
} 