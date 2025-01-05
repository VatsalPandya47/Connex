import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
    case serverError(String)
    case unauthorized
    case noData
    case rateLimited
    case connectionError
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingError:
            return "Error decoding response"
        case .serverError(let message):
            return "Server error: \(message)"
        case .unauthorized:
            return "Unauthorized access"
        case .noData:
            return "No data received"
        case .rateLimited:
            return "Too many requests. Please try again later"
        case .connectionError:
            return "Connection error. Please check your internet connection"
        }
    }
} 