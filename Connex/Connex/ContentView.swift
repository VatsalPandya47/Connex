//
//  ContentView.swift
//  Connex
//
//  Created by Vatsal Pandya on 1/5/25.
//

import SwiftUI
import Combine
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

// Ensure Firebase is configured in your App or AppDelegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

// If using SwiftUI App lifecycle
@main
struct ConnexApp: App {
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// Define AuthViewModel directly in the file
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var authError: Error?
    
    // Define a basic User struct if not already defined
    struct User: Identifiable {
        let id: String
        var firstName: String?
        var lastName: String?
        var email: String?
        var profileImageURL: String?
        var bio: String?
        var interests: [String]?
        var prompts: [String]?
    }
    
    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
            if let error = error {
                self?.authError = error
                self?.isAuthenticated = false
                return
            }
            
            guard let user = result?.user else {
                self?.isAuthenticated = false
                return
            }
            
            // Fetch additional user data from Firestore
            self?.fetchUserData(uid: user.uid)
        }
    }
    
    func signUp(email: String, password: String, firstName: String, lastName: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (result, error) in
            if let error = error {
                self?.authError = error
                return
            }
            
            guard let user = result?.user else { return }
            
            // Save additional user info to Firestore
            let userData: [String: Any] = [
                "uid": user.uid,
                "email": email,
                "firstName": firstName,
                "lastName": lastName
            ]
            
            Firestore.firestore().collection("users").document(user.uid).setData(userData) { error in
                if let error = error {
                    print("Error saving user data: \(error)")
                }
            }
        }
    }
    
    private func fetchUserData(uid: String) {
        Firestore.firestore().collection("users").document(uid).getDocument { [weak self] (snapshot, error) in
            guard let data = snapshot?.data() else { return }
            
            self?.currentUser = User(
                id: uid,
                firstName: data["firstName"] as? String,
                lastName: data["lastName"] as? String,
                email: data["email"] as? String,
                profileImageURL: data["profileImageURL"] as? String,
                bio: data["bio"] as? String,
                interests: data["interests"] as? [String],
                prompts: data["prompts"] as? [String]
            )
            
            self?.isAuthenticated = true
        }
    }
    
    func completeProfileCreation(user: User) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let userData: [String: Any] = [
            "firstName": user.firstName ?? "",
            "lastName": user.lastName ?? "",
            "bio": user.bio ?? "",
            "interests": user.interests ?? [],
            "prompts": user.prompts ?? []
        ]
        
        Firestore.firestore().collection("users").document(currentUser.uid).updateData(userData) { error in
            if let error = error {
                print("Error updating profile: \(error)")
            } else {
                self.currentUser = user
            }
        }
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
                if authViewModel.currentUser?.bio == nil {
                    ProfileCreationWizardView()
                } else {
                    MainTabView()
                }
            } else {
                AuthenticationView()
            }
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

struct ProfileCreationWizardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var currentStep = 0
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Complete Your Profile")
                    .font(.title)
                
                Stepper("Profile Creation Step: \(currentStep)", value: $currentStep, in: 0...3)
                
                switch currentStep {
                case 0:
                    BasicInfoView()
                case 1:
                    ProfilePhotoView()
                case 2:
                    InterestsView()
                case 3:
                    PromptsView()
                default:
                    Text("Profile Complete")
                }
                
                Button("Next") {
                    if currentStep < 3 {
                        currentStep += 1
                    } else {
                        // Complete profile creation
                        authViewModel.completeProfileCreation()
                    }
                }
            }
            .navigationTitle("Create Profile")
        }
    }
}

// Placeholder subviews
struct BasicInfoView: View {
    var body: some View {
        VStack {
            Text("Basic Information")
            TextField("First Name", text: .constant(""))
            TextField("Last Name", text: .constant(""))
            TextField("Age", text: .constant(""))
        }
        .padding()
    }
}

struct ProfilePhotoView: View {
    var body: some View {
        VStack {
            Text("Upload Profile Photo")
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
            
            Button("Select Photo") {
                // Photo selection logic
            }
        }
        .padding()
    }
}

struct InterestsView: View {
    var body: some View {
        VStack {
            Text("Select Your Interests")
            List {
                Text("Technology")
                Text("Business")
                Text("Arts")
                Text("Sports")
                // Add more interests
            }
        }
        .padding()
    }
}

struct PromptsView: View {
    var body: some View {
        VStack {
            Text("Answer Some Prompts")
            TextEditor(text: .constant("Tell us about yourself..."))
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
