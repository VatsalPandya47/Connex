import SwiftUI

struct BlockedUsersView: View {
    @StateObject private var viewModel = BlockedUsersViewModel()
    
    var body: some View {
        List {
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.blockedUsers.isEmpty {
                Text("No blocked users")
                    .foregroundColor(.gray)
            } else {
                ForEach(viewModel.blockedUsers) { user in
                    BlockedUserRow(user: user) {
                        viewModel.unblockUser(user)
                    }
                }
            }
        }
        .navigationTitle("Blocked Users")
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

struct BlockedUserRow: View {
    let user: User
    let onUnblock: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: user.profileImageURLs.first) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(Color.gray.opacity(0.2))
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())
            
            Text("\(user.firstName) \(user.lastName)")
            
            Spacer()
            
            Button("Unblock") {
                onUnblock()
            }
            .foregroundColor(.blue)
        }
        .padding(.vertical, 4)
    }
} 