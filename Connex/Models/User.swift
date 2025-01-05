import Foundation

struct User: Identifiable, Codable {
    let id: UUID
    var username: String
    var email: String
    var profilePrompts: [ProfilePrompt]
    var interests: [String]
    var moments: [Moment]
    var connectionPreferences: ConnectionPreferences
    
    var firstName: String
    var lastName: String
    var profileImageURLs: [URL]
    var bio: String?
    var dateOfBirth: Date
    var location: Location
    var lastActive: Date
    var isVerified: Bool
    
    struct ProfilePrompt: Codable {
        let prompt: String
        let response: String
    }
    
    struct ConnectionPreferences: Codable {
        var lookingFor: [ConnectionType]
        var maxDistance: Double
        var ageRange: ClosedRange<Int>
    }
    
    enum ConnectionType: String, Codable, CaseIterable {
        case friendship
        case mentorship
        case professionalNetworking
        case romanticPartnership
    }
    
    struct Location: Codable {
        var latitude: Double
        var longitude: Double
        var city: String?
        var country: String?
    }
    
    init(id: UUID = UUID(),
         username: String,
         email: String,
         firstName: String,
         lastName: String,
         dateOfBirth: Date,
         location: Location) {
        self.id = id
        self.username = username
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.dateOfBirth = dateOfBirth
        self.location = location
        self.profilePrompts = []
        self.interests = []
        self.moments = []
        self.profileImageURLs = []
        self.lastActive = Date()
        self.isVerified = false
        self.connectionPreferences = ConnectionPreferences(
            lookingFor: [],
            maxDistance: 50.0,
            ageRange: 18...100
        )
    }
} 