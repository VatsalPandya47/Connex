import Foundation

extension Error {
    func fullDescription() -> String {
        var description = "Error Details:\n"
        description += "Message: \(localizedDescription)\n"
        
        // Add more detailed error information
        if let nsError = self as NSError {
            description += "Domain: \(nsError.domain)\n"
            description += "Code: \(nsError.code)\n"
            
            if let underlyingError = nsError.userInfo[NSUnderlyingErrorKey] as? Error {
                description += "Underlying Error: \(underlyingError.localizedDescription)\n"
            }
        }
        
        return description
    }
    
    func report(context: String? = nil, severity: LogLevel = .error) {
        // Log to multiple services
        Logger.log(fullDescription(), level: severity)
        AnalyticsService.shared.logError(self, context: context)
        CrashReportingService.shared.recordError(self, reason: context)
    }
} 