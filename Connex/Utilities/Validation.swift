import Foundation

enum Validation {
    static func email(_ email: String) -> ValidationResult {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        if email.isEmpty {
            return .invalid("Email is required")
        }
        
        if !emailPredicate.evaluate(with: email) {
            return .invalid("Please enter a valid email address")
        }
        
        return .valid
    }
    
    static func password(_ password: String) -> ValidationResult {
        if password.isEmpty {
            return .invalid("Password is required")
        }
        
        if password.count < 8 {
            return .invalid("Password must be at least 8 characters")
        }
        
        let hasUppercase = password.contains(where: { $0.isUppercase })
        let hasNumber = password.contains(where: { $0.isNumber })
        
        if !hasUppercase || !hasNumber {
            return .invalid("Password must contain at least one uppercase letter and one number")
        }
        
        return .valid
    }
    
    static func name(_ name: String) -> ValidationResult {
        if name.isEmpty {
            return .invalid("Name is required")
        }
        
        if name.count < 2 {
            return .invalid("Name must be at least 2 characters")
        }
        
        let nameRegex = "^[a-zA-Z]+(([',. -][a-zA-Z ])?[a-zA-Z]*)*$"
        let namePredicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        
        if !namePredicate.evaluate(with: name) {
            return .invalid("Please enter a valid name")
        }
        
        return .valid
    }
    
    static func age(dateOfBirth: Date) -> ValidationResult {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
        
        guard let age = ageComponents.year else {
            return .invalid("Invalid date")
        }
        
        if age < 18 {
            return .invalid("You must be at least 18 years old")
        }
        
        if age > 120 {
            return .invalid("Please enter a valid date of birth")
        }
        
        return .valid
    }
} 