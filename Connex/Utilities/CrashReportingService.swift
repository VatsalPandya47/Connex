import Foundation
import FirebaseCrashlytics

class CrashReportingService {
    static let shared = CrashReportingService()
    
    private init() {}
    
    func recordError(_ error: Error, reason: String? = nil) {
        let crashlytics = Crashlytics.crashlytics()
        
        // Log non-fatal error
        crashlytics.record(error: error)
        
        // Add custom keys for more context
        if let reason = reason {
            crashlytics.setCustomKey("error_context", value: reason)
        }
        
        // Log to our custom logger
        Logger.log("Crash Report: \(error.localizedDescription)", level: .critical)
    }
    
    func setUserIdentifier(_ userID: String?) {
        Crashlytics.crashlytics().setUserID(userID ?? "")
    }
    
    // Simulate a controlled crash (use carefully!)
    func forceCrash() {
        Crashlytics.crashlytics().crash()
    }
} 