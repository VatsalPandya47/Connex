import Foundation
import Combine

class AuthenticationService: ObservableObject {
    static let shared = AuthenticationService()
    
    @Published private(set) var currentUser: User?
    @Published private(set) var isAuthenticated = false
    
    private let networkService = NetworkService.shared
    private let tokenManager = TokenManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    var token: String? {
        tokenManager.accessToken
    }
    
    private init() {
        // Try to restore session from saved tokens
        if let token = tokenManager.accessToken {
            validateToken(token)
        }
    }
    
    func signIn(email: String, password: String) -> AnyPublisher<User, Error> {
        let credentials = SignInCredentials(email: email, password: password)
        
        return networkService.makeRequest(endpoint: .signIn, body: credentials)
            .tryMap { (response: AuthResponse) -> User in
                self.tokenManager.saveTokens(
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken
                )
                return response.user
            }
            .handleEvents(receiveOutput: { [weak self] user in
                self?.currentUser = user
                self?.isAuthenticated = true
            })
            .eraseToAnyPublisher()
    }
    
    func signUp(with details: SignUpDetails) -> AnyPublisher<User, Error> {
        networkService.makeRequest(endpoint: .signUp, body: details)
            .tryMap { (response: AuthResponse) -> User in
                self.tokenManager.saveTokens(
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken
                )
                return response.user
            }
            .handleEvents(receiveOutput: { [weak self] user in
                self?.currentUser = user
                self?.isAuthenticated = true
            })
            .eraseToAnyPublisher()
    }
    
    func signOut() {
        tokenManager.clearTokens()
        currentUser = nil
        isAuthenticated = false
    }
    
    private func validateToken(_ token: String) {
        // Fetch current user profile to validate token
        networkService.makeRequest(endpoint: .updateProfile("me"))
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure = completion {
                        self?.signOut()
                    }
                },
                receiveValue: { [weak self] (user: User) in
                    self?.currentUser = user
                    self?.isAuthenticated = true
                }
            )
            .store(in: &cancellables)
    }
    
    func changePassword(currentPassword: String, newPassword: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Implement the logic to change the password
        // This would typically involve making a network request to the backend
        // For example:
        
        let body = ["currentPassword": currentPassword, "newPassword": newPassword]
        
        NetworkService.shared.makeRequest(endpoint: .changePassword, body: body)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .finished:
                    completion(.success(()))
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
}

// MARK: - Supporting Types

struct SignInCredentials: Codable {
    let email: String
    let password: String
}

struct SignUpDetails: Codable {
    let email: String
    let password: String
    let firstName: String
    let lastName: String
    let dateOfBirth: Date
}

struct AuthResponse: Codable {
    let user: User
    let accessToken: String
    let refreshToken: String
} 