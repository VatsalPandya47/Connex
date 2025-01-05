import Foundation

class PrivacySettingsViewModel: ObservableObject {
    @Published var showInDiscovery = true
    @Published var showOnlineStatus = true
    @Published var showLastActive = true
    @Published var defaultMomentsPrivacy: MomentsPrivacy = .connectionsOnly
    
    private let networkService = NetworkService.shared
    
    init() {
        loadSettings()
    }
    
    private func loadSettings() {
        // Load from UserDefaults or API
    }
    
    func updateSettings() {
        // Save to UserDefaults or API
    }
} 