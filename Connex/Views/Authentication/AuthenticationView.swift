import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var isSignUp = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Logo and Title
                VStack {
                    Image(systemName: "network")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                    
                    Text("Connex")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .padding()
                
                // Authentication Form
                VStack(spacing: 15) {
                    if isSignUp {
                        TextField("First Name", text: $firstName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Last Name", text: $lastName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding()
                
                // Submit Button
                Button(action: submitAction) {
                    Text(isSignUp ? "Sign Up" : "Sign In")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .disabled(!isFormValid)
                
                // Toggle between Sign In and Sign Up
                Button(isSignUp ? "Already have an account? Sign In" : "Create New Account") {
                    isSignUp.toggle()
                }
                .foregroundColor(.blue)
            }
            .navigationTitle(isSignUp ? "Sign Up" : "Sign In")
        }
    }
    
    private var isFormValid: Bool {
        if isSignUp {
            return !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty && !password.isEmpty
        }
        return !email.isEmpty && !password.isEmpty
    }
    
    private func submitAction() {
        if isSignUp {
            authViewModel.signUp(email: email, password: password, firstName: firstName, lastName: lastName)
        } else {
            authViewModel.signIn(email: email, password: password)
        }
    }
} 