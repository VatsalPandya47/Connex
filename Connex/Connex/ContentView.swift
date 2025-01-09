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
import FirebaseFirestoreInternal
import FirebaseAppCheck

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
        var profileCompleted: Bool = false
    }
    
    func signIn(email: String, password: String, completion: ((Bool) -> Void)? = nil) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
            if let error = error {
                print("Sign in error: \(error.localizedDescription)")
                self?.authError = error
                completion?(false)
                return
            }
            
            guard let user = result?.user else {
                completion?(false)
                return
            }
            
            // Fetch additional user data from Firestore
            self?.fetchUserData(uid: user.uid) { success in
                completion?(success)
            }
        }
    }
    
    func signUp(
        email: String, 
        password: String, 
        firstName: String, 
        lastName: String, 
        completion: ((Bool, String?) -> Void)? = nil
    ) {
        // Validate input
        guard !email.isEmpty, !password.isEmpty, !firstName.isEmpty, !lastName.isEmpty else {
            print("❌ Sign up validation failed: Empty fields")
            completion?(false, "Please fill in all fields")
            return
        }
        
        // Email validation
        guard isValidEmail(email) else {
            print("❌ Invalid email format")
            completion?(false, "Invalid email format")
            return
        }
        
        // Password strength check
        guard password.count >= 6 else {
            print("❌ Password too short")
            completion?(false, "Password must be at least 6 characters")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (result, error) in
            if let error = error {
                // Detailed error handling
                let errorMessage: String
                switch (error as NSError).code {
                case AuthErrorCode.emailAlreadyInUse.rawValue:
                    errorMessage = "Email is already in use"
                case AuthErrorCode.invalidEmail.rawValue:
                    errorMessage = "Invalid email address"
                case AuthErrorCode.weakPassword.rawValue:
                    errorMessage = "Password is too weak"
                default:
                    errorMessage = error.localizedDescription
                }
                
                print("❌ Sign up error: \(errorMessage)")
                self?.authError = error
                completion?(false, errorMessage)
                return
            }
            
            guard let user = result?.user else { 
                print("❌ No user created")
                completion?(false, "User creation failed")
                return 
            }
            
            // Save additional user info to Firestore
            let userData: [String: Any] = [
                "uid": user.uid,
                "email": email,
                "firstName": firstName,
                "lastName": lastName,
                "profileCompleted": false,
                "createdAt": FieldValue.serverTimestamp()
            ]
            
            Firestore.firestore().collection("users").document(user.uid).setData(userData) { error in
                if let error = error {
                    print("❌ Error saving user data: \(error.localizedDescription)")
                    completion?(false, "Failed to save user data")
                    return
                }
                
                // Update local user state
                DispatchQueue.main.async {
                    self?.currentUser = User(
                        id: user.uid,
                        firstName: firstName,
                        lastName: lastName,
                        email: email,
                        profileCompleted: false
                    )
                    self?.isAuthenticated = true
                    print("✅ User signed up successfully")
                    completion?(true, nil)
                }
            }
        }
    }
    
    private func fetchUserData(uid: String, completion: ((Bool) -> Void)? = nil) {
        Firestore.firestore().collection("users").document(uid).getDocument { [weak self] (snapshot, error) in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                completion?(false)
                return
            }
            
            guard let data = snapshot?.data() else {
                completion?(false)
                return
            }
            
            self?.currentUser = User(
                id: uid,
                firstName: data["firstName"] as? String,
                lastName: data["lastName"] as? String,
                email: data["email"] as? String,
                profileImageURL: data["profileImageURL"] as? String,
                bio: data["bio"] as? String,
                interests: data["interests"] as? [String],
                prompts: data["prompts"] as? [String],
                profileCompleted: data["profileCompleted"] as? Bool ?? false
            )
            
            self?.isAuthenticated = true
            completion?(true)
        }
    }
    
    func completeProfileCreation(user: User, completion: ((Bool) -> Void)? = nil) {
        print("🔍 Starting profile creation process")
        
        guard let currentUser = Auth.auth().currentUser else { 
            print("❌ No authenticated user found")
            completion?(false)
            return 
        }
        
        let userData: [String: Any] = [
            "firstName": user.firstName ?? "",
            "lastName": user.lastName ?? "",
            "bio": user.bio ?? "",
            "interests": user.interests ?? [],
            "prompts": user.prompts ?? [],
            "profileCompleted": true,
            "email": currentUser.email ?? ""
        ]
        
        print("📝 Preparing to update user data: \(userData)")
        
        Firestore.firestore().collection("users").document(currentUser.uid).updateData(userData) { error in
            if let error = error {
                print("❌ Error updating profile: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion?(false)
                }
            } else {
                print("✅ Profile successfully updated")
                // Update the local user object
                DispatchQueue.main.async {
                    self.currentUser = user
                    self.isAuthenticated = true
                    print("🎉 Authentication state updated")
                    completion?(true)
                }
            }
        }
    }
    
    // Add email validation method
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
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
                if authViewModel.currentUser?.bio == nil || 
                   (authViewModel.currentUser?.firstName?.isEmpty ?? true) {
                    ProfileCreationView()
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
    @State private var showError = false
    @State private var errorMessage = ""
    
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
                
                // Error Message
                if showError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                // Login Button
                Button(action: signIn) {
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
                
                // Sign Up Button
                Button(action: { showSignUp = true }) {
                    Text("Create New Account")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Login")
            .sheet(isPresented: $showSignUp) {
                SignUpView()
            }
        }
    }
    
    private func signIn() {
        authViewModel.signIn(email: email, password: password) { success in
            if !success {
                errorMessage = "Invalid email or password"
                showError = true
            }
        }
    }
}

// Placeholder SignUp View
struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var firstName = ""
    @State private var lastName = ""
    
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(spacing: 15) {
                    TextField("First Name", text: $firstName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.words)
                    
                    TextField("Last Name", text: $lastName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.words)
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding()
                
                // Error Message
                if showError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                // Sign Up Button
                Button(action: signUp) {
                    Text("Create Account")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .disabled(!isFormValid)
                
                Spacer()
            }
            .navigationTitle("Sign Up")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var isFormValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !email.isEmpty &&
        password.count >= 6 &&
        password == confirmPassword
    }
    
    private func signUp() {
        guard isFormValid else {
            errorMessage = "Please fill out all fields correctly"
            showError = true
            return
        }
        
        authViewModel.signUp(
            email: email, 
            password: password, 
            firstName: firstName, 
            lastName: lastName
        ) { success, errorMsg in
            if success {
                // Navigate to profile creation or main view
                presentationMode.wrappedValue.dismiss()
            } else {
                errorMessage = errorMsg ?? "Sign up failed. Please try again."
                showError = true
            }
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

struct ProfileCreationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ProfileCreationViewModel()
    @State private var currentStep: ProfileCreationStep = .basicInfo
    @State private var progress: CGFloat = 0.0
    @State private var showError = false
    @State private var errorMessage = ""
    
    enum ProfileCreationStep {
        case basicInfo
        case profilePhoto
        case interests
        case bio
        case complete
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(UIColor.systemBackground),
                    Color(UIColor.systemBackground).opacity(0.8)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Progress Indicator
                ProgressView(value: progress, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .padding()
                
                // Main Content
                switch currentStep {
                case .basicInfo:
                    BasicInfoStepView(
                        firstName: $viewModel.firstName,
                        lastName: $viewModel.lastName,
                        onNext: validateBasicInfo
                    )
                    .transition(.asymmetric(insertion: .move(edge: .trailing), 
                                            removal: .move(edge: .leading)))
                    
                case .profilePhoto:
                    ProfilePhotoStepView(
                        selectedImage: $viewModel.profileImage,
                        onNext: { advanceStep() },
                        onBack: { retreatStep() }
                    )
                    .transition(.asymmetric(insertion: .move(edge: .trailing), 
                                            removal: .move(edge: .leading)))
                    
                case .interests:
                    InterestsStepView(
                        selectedInterests: $viewModel.selectedInterests,
                        onNext: validateInterests,
                        onBack: { retreatStep() }
                    )
                    .transition(.asymmetric(insertion: .move(edge: .trailing), 
                                            removal: .move(edge: .leading)))
                    
                case .bio:
                    BioStepView(
                        bio: $viewModel.bio,
                        onNext: validateBio,
                        onBack: { retreatStep() }
                    )
                    .transition(.asymmetric(insertion: .move(edge: .trailing), 
                                            removal: .move(edge: .leading)))
                    
                case .complete:
                    ProfileCompletionView(
                        viewModel: viewModel,
                        onComplete: completeProfile
                    )
                    .transition(.asymmetric(insertion: .move(edge: .trailing), 
                                            removal: .move(edge: .leading)))
                }
            }
            .animation(.smooth, value: currentStep)
            .padding()
            
            // Error Alert
            if showError {
                ErrorOverlayView(message: errorMessage, onDismiss: { showError = false })
            }
        }
    }
    
    private func validateBasicInfo() {
        if viewModel.firstName.trimmingCharacters(in: .whitespaces).isEmpty {
            showErrorMessage("Please enter your first name")
        } else if viewModel.lastName.trimmingCharacters(in: .whitespaces).isEmpty {
            showErrorMessage("Please enter your last name")
        } else {
            advanceStep()
        }
    }
    
    private func validateInterests() {
        if viewModel.selectedInterests.isEmpty {
            showErrorMessage("Please select at least one interest")
        } else {
            advanceStep()
        }
    }
    
    private func validateBio() {
        if viewModel.bio.trimmingCharacters(in: .whitespaces).isEmpty {
            showErrorMessage("Please write a short bio")
        } else if viewModel.bio.count < 10 {
            showErrorMessage("Bio should be at least 10 characters long")
        } else {
            advanceStep()
        }
    }
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
    
    private func advanceStep() {
        withAnimation {
            switch currentStep {
            case .basicInfo:
                currentStep = .profilePhoto
                progress = 0.25
            case .profilePhoto:
                currentStep = .interests
                progress = 0.5
            case .interests:
                currentStep = .bio
                progress = 0.75
            case .bio:
                currentStep = .complete
                progress = 1.0
            case .complete:
                break
            }
        }
    }
    
    private func retreatStep() {
        withAnimation {
            switch currentStep {
            case .basicInfo:
                break
            case .profilePhoto:
                currentStep = .basicInfo
                progress = 0.0
            case .interests:
                currentStep = .profilePhoto
                progress = 0.25
            case .bio:
                currentStep = .interests
                progress = 0.5
            case .complete:
                currentStep = .bio
                progress = 0.75
            }
        }
    }
    
    private func completeProfile() {
        print("🚀 Attempting to complete profile")
        
        guard let currentUser = authViewModel.currentUser else {
            print("❌ No current user found")
            showErrorMessage("Unable to find current user")
            return
        }
        
        // Create a User object from the view model
        let updatedUser = AuthViewModel.User(
            id: currentUser.id,
            firstName: viewModel.firstName,
            lastName: viewModel.lastName,
            email: currentUser.email,
            profileImageURL: currentUser.profileImageURL,
            bio: viewModel.bio,
            interests: Array(viewModel.selectedInterests),
            prompts: currentUser.prompts
        )
        
        // Call the method to complete profile creation
        authViewModel.completeProfileCreation(user: updatedUser) { success in
            DispatchQueue.main.async {
                if success {
                    print("✅ Profile creation successful")
                    // Directly update the authentication state
                    self.authViewModel.isAuthenticated = true
                    self.authViewModel.currentUser = updatedUser
                } else {
                    print("❌ Profile creation failed")
                    // Show an error to the user
                    self.showErrorMessage("Unable to complete profile. Please try again.")
                }
            }
        }
    }
}

// Error Overlay View
struct ErrorOverlayView: View {
    let message: String
    let onDismiss: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                
                Text(message)
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color.red.opacity(0.8))
            .cornerRadius(10)
            .transition(.move(edge: .bottom))
            .onTapGesture {
                onDismiss()
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .animation(.default, value: message)
    }
}

// Basic Info Step View
struct BasicInfoStepView: View {
    @Binding var firstName: String
    @Binding var lastName: String
    var onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Tell Us About Yourself")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 15) {
                TextField("First Name", text: $firstName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.words)
                
                TextField("Last Name", text: $lastName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.words)
            }
            .padding()
            
            Spacer()
            
            Button("Next") {
                onNext()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }
}

// Primary Button Style
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct ProfilePhotoStepView: View {
    @Binding var selectedImage: UIImage?
    var onNext: () -> Void
    var onBack: () -> Void
    @State private var showImagePicker = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Choose Profile Photo")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.blue, lineWidth: 4)
                    )
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .foregroundColor(.gray)
            }
            
            HStack {
                Button("Back") {
                    onBack()
                }
                .foregroundColor(.red)
                
                Spacer()
                
                Button("Select Photo") {
                    showImagePicker = true
                }
                .foregroundColor(.blue)
                
                Spacer()
                
                Button("Next") {
                    onNext()
                }
                .disabled(selectedImage == nil)
            }
            .padding()
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage)
        }
    }
}

struct InterestsStepView: View {
    @Binding var selectedInterests: Set<String>
    var onNext: () -> Void
    var onBack: () -> Void
    
    let interests = [
        "Technology", "Business", "Arts", "Sports", 
        "Music", "Travel", "Fitness", "Cooking", 
        "Photography", "Gaming", "Reading", "Movies"
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Select Your Interests")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 15) {
                    ForEach(interests, id: \.self) { interest in
                        InterestChip(
                            title: interest, 
                            isSelected: selectedInterests.contains(interest)
                        ) {
                            if selectedInterests.contains(interest) {
                                selectedInterests.remove(interest)
                            } else {
                                selectedInterests.insert(interest)
                            }
                        }
                    }
                }
            }
            .padding()
            
            HStack {
                Button("Back") {
                    onBack()
                }
                .foregroundColor(.red)
                
                Spacer()
                
                Button("Next") {
                    onNext()
                }
                .disabled(selectedInterests.isEmpty)
            }
            .padding()
        }
    }
}

struct BioStepView: View {
    @Binding var bio: String
    var onNext: () -> Void
    var onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Tell Us About Yourself")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            TextEditor(text: $bio)
                .frame(height: 200)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .padding()
            
            HStack {
                Button("Back") {
                    onBack()
                }
                .foregroundColor(.red)
                
                Spacer()
                
                Button("Next") {
                    onNext()
                }
                .disabled(bio.isEmpty)
            }
            .padding()
        }
    }
}

struct ProfileCompletionView: View {
    @ObservedObject var viewModel: ProfileCreationViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Profile Complete!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // Preview of profile details
            VStack(alignment: .leading, spacing: 10) {
                Text("Name: \(viewModel.firstName) \(viewModel.lastName)")
                Text("Interests: \(viewModel.selectedInterests.joined(separator: ", "))")
                Text("Bio: \(viewModel.bio)")
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            if isLoading {
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Text("Completing your profile...")
                        .foregroundColor(.secondary)
                }
            } else {
                Button("Finish") {
                    isLoading = true
                    errorMessage = nil
                    onComplete()
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(isLoading)
            }
        }
        .onChange(of: authViewModel.isAuthenticated) { _, newValue in
            if newValue {
                isLoading = false
                print("🎉 Authentication state changed to: \(newValue)")
            }
        }
    }
}

// Reusable Interest Chip View
struct InterestChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

// View Model for Profile Creation
class ProfileCreationViewModel: ObservableObject {
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var profileImage: UIImage?
    @Published var selectedInterests: Set<String> = []
    @Published var bio = ""
}

// Image Picker Wrapper
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    ContentView()
}
