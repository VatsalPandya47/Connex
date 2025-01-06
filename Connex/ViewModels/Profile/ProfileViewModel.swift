import Foundation
import Combine

class ProfileViewModel: ObservableObject {
    @Published var user: User
    @Published var isCurrentUser: Bool = false // Determine if the profile belongs to the current user
    
    private var cancellables = Set<AnyCancellable>()
    
    init(user: User) {
        self.user = user
        // Additional initialization if needed
    }
    
    func updateUserProfile(with updatedUser: User) {
        // Logic to update the user profile
        self.user = updatedUser
    }
    
    func toggleProfileVisibility() {
        user.isProfileVisible.toggle()
    }
} 