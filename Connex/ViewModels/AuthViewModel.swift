import SwiftUI
import Combine
import Firebase
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var authError: Error?
    
    enum AuthState {
        case unauthenticated
        case authenticating
        case authenticated
        case error
    }
    
    @Published var authState: AuthState = .unauthenticated
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        FirebaseManager.shared.auth.addStateDidChangeListener { [weak self] (_, user) in
            if let user = user {
                self?.fetchUserData(uid: user.uid)
            } else {
                self?.currentUser = nil
                self?.isAuthenticated = false
                self?.authState = .unauthenticated
            }
        }
    }
    
    func signIn(email: String, password: String) {
        authState = .authenticating
        
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { [weak self] (result, error) in
            if let error = error {
                // Log authentication attempt
                AnalyticsService.shared.logAuthenticationAttempt(method: "email", success: false)
                
                // Map and handle error
                let connexError = ErrorHandler.mapFirebaseError(error)
                self?.authState = .error
                self?.authError = connexError
                
                // Report error
                error.report(context: "Email Sign In")
                
                return
            }
            
            // Successful authentication
            AnalyticsService.shared.logAuthenticationAttempt(method: "email", success: true)
            
            guard let uid = result?.user.uid else {
                self?.authState = .error
                return
            }
            
            self?.fetchUserData(uid: uid)
        }
    }
    
    func signUp(email: String, password: String, firstName: String, lastName: String) {
        authState = .authenticating
        
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { [weak self] (result, error) in
            if let error = error {
                self?.authState = .error
                self?.authError = error
                return
            }
            
            guard let uid = result?.user.uid else {
                self?.authState = .error
                return
            }
            
            let userData: [String: Any] = [
                "id": uid,
                "firstName": firstName,
                "lastName": lastName,
                "email": email
            ]
            
            FirebaseManager.shared.firestore
                .collection("users")
                .document(uid)
                .setData(userData) { error in
                    if let error = error {
                        self?.authState = .error
                        self?.authError = error
                    } else {
                        self?.fetchUserData(uid: uid)
                    }
                }
        }
    }
    
    private func fetchUserData(uid: String) {
        FirebaseManager.shared.firestore
            .collection("users")
            .document(uid)
            .getDocument { [weak self] (snapshot, error) in
                if let error = error {
                    self?.authState = .error
                    self?.authError = error
                    return
                }
                
                guard let data = snapshot?.data() else {
                    self?.authState = .error
                    return
                }
                
                let user = User(
                    id: uid,
                    firstName: data["firstName"] as? String ?? "",
                    lastName: data["lastName"] as? String ?? "",
                    email: data["email"] as? String ?? "",
                    profileImageURL: data["profileImageURL"] as? String,
                    bio: data["bio"] as? String,
                    age: data["age"] as? Int,
                    location: nil,
                    interests: data["interests"] as? [String] ?? [],
                    prompts: []
                )
                
                self?.completeSignIn(user: user)
            }
    }
    
    func completeSignIn(user: User) {
        currentUser = user
        isAuthenticated = true
        authState = .authenticated
    }
    
    func signOut() {
        do {
            try FirebaseManager.shared.auth.signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    func checkAuthenticationStatus() {
        isAuthenticated = FirebaseManager.shared.auth.currentUser != nil
    }
} 