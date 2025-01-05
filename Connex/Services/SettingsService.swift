import Foundation
import Combine

class SettingsService: ObservableObject {
    static let shared = SettingsService()
    
    @Published private(set) var settings: UserSettings = .default
    
    private let networkService = NetworkService.shared
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        loadSettings()
    }
    
    func loadSettings() {
        networkService.makeRequest(endpoint: .settings)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] (settings: UserSettings) in
                    self?.settings = settings
                }
            )
            .store(in: &cancellables)
    }
    
    func updateSettings(_ settings: UserSettings) -> AnyPublisher<UserSettings, Error> {
        networkService.makeRequest(
            endpoint: .updateSettings,
            body: settings
        )
        .handleEvents(receiveOutput: { [weak self] settings in
            self?.settings = settings
        })
        .eraseToAnyPublisher()
    }
    
    func blockUser(_ userId: String) -> AnyPublisher<UserSettings, Error> {
        networkService.makeRequest(
            endpoint: .blockUser,
            body: ["userId": userId]
        )
        .handleEvents(receiveOutput: { [weak self] settings in
            self?.settings = settings
        })
        .eraseToAnyPublisher()
    }
    
    func unblockUser(_ userId: String) -> AnyPublisher<UserSettings, Error> {
        networkService.makeRequest(
            endpoint: .unblockUser,
            body: ["userId": userId]
        )
        .handleEvents(receiveOutput: { [weak self] settings in
            self?.settings = settings
        })
        .eraseToAnyPublisher()
    }
} 