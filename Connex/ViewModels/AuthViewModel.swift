import Foundation
import Combine

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    
    func checkAuthenticationStatus() {
        // Logic to check if the user is authenticated
    }
} 