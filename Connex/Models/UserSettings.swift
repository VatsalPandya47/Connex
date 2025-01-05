import Foundation

struct UserSettings: Codable {
    var notificationPreferences: NotificationPreferences
    var privacySettings: PrivacySettings
    var discoverySettings: DiscoverySettings
    
    struct NotificationPreferences: Codable {
        var pushEnabled: Bool
        var connectionRequests: Bool
        var messages: Bool
        var connectionUpdates: Bool
        var emailNotifications: Bool
    }
    
    struct PrivacySettings: Codable {
        var profileVisibility: ProfileVisibility
        var onlineStatus: OnlineStatusVisibility
        var lastSeen: LastSeenVisibility
        var blockList: [String] // User IDs
        
        enum ProfileVisibility: String, Codable {
            case everyone
            case connections
            case nobody
        }
        
        enum OnlineStatusVisibility: String, Codable {
            case everyone
            case connections
            case nobody
        }
        
        enum LastSeenVisibility: String, Codable {
            case everyone
            case connections
            case nobody
        }
    }
    
    struct DiscoverySettings: Codable {
        var discoverable: Bool
        var maxDistance: Int // in kilometers
        var ageRange: ClosedRange<Int>
        var interests: [String]
    }
    
    static var `default`: UserSettings {
        UserSettings(
            notificationPreferences: NotificationPreferences(
                pushEnabled: true,
                connectionRequests: true,
                messages: true,
                connectionUpdates: true,
                emailNotifications: true
            ),
            privacySettings: PrivacySettings(
                profileVisibility: .everyone,
                onlineStatus: .everyone,
                lastSeen: .connections,
                blockList: []
            ),
            discoverySettings: DiscoverySettings(
                discoverable: true,
                maxDistance: 50,
                ageRange: 18...65,
                interests: []
            )
        )
    }
} 