import Foundation

struct Moment: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let content: String
    let mediaURL: URL?
    let timestamp: Date
    var likes: Int
    var comments: [Comment]
    var privacy: Privacy
    
    struct Comment: Identifiable, Codable {
        let id: UUID
        let userId: UUID
        let content: String
        let timestamp: Date
    }
    
    enum Privacy: String, Codable {
        case `public`
        case connectionsOnly
        case `private`
    }
} 