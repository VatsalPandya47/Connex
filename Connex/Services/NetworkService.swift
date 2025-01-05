import Foundation
import Combine

class NetworkService {
    static let shared = NetworkService()
    private let baseURL = URL(string: "https://api.connex.app")!
    
    // Authentication headers
    private var headers: [String: String] {
        if let token = KeychainService.shared.getAuthToken() {
            return ["Authorization": "Bearer \(token)"]
        }
        return [:]
    }
    
    // MARK: - User Endpoints
    
    func fetchPotentialConnections(
        page: Int = 1,
        limit: Int = 20
    ) -> AnyPublisher<[User], Error> {
        var components = URLComponents(url: baseURL.appendingPathComponent("discover"), resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        
        return makeRequest(url: components.url!, method: "GET")
    }
    
    func updateUserProfile(_ user: User) -> AnyPublisher<User, Error> {
        let url = baseURL.appendingPathComponent("users/\(user.id)")
        return makeRequest(url: url, method: "PUT", body: user)
    }
    
    // MARK: - Moments Endpoints
    
    func createMoment(_ moment: Moment) -> AnyPublisher<Moment, Error> {
        let url = baseURL.appendingPathComponent("moments")
        return makeRequest(url: url, method: "POST", body: moment)
    }
    
    func fetchUserMoments(userId: UUID) -> AnyPublisher<[Moment], Error> {
        let url = baseURL.appendingPathComponent("users/\(userId)/moments")
        return makeRequest(url: url, method: "GET")
    }
    
    // MARK: - Helper Methods
    
    private func makeRequest<T: Codable>(
        url: URL,
        method: String,
        body: Codable? = nil
    ) -> AnyPublisher<T, Error> {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers
        
        if let body = body {
            request.httpBody = try? JSONEncoder().encode(body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
} 