import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Your Profile")
                Button("Sign Out") {
                    authViewModel.signOut()
                }
            }
            .navigationTitle("Profile")
        }
    }
} 