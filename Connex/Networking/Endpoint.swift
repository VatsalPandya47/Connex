import Foundation

enum Endpoint {
    // Auth
    case signIn
    case signUp
    case refreshToken
    
    // User
    case updateProfile(String)
    case uploadImage
    
    // Connections
    case connections
    case createConnection
    case updateConnection(String)
    case connectionSuggestions
    
    // Chat
    case conversations
    case messages(String)
    case sendMessage(String)
    
    // Moments
    case moments
    case createMoment
    case likeMoment(String)
    
    var path: String {
        switch self {
        case .signIn:
            return "/auth/signin"
        case .signUp:
            return "/auth/signup"
        case .refreshToken:
            return "/auth/refresh"
            
        case .updateProfile(let userId):
            return "/users/\(userId)"
        case .uploadImage:
            return "/media/upload"
            
        case .connections:
            return "/connections"
        case .createConnection:
            return "/connections"
        case .updateConnection(let connectionId):
            return "/connections/\(connectionId)"
        case .connectionSuggestions:
            return "/connections/suggestions"
            
        case .conversations:
            return "/conversations"
        case .messages(let conversationId):
            return "/conversations/\(conversationId)/messages"
        case .sendMessage(let conversationId):
            return "/conversations/\(conversationId)/messages"
            
        case .moments:
            return "/moments"
        case .createMoment:
            return "/moments"
        case .likeMoment(let momentId):
            return "/moments/\(momentId)/like"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .signIn, .signUp, .createConnection, .sendMessage, .createMoment:
            return .post
        case .updateProfile, .updateConnection:
            return .put
        case .likeMoment:
            return .post
        default:
            return .get
        }
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
} 