import Foundation

class NotificationSettingsViewModel: ObservableObject {
    @Published var newMatches = true
    @Published var messages = true
    @Published var momentLikes = true
    @Published var momentComments = true
    @Published var weeklyDigest = true
    @Published var specialOffers = false
    
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