import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Form fields
                    VStack(spacing: 16) {
                        ValidatedTextField(
                            title: "First Name",
                            text: $viewModel.firstName,
                            validation: Validation.name
                        )
                        
                        ValidatedTextField(
                            title: "Last Name",
                            text: $viewModel.lastName,
                            validation: Validation.name
                        )
                        
                        ValidatedTextField(
                            title: "Email",
                            text: $viewModel.email,
                            validation: Validation.email
                        )
                        
                        SecureInputField(
                            title: "Password",
                            text: $viewModel.password,
                            validation: Validation.password,
                            showRequirements: true
                        )
                        
                        SecureInputField(
                            title: "Confirm Password",
                            text: $viewModel.confirmPassword,
                            validation: { password in
                                password == viewModel.password ? .valid : .invalid("Passwords do not match")
                            },
                            showRequirements: false
                        )
                        
                        DatePicker(
                            "Date of Birth",
                            selection: $viewModel.dateOfBirth,
                            in: ...Date(),
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                    }
                    
                    // Sign up button
                    Button {
                        if viewModel.validateInput() {
                            viewModel.signUp()
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.white)
                        } else {
                            Text("Create Account")
                                .fontWeight(.semibold)
                        }
                    }
                    .primaryButton()
                    .disabled(!viewModel.canSubmit)
                    
                    // Terms and conditions
                    Text("By creating an account, you agree to our Terms of Service and Privacy Policy")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
            .navigationTitle("Create Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
} 