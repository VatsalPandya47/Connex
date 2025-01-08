import Foundation
import FirebaseAuth

enum ConnexError: Error {
    case authentication(message: String)
    case network(message: String)
    case validation(message: String)
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .authentication(let message):
            return "Authentication Error: \(message)"
        case .network(let message):
            return "Network Error: \(message)"
        case .validation(let message):
            return "Validation Error: \(message)"
        case .unknown:
            return "An unexpected error occurred"
        }
    }
}

class ErrorHandler {
    static func handle(_ error: Error) {
        // Log error
        print("Error occurred: \(error.localizedDescription)")
        
        // You could add additional error reporting here
        // For example, sending to a crash reporting service
    }
    
    static func mapFirebaseError(_ error: Error) -> ConnexError {
        guard let authErrorCode = AuthErrorCode(rawValue: (error as NSError).code) else {
            // Log unexpected error
            CrashReportingService.shared.recordError(error, reason: "Unmapped Firebase Error")
            return .unknown
        }
        
        switch authErrorCode {
        case .invalidEmail:
            return .validation(message: "Invalid email address")
        case .emailAlreadyInUse:
            return .authentication(message: "Email is already registered")
        case .weakPassword:
            return .validation(message: "Password is too weak")
        case .wrongPassword:
            return .authentication(message: "Incorrect password")
        case .userNotFound:
            return .authentication(message: "No account found with this email")
        case .networkError:
            return .network(message: "Network connection failed")
        default:
            // Log unexpected error
            CrashReportingService.shared.recordError(error, reason: "Unhandled Firebase Error")
            return .unknown
        }
    }
} 