import SwiftUI

struct PasswordChangeView: View {
    @StateObject private var viewModel = PasswordChangeViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            Section(header: Text("Current Password")) {
                SecureField("Current Password", text: $viewModel.currentPassword)
            }
            
            Section(header: Text("New Password")) {
                SecureField("New Password", text: $viewModel.newPassword)
                SecureField("Confirm New Password", text: $viewModel.confirmPassword)
                
                if !viewModel.passwordRequirementsMet {
                    PasswordRequirementsView(password: viewModel.newPassword)
                }
            }
            
            Section {
                Button("Update Password") {
                    viewModel.updatePassword()
                }
                .disabled(!viewModel.isValid)
            }
        }
        .navigationTitle("Change Password")
        .alert("Password Updated", isPresented: $viewModel.showSuccessAlert) {
            Button("OK") { dismiss() }
        }
        .alert("Error", isPresented: $viewModel.showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

struct PasswordRequirementsView: View {
    let password: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            RequirementRow(text: "At least 8 characters", 
                         isMet: password.count >= 8)
            RequirementRow(text: "Contains uppercase letter", 
                         isMet: password.contains(where: \.isUppercase))
            RequirementRow(text: "Contains number", 
                         isMet: password.contains(where: \.isNumber))
            RequirementRow(text: "Contains special character", 
                         isMet: password.contains(where: { !$0.isLetterOrNumber }))
        }
        .font(.caption)
        .foregroundColor(.gray)
    }
}

struct RequirementRow: View {
    let text: String
    let isMet: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isMet ? .green : .gray)
            Text(text)
        }
    }
} 