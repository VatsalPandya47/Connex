import SwiftUI

struct ChangePasswordView: View {
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false // Loading state
    
    var body: some View {
        Form {
            Section(header: Text("Change Password")) {
                SecureField("Current Password", text: $currentPassword)
                SecureField("New Password", text: $newPassword)
                SecureField("Confirm New Password", text: $confirmPassword)
            }
            
            Section {
                Button(action: {
                    changePassword()
                }) {
                    if isLoading {
                        ProgressView() // Show loading indicator
                    } else {
                        Text("Change Password")
                    }
                }
                .disabled(isLoading) // Disable button while loading
            }
        }
        .navigationTitle("Change Password")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
    
    private func changePassword() {
        // Validate the input
        guard !currentPassword.isEmpty, !newPassword.isEmpty, newPassword == confirmPassword else {
            alertMessage = "Please ensure all fields are filled out correctly."
            showAlert = true
            return
        }
        
        isLoading = true // Start loading
        
        // Call the service to change the password
        AuthenticationService.shared.changePassword(currentPassword: currentPassword, newPassword: newPassword) { result in
            isLoading = false // Stop loading
            switch result {
            case .success:
                alertMessage = "Password changed successfully."
                showAlert = true
                // Optionally, dismiss the view or navigate back
            case .failure(let error):
                alertMessage = error.localizedDescription
                showAlert = true
            }
        }
    }
} 