import Foundation

struct User: Identifiable, Codable {
    let id: String
    var firstName: String
    var lastName: String
    var email: String
    var profileImageURL: String?
    var bio: String?
    var age: Int?
    var location: Location?
    var interests: [String]
    var prompts: [Prompt]
    
    struct Location: Codable {
        let latitude: Double
        let longitude: Double
        let city: String
        let country: String
    }
    
    struct Prompt: Codable, Identifiable {
        let id: UUID
        let question: String
        let answer: String
        let imageURL: String?
    }
} 