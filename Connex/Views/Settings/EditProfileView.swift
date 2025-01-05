import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var user: User
    @State private var showAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        Form {
            Section(header: Text("Profile Information")) {
                TextField("First Name", text: $user.firstName)
                TextField("Last Name", text: $user.lastName)
                TextField("Email", text: $user.email)
                    .keyboardType(.emailAddress)
                TextField("Bio", text: $user.bio.bound)
            }
            
            Section {
                Button("Save Changes") {
                    saveChanges()
                }
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private func saveChanges() {
        // Implement the logic to save changes to the user profile
        // For example, call a service to update the user information
        // If there's an error, set the errorMessage and showAlert to true
    }
} 