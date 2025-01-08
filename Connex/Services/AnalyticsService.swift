import Foundation
import Firebase

class AnalyticsService {
    static let shared = AnalyticsService()
    
    private init() {}
    
    func logEvent(_ eventName: String, parameters: [String: Any]? = nil) {
        Analytics.logEvent(eventName, parameters: parameters)
        Logger.log("Analytics Event: \(eventName)", level: .debug)
    }
    
    func logAuthenticationAttempt(method: String, success: Bool) {
        let params: [String: Any] = [
            "method": method,
            "success": success
        ]
        
        logEvent("authentication_attempt", parameters: params)
        
        Logger.log("Auth Attempt: \(method), Success: \(success)", level: success ? .info : .warning)
    }
    
    func logError(_ error: Error, context: String? = nil) {
        let errorDescription = error.localizedDescription
        var params: [String: Any] = ["error": errorDescription]
        
        if let context = context {
            params["context"] = context
        }
        
        logEvent("error_occurred", parameters: params)
        Logger.log("Error: \(errorDescription)", level: .error)
    }
} 