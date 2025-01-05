import Foundation
import Combine

class NetworkService {
    static let shared = NetworkService()
    private let baseURL = URL(string: AppConfig.API.baseURL)!
    
    private var headers: [String: String] {
        if let token = KeychainService.shared.getAuthToken() {
            return [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json"
            ]
        }
        return ["Content-Type": "application/json"]
    }
    
    func makeRequest<T: Codable>(
        endpoint: APIEndpoint,
        queryItems: [URLQueryItem]? = nil,
        body: Encodable? = nil
    ) -> AnyPublisher<T, Error> {
        var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: true)!
        components.queryItems = queryItems
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = endpoint.method
        request.allHTTPHeaderFields = headers
        
        if let body = body {
            request.httpBody = try? JSONEncoder().encode(body)
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                
                switch httpResponse.statusCode {
                case 200...299:
                    return data
                case 401:
                    throw NetworkError.unauthorized
                case 429:
                    throw NetworkError.rateLimited
                default:
                    throw NetworkError.serverError("Status code: \(httpResponse.statusCode)")
                }
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

extension NetworkService {
    enum Endpoint {
        case connections
        case createConnection
        case acceptConnection(String)
        case declineConnection(String)
        case blockUser
        case getUsers
        
        var path: String {
            switch self {
            case .connections:
                return "/connections"
            case .createConnection:
                return "/connections"
            case .acceptConnection(let id):
                return "/connections/\(id)/accept"
            case .declineConnection(let id):
                return "/connections/\(id)/decline"
            case .blockUser:
                return "/users/block"
            case .getUsers:
                return "/users/get"
            }
        }
        
        var method: HTTPMethod {
            switch self {
            case .connections:
                return .get
            case .createConnection:
                return .post
            case .acceptConnection:
                return .post
            case .declineConnection:
                return .post
            case .blockUser:
                return .post
            case .getUsers:
                return .post
            }
        }
    }
} 