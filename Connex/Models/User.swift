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
    
    var age: Int {
        Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
    }
    
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

extension User {
    static var mock: User {
        User(
            id: UUID().uuidString,
            firstName: "John",
            lastName: "Doe",
            email: "john@example.com",
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -25, to: Date())!,
            location: Location(
                latitude: 37.7749,
                longitude: -122.4194,
                city: "San Francisco",
                country: "United States"
            ),
            profileImageURLs: [
                URL(string: "https://example.com/profile1.jpg")!
            ],
            bio: "Software developer passionate about creating great user experiences",
            headline: "iOS Developer @ Tech Co",
            interests: ["Swift", "SwiftUI", "iOS Development", "Hiking", "Photography"],
            profilePrompts: [
                ProfilePrompt(
                    question: "What's your favorite way to spend a weekend?",
                    answer: "Exploring new hiking trails and taking photos"
                )
            ],
            lastActive: Date(),
            createdAt: Date()
        )
    }
} 