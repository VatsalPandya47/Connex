import SwiftUI

struct EmailChangeView: View {
    @StateObject private var viewModel = EmailChangeViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            Section(header: Text("Current Email")) {
                Text(viewModel.currentEmail)
                    .foregroundColor(.gray)
            }
            
            Section(header: Text("New Email")) {
                TextField("New Email Address", text: $viewModel.newEmail)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                SecureField("Current Password", text: $viewModel.password)
            }
            
            Section {
                Button("Update Email") {
                    viewModel.updateEmail()
                }
                .disabled(!viewModel.isValid)
            }
        }
        .navigationTitle("Change Email")
        .alert("Email Updated", isPresented: $viewModel.showSuccessAlert) {
            Button("OK") { dismiss() }
        }
        .alert("Error", isPresented: $viewModel.showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
} 