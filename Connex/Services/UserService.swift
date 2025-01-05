import Foundation
import Combine

class UserService {
    static let shared = UserService()
    
    private let networkService = NetworkService.shared
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    func getUsers(ids: [String]) -> AnyPublisher<[User], Error> {
        let body = ["userIds": ids]
        
        return networkService.makeRequest(endpoint: .getUsers, body: body)
            .eraseToAnyPublisher()
    }
} 