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
    var body: some View {
        Text("Authentication View")
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
