import SwiftUI

struct AuthenticationView: View {
    @State private var showSignUp = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Logo and welcome text
                VStack(spacing: 16) {
                    Image(systemName: "network")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                    
                    Text("Welcome to Connex")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Connect with like-minded professionals")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 60)
                
                Spacer()
                
                // Authentication buttons
                VStack(spacing: 16) {
                    Button {
                        showSignUp = true
                    } label: {
                        Text("Create Account")
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    
                    NavigationLink {
                        SignInView()
                    } label: {
                        Text("Sign In")
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
                .padding(.bottom, 32)
            }
            .padding()
            .sheet(isPresented: $showSignUp) {
                SignUpView()
            }
        }
    }
}

// Placeholder button styles (you'll want to define these)
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.2))
            .foregroundColor(.primary)
            .cornerRadius(10)
    }
} 