import Foundation
import Combine

class NetworkService {
    static let shared = NetworkService()
    
    private let baseURL = URL(string: "https://api.connex.com")!
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    let connectionUpdates = PassthroughSubject<Connection, Never>()
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        session = URLSession(configuration: configuration)
        
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
    }
    
    func makeRequest<T: Codable>(
        endpoint: Endpoint,
        body: Encodable? = nil
    ) -> AnyPublisher<T, Error> {
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint.path))
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authentication token if available
        if let token = AuthenticationService.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Add request body if provided
        if let body = body {
            do {
                request.httpBody = try encoder.encode(body)
            } catch {
                return Fail(error: error).eraseToAnyPublisher()
            }
        }
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw self.handleErrorResponse(data: data, statusCode: httpResponse.statusCode)
                }
                
                return data
            }
            .decode(type: T.self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private func handleErrorResponse(data: Data, statusCode: Int) -> Error {
        if let errorResponse = try? decoder.decode(ErrorResponse.self, from: data) {
            return NetworkError.serverError(message: errorResponse.message)
        }
        
        return NetworkError.httpError(statusCode: statusCode)
    }
}

// MARK: - Supporting Types

enum NetworkError: LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int)
    case serverError(message: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let statusCode):
            return "HTTP Error: \(statusCode)"
        case .serverError(let message):
            return message
        }
    }
}

struct ErrorResponse: Codable {
    let message: String
} 