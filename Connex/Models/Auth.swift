import Foundation

struct AuthCredentials {
    let email: String
    let password: String
}

struct SignUpData {
    let email: String
    let password: String
    let firstName: String
    let lastName: String
    let dateOfBirth: Date
}

struct AuthResponse: Codable {
    let user: User
    let token: String
}

enum AuthError: Error {
    case invalidCredentials
    case networkError
    case serverError
    case emailTaken
    case invalidEmail
    case weakPassword
    case userNotFound
    case tokenExpired
} 