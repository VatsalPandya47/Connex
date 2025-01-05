import SwiftUI

struct ValidatedTextField: View {
    let title: String
    @Binding var text: String
    let validation: (String) -> ValidationResult
    
    @State private var isValid = true
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField(title, text: $text)
                .appTextFieldStyle()
                .onChange(of: text) { newValue in
                    let result = validation(newValue)
                    isValid = result.isValid
                    errorMessage = result.message ?? ""
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isValid ? Color.clear : Color.red, lineWidth: 1)
                )
            
            if !isValid {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
}

struct ValidationResult {
    let isValid: Bool
    let message: String?
    
    static let valid = ValidationResult(isValid: true, message: nil)
    static func invalid(_ message: String) -> ValidationResult {
        ValidationResult(isValid: false, message: message)
    }
} 