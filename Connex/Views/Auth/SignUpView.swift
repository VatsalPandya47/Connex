import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            // Progress bar
            ProgressBar(currentStep: viewModel.currentStep, totalSteps: 2)
                .padding(.top)
            
            // Step content
            switch viewModel.currentStep {
            case 0:
                credentialsView
            case 1:
                personalInfoView
            default:
                EmptyView()
            }
            
            Spacer()
            
            // Navigation buttons
            navigationButtons
        }
        .padding()
        .navigationTitle("Create Account")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    
    private var credentialsView: some View {
        VStack(spacing: 16) {
            Text("Create your account")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Enter your email and create a password")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            CustomTextField(
                text: $viewModel.email,
                placeholder: "Email",
                icon: "envelope.fill"
            )
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .autocapitalization(.none)
            
            CustomSecureField(
                text: $viewModel.password,
                placeholder: "Password",
                icon: "lock.fill"
            )
            .textContentType(.newPassword)
            
            CustomSecureField(
                text: $viewModel.confirmPassword,
                placeholder: "Confirm Password",
                icon: "lock.fill"
            )
            .textContentType(.newPassword)
        }
    }
    
    private var personalInfoView: some View {
        VStack(spacing: 16) {
            Text("Tell us about yourself")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Enter your personal information")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            CustomTextField(
                text: $viewModel.firstName,
                placeholder: "First Name",
                icon: "person.fill"
            )
            .textContentType(.givenName)
            
            CustomTextField(
                text: $viewModel.lastName,
                placeholder: "Last Name",
                icon: "person.fill"
            )
            .textContentType(.familyName)
            
            DatePicker(
                "Date of Birth",
                selection: $viewModel.dateOfBirth,
                in: ...Date(),
                displayedComponents: .date
            )
            .datePickerStyle(.compact)
        }
    }
    
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            if viewModel.currentStep > 0 {
                Button("Back") {
                    withAnimation {
                        viewModel.currentStep -= 1
                    }
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            
            Button(viewModel.currentStep == 1 ? "Create Account" : "Next") {
                if viewModel.currentStep == 1 {
                    viewModel.signUp { success in
                        if success {
                            dismiss()
                        }
                    }
                } else {
                    withAnimation {
                        viewModel.proceedToNextStep()
                    }
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(!viewModel.canProceed || viewModel.isLoading)
        }
    }
}

struct ProgressBar: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(Color(.systemGray5))
                
                Rectangle()
                    .foregroundColor(.accentColor)
                    .frame(width: progressWidth(for: geometry.size.width))
            }
            .frame(height: 4)
            .cornerRadius(2)
        }
        .frame(height: 4)
    }
    
    private func progressWidth(for totalWidth: CGFloat) -> CGFloat {
        let progress = CGFloat(currentStep + 1) / CGFloat(totalSteps)
        return totalWidth * progress
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color(.systemGray6))
            .foregroundColor(.primary)
            .cornerRadius(12)
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
} 