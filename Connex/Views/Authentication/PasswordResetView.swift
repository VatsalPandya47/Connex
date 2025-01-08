import SwiftUI

struct PasswordResetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var resetError: Error?
    @State private var resetSuccess = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Reset Your Password")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Enter your email and we'll send you a password reset link")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .padding()
                
                if let error = resetError {
                    Text(error.localizedDescription)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Button("Send Reset Link") {
                    resetPassword()
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(email.isEmpty)
                
                Spacer()
            }
            .navigationTitle("Password Reset")
            .alert(isPresented: $resetSuccess) {
                Alert(
                    title: Text("Password Reset"),
                    message: Text("A password reset link has been sent to your email."),
                    dismissButton: .default(Text("OK")) {
                        dismiss()
                    }
                )
            }
        }
    }
    
    private func resetPassword() {
        FirebaseManager.shared.auth.sendPasswordReset(withEmail: email) { error in
            if let error = error {
                self.resetError = error
                self.resetSuccess = false
            } else {
                self.resetError = nil
                self.resetSuccess = true
            }
        }
    }
} 