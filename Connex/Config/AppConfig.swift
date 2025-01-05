import Foundation

enum AppConfig {
    static let appName = "Connex"
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    enum API {
        static let baseURL = "https://api.connex.app"
        static let apiVersion = "v1"
        static let timeout: TimeInterval = 30
    }
    
    enum Cache {
        static let imageCache = 50 * 1024 * 1024 // 50MB
        static let diskCache = 100 * 1024 * 1024 // 100MB
    }
    
    enum Limits {
        static let maxPhotos = 6
        static let maxPrompts = 3
        static let minInterests = 3
        static let maxInterests = 10
        static let bioMaxLength = 500
    }
} 