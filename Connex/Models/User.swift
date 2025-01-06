import Foundation

struct User: Identifiable, Codable {
    let id: String
    var firstName: String
    var lastName: String
    var email: String
    var bio: String?
    var profileImageURL: String?
    var interests: [String]
    
    // Additional optional properties
    var dateOfBirth: Date?
    var location: Location?
    var headline: String?
    
    struct Location: Codable {
        let latitude: Double
        let longitude: Double
        let city: String
        let country: String
    }
} 