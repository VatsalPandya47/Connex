import Foundation

struct User: Identifiable, Codable, Equatable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let dateOfBirth: Date
    let location: Location
    let profileImageURLs: [URL]
    let bio: String?
    let headline: String?
    let interests: [String]
    let profilePrompts: [ProfilePrompt]
    let lastActive: Date
    let createdAt: Date
    var connection: Connection?
    
    var isProfileVisible: Bool = true
    
    struct Location: Codable, Equatable {
        let latitude: Double
        let longitude: Double
        let city: String
        let country: String
    }
    
    struct ProfilePrompt: Codable, Equatable {
        let question: String
        var answer: String
    }
} 