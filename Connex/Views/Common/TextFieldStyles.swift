import SwiftUI

struct AppTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
    }
}

extension View {
    func appTextFieldStyle() -> some View {
        self.textFieldStyle(AppTextFieldStyle())
    }
} 