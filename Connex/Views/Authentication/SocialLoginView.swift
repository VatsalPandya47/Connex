import SwiftUI
import AuthenticationServices
import GoogleSignIn
import Firebase

struct SocialLoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            // Apple Sign In
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                handleAppleSignIn(result)
            }
            .frame(height: 50)
            .cornerRadius(8)
            
            // Google Sign In
            Button(action: {
                handleGoogleSignIn()
            }) {
                HStack {
                    Image("google-logo") // Add Google logo to your assets
                    Text("Sign in with Google")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .foregroundColor(.black)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
        }
        .padding()
    }
    
    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let identityToken = appleIDCredential.identityToken,
                  let tokenString = String(data: identityToken, encoding: .utf8) else {
                return
            }
            
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: tokenString,
                                                      rawNonce: nil)
            
            FirebaseManager.shared.auth.signIn(with: credential) { (authResult, error) in
                if let error = error {
                    print("Apple sign-in error: \(error.localizedDescription)")
                    return
                }
                
                // Create or update user in Firestore
                guard let user = authResult?.user else { return }
                createUserInFirestore(user: user)
            }
            
        case .failure(let error):
            print("Apple sign-in error: \(error.localizedDescription)")
        }
    }
    
    private func handleGoogleSignIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: getRootViewController()) { signInResult, error in
            if let error = error {
                print("Google sign-in error: \(error.localizedDescription)")
                return
            }
            
            guard let user = signInResult?.user,
                  let idToken = user.idToken?.tokenString else { return }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            FirebaseManager.shared.auth.signIn(with: credential) { (authResult, error) in
                if let error = error {
                    print("Firebase Google sign-in error: \(error.localizedDescription)")
                    return
                }
                
                // Create or update user in Firestore
                guard let user = authResult?.user else { return }
                createUserInFirestore(user: user)
            }
        }
    }
    
    private func createUserInFirestore(user: User) {
        let userData: [String: Any] = [
            "id": user.uid,
            "email": user.email ?? "",
            "firstName": user.displayName ?? "",
            "lastName": "",
            "profileImageURL": user.photoURL?.absoluteString ?? ""
        ]
        
        FirebaseManager.shared.firestore
            .collection("users")
            .document(user.uid)
            .setData(userData, merge: true)
    }
    
    // Utility function to get root view controller
    private func getRootViewController() -> UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }
        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }
        return root
    }
} 