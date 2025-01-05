import SwiftUI

struct AccountSettingsView: View {
    @StateObject private var viewModel = AccountSettingsViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Form {
            Section(header: Text("Account Information")) {
                NavigationLink("Email Address") {
                    EmailChangeView()
                }
                NavigationLink("Change Password") {
                    PasswordChangeView()
                }
            }
            
            Section(header: Text("Data & Privacy")) {
                NavigationLink("Download My Data") {
                    DataDownloadView()
                }
                Button("Delete Account") {
                    viewModel.showDeleteConfirmation = true
                }
                .foregroundColor(.red)
            }
            
            Section {
                Button("Sign Out") {
                    authViewModel.signOut()
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("Account")
        .alert("Delete Account", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.deleteAccount()
            }
        } message: {
            Text("This action cannot be undone. All your data will be permanently deleted.")
        }
    }
} 