import SwiftUI

struct SignInView: View {
    @StateObject private var viewModel = SignInViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                Text("Welcome Back")
                    .font(.title)
                    .fontWeight(.bold)
                
                // Form fields
                VStack(spacing: 16) {
                    TextField("Email", text: $viewModel.email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .textFieldStyle(.roundedBorder)
                    
                    SecureField("Password", text: $viewModel.password)
                        .textContentType(.password)
                        .textFieldStyle(.roundedBorder)
                }
                
                // Sign in button
                Button {
                    viewModel.signIn()
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                    } else {
                        Text("Sign In")
                            .fontWeight(.semibold)
                    }
                }
                .primaryButton()
                .disabled(!viewModel.canSubmit)
                
                // Forgot password
                Button("Forgot Password?") {
                    // Handle forgot password
                }
                .foregroundColor(.accentColor)
            }
            .padding()
        }
        .navigationTitle("Sign In")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }
} 