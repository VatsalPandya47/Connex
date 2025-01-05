import Foundation
import Combine

class ProfileViewModel: ObservableObject {
    @Published var user: User
    @Published var isCurrentUser: Bool = false // Determine if the profile belongs to the current user
    
    init(user: User) {
        self.user = user
        // Additional initialization if needed
    }
} 