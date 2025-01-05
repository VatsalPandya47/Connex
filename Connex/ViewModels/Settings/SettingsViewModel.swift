import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    @Published private(set) var settings: UserSettings
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let settingsService = SettingsService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.settings = .default
        setupBindings()
    }
    
    private func setupBindings() {
        settingsService.$settings
            .assign(to: &$settings)
    }
    
    func updateNotificationPreferences(_ preferences: UserSettings.NotificationPreferences) {
        var updatedSettings = settings
        updatedSettings.notificationPreferences = preferences
        saveSettings(updatedSettings)
    }
    
    func updatePrivacySettings(_ privacySettings: UserSettings.PrivacySettings) {
        var updatedSettings = settings
        updatedSettings.privacySettings = privacySettings
        saveSettings(updatedSettings)
    }
    
    func updateDiscoverySettings(_ discoverySettings: UserSettings.DiscoverySettings) {
        var updatedSettings = settings
        updatedSettings.discoverySettings = discoverySettings
        saveSettings(updatedSettings)
    }
    
    private func saveSettings(_ settings: UserSettings) {
        isLoading = true
        
        settingsService.updateSettings(settings)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        self?.showError = true
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
    
    func blockUser(_ userId: String) {
        settingsService.blockUser(userId)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        self?.showError = true
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
    
    func unblockUser(_ userId: String) {
        settingsService.unblockUser(userId)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        self?.showError = true
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
} 