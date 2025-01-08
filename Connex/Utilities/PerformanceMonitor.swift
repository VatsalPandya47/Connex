import Foundation
import FirebasePerformance

class PerformanceMonitor {
    static let shared = PerformanceMonitor()
    
    private init() {}
    
    func startTrace(_ name: String) -> Performance.Trace {
        let trace = Performance.startTrace(name: name)
        Logger.log("Started Performance Trace: \(name)", level: .debug)
        return trace
    }
    
    func measureBlock<T>(name: String, block: () throws -> T) rethrows -> T {
        let trace = startTrace(name)
        defer { trace.stop() }
        
        return try block()
    }
} 