import SwiftUI

struct SecureInputField: View {
    let title: String
    @Binding var text: String
    let validation: (String) -> ValidationResult
    let showRequirements: Bool
    
    @State private var isSecure = true
    @State private var isValid = true
    @State private var errorMessage = ""
    
    private var requirements: [(String, Bool)] {
        [
            ("At least 8 characters", text.count >= 8),
            ("Contains uppercase letter", text.contains(where: { $0.isUppercase })),
            ("Contains number", text.contains(where: { $0.isNumber }))
        ]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                if isSecure {
                    SecureField(title, text: $text)
                } else {
                    TextField(title, text: $text)
                }
                
                Button {
                    isSecure.toggle()
                } label: {
                    Image(systemName: isSecure ? "eye.slash" : "eye")
                        .foregroundColor(.secondary)
                }
            }
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
            
            if showRequirements {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(requirements, id: \.0) { requirement, isMet in
                        HStack(spacing: 4) {
                            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(isMet ? .green : .secondary)
                                .font(.caption)
                            
                            Text(requirement)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
    }
} 