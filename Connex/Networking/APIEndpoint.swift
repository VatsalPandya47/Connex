import Foundation

enum APIEndpoint {
    case login
    case signup
    case refreshToken
    case updateProfile(UUID)
    case fetchUser(UUID)
    case discover(page: Int, limit: Int)
    case moments(userId: UUID)
    case createMoment
    case conversations
    case messages(conversationId: UUID)
    case sendMessage(conversationId: UUID)
    case connections
    case pendingConnections
    case sendConnectionRequest(userId: UUID)
    case acceptConnection(userId: UUID)
    case connectionSuggestions
    case mutualConnections(userId: UUID)
    case likeMoment(UUID)
    case commentOnMoment(UUID)
    
    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .signup:
            return "/auth/signup"
        case .refreshToken:
            return "/auth/refresh"
        case .updateProfile(let userId):
            return "/users/\(userId)"
        case .fetchUser(let userId):
            return "/users/\(userId)"
        case .discover:
            return "/discover"
        case .moments(let userId):
            return "/users/\(userId)/moments"
        case .createMoment:
            return "/moments"
        case .conversations:
            return "/conversations"
        case .messages(let conversationId):
            return "/conversations/\(conversationId)/messages"
        case .sendMessage(let conversationId):
            return "/conversations/\(conversationId)/messages"
        case .connections:
            return "/connections"
        case .pendingConnections:
            return "/connections/pending"
        case .sendConnectionRequest(let userId):
            return "/connections/request/\(userId)"
        case .acceptConnection(let userId):
            return "/connections/accept/\(userId)"
        case .connectionSuggestions:
            return "/connections/suggestions"
        case .mutualConnections(let userId):
            return "/connections/\(userId)/mutual"
        case .likeMoment(let momentId):
            return "/moments/\(momentId)/like"
        case .commentOnMoment(let momentId):
            return "/moments/\(momentId)/comment"
        }
    }
    
    var method: String {
        switch self {
        case .login, .signup, .createMoment, .sendMessage:
            return "POST"
        case .updateProfile:
            return "PUT"
        case .sendConnectionRequest, .acceptConnection:
            return "POST"
        case .likeMoment, .commentOnMoment:
            return "POST"
        default:
            return "GET"
        }
    }
} 