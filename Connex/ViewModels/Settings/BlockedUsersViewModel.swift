import Foundation
import Combine

class BlockedUsersViewModel: ObservableObject {
    @Published private(set) var blockedUsers: [User] = []
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let settingsService = SettingsService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadBlockedUsers()
    }
    
    func loadBlockedUsers() {
        isLoading = true
        
        // Get blocked user IDs from settings
        let blockedIds = settingsService.settings.privacySettings.blockList
        
        // Load user details for blocked users
        UserService.shared.getUsers(ids: blockedIds)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        self?.showError = true
                    }
                },
                receiveValue: { [weak self] users in
                    self?.blockedUsers = users
                }
            )
            .store(in: &cancellables)
    }
    
    func unblockUser(_ user: User) {
        settingsService.unblockUser(user.id)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        self?.showError = true
                    }
                },
                receiveValue: { [weak self] _ in
                    self?.blockedUsers.removeAll { $0.id == user.id }
                }
            )
            .store(in: &cancellables)
    }
} 