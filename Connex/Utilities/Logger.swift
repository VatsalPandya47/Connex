import Foundation
import os.log

enum LogLevel {
    case info
    case debug
    case warning
    case error
    case critical
}

class Logger {
    private static let logger = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "Connex")
    
    static func log(_ message: String, level: LogLevel = .info, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        let logMessage = "[\(fileName):\(line)] \(function) - \(message)"
        
        switch level {
        case .info:
            os_log("%{public}@", log: logger, type: .info, logMessage)
        case .debug:
            os_log("%{public}@", log: logger, type: .debug, logMessage)
        case .warning:
            os_log("%{public}@", log: logger, type: .default, logMessage)
        case .error:
            os_log("%{public}@", log: logger, type: .error, logMessage)
        case .critical:
            os_log("%{public}@", log: logger, type: .fault, logMessage)
        }
        
        // Optional: Add additional logging mechanisms
        #if DEBUG
        print(logMessage)
        #endif
    }
} 