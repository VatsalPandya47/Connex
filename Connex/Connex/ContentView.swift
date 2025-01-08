//
//  ContentView.swift
//  Connex
//
//  Created by Vatsal Pandya on 1/5/25.
//

import SwiftUI
import Combine

// Define AuthViewModel directly in the file
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    
    func checkAuthenticationStatus() {
        // Placeholder authentication logic
        isAuthenticated = false
    }
}

// Define AppState directly in the file
class AppState: ObservableObject {
    @Published var colorScheme: ColorScheme? = nil
    @Published var isOnboarding = false
    @Published var showingError = false
    @Published var errorMessage = ""
    
    func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
}

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var appState = AppState()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
            } else {
                AuthenticationView()
            }
        }
        .onAppear {
            authViewModel.checkAuthenticationStatus()
        }
        .alert(isPresented: $appState.showingError) {
            Alert(
                title: Text("Error"),
                message: Text(appState.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .environmentObject(authViewModel)
        .environmentObject(appState)
    }
}

// Include placeholder views directly in this file
struct AuthenticationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // App Logo and Title
                VStack(spacing: 10) {
                    Image(systemName: "network")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                    
                    Text("Connex")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Connect with Professionals")
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // Login Form
                VStack(spacing: 15) {
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding()
                
                // Login Button
                Button(action: {
                    // Implement login logic
                    print("Login attempted")
                }) {
                    Text("Sign In")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .disabled(email.isEmpty || password.isEmpty)
                
                // Divider
                HStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 1)
                    
                    Text("OR")
                        .foregroundColor(.gray)
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 1)
                }
                .padding()
                
                // Sign Up Button
                Button(action: {
                    showSignUp = true
                }) {
                    Text("Create New Account")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .sheet(isPresented: $showSignUp) {
                    SignUpView()
                }
                
                // Skip for Now Button (Demo Mode)
                Button(action: {
                    // Bypass authentication for demo
                    authViewModel.isAuthenticated = true
                }) {
                    Text("Skip for Now")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
}

// Placeholder SignUp View
struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Sign Up")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Button("Close") {
                    dismiss()
                }
            }
            .navigationBarTitle("Create Account")
        }
    }
}

struct DiscoverView: View {
    var body: some View {
        Text("Discover View")
    }
}

struct MomentsView: View {
    var body: some View {
        Text("Moments View")
    }
}

struct ChatListView: View {
    var body: some View {
        Text("Chat List View")
    }
}

struct ProfileView: View {
    var body: some View {
        Text("Profile View")
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            DiscoverView()
                .tabItem {
                    Label("Discover", systemImage: "sparkles")
                }
            
            MomentsView()
                .tabItem {
                    Label("Moments", systemImage: "rectangle.stack")
                }
            
            ChatListView()
                .tabItem {
                    Label("Chats", systemImage: "bubble.left.and.bubble.right")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
    }
}

#Preview {
    ContentView()
}
