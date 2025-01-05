import Foundation

extension Date {
    func timeAgoDisplay() -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self, to: now)
        
        if let year = components.year, year > 0 {
            return year == 1 ? "1y ago" : "\(year)y ago"
        }
        
        if let month = components.month, month > 0 {
            return month == 1 ? "1mo ago" : "\(month)mo ago"
        }
        
        if let day = components.day, day > 0 {
            if day == 1 { return "Yesterday" }
            if day < 7 { return "\(day)d ago" }
            return calendar.isDate(self, equalTo: now, toGranularity: .weekOfYear) ? "This week" : "\(day)d ago"
        }
        
        if let hour = components.hour, hour > 0 {
            return hour == 1 ? "1h ago" : "\(hour)h ago"
        }
        
        if let minute = components.minute, minute > 0 {
            return minute == 1 ? "1m ago" : "\(minute)m ago"
        }
        
        return "Just now"
    }
} 