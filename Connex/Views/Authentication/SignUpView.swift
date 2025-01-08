import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                }
                
                Section(header: Text("Account Details")) {
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $password)
                    SecureField("Confirm Password", text: $confirmPassword)
                }
                
                Section {
                    Button("Create Account") {
                        if validateForm() {
                            authViewModel.signUp(
                                email: email, 
                                password: password, 
                                firstName: firstName, 
                                lastName: lastName
                            )
                        }
                    }
                }
            }
            .navigationTitle("Sign Up")
            .alert(isPresented: Binding(
                get: { authViewModel.authState == .error },
                set: { _ in authViewModel.authState = .unauthenticated }
            )) {
                Alert(
                    title: Text("Sign Up Error"),
                    message: Text(authViewModel.authError?.localizedDescription ?? "Unknown error"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func validateForm() -> Bool {
        guard !firstName.isEmpty, !lastName.isEmpty else {
            authViewModel.authError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Please enter first and last name"])
            authViewModel.authState = .error
            return false
        }
        
        guard email.contains("@") else {
            authViewModel.authError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Please enter a valid email"])
            authViewModel.authState = .error
            return false
        }
        
        guard password.count >= 6 else {
            authViewModel.authError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Password must be at least 6 characters"])
            authViewModel.authState = .error
            return false
        }
        
        guard password == confirmPassword else {
            authViewModel.authError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Passwords do not match"])
            authViewModel.authState = .error
            return false
        }
        
        return true
    }
} 