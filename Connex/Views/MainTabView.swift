import SwiftUI

struct MainTabView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                TabView(selection: $selectedTab) {
                    DiscoverView()
                        .tabItem {
                            Label("Discover", systemImage: "sparkles")
                        }
                        .tag(0)
                    
                    ConnectionsView()
                        .tabItem {
                            Label("Connections", systemImage: "person.2.fill")
                        }
                        .tag(1)
                    
                    ChatListView()
                        .tabItem {
                            Label("Messages", systemImage: "message.fill")
                        }
                        .tag(2)
                    
                    if let currentUser = authViewModel.currentUser {
                        ProfileView(user: currentUser)
                            .tabItem {
                                Label("Profile", systemImage: "person.fill")
                            }
                            .tag(3)
                    }
                }
            } else {
                AuthenticationView()
            }
        }
    }
}

struct AuthenticationView: View {
    @State private var showSignUp = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Logo and welcome text
                VStack(spacing: 16) {
                    Image("AppLogo")
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