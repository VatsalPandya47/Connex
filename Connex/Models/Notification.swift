import Foundation

struct Notification: Identifiable, Codable {
    let id: String
    let type: NotificationType
    let userId: String
    let data: NotificationData
    let isRead: Bool
    let createdAt: Date
    
    enum NotificationType: String, Codable {
        case connectionRequest
        case connectionAccepted
        case newMessage
    }
    
    struct NotificationData: Codable {
        let title: String
        let body: String
        let imageURL: URL?
        let metadata: [String: String]
    }
} 