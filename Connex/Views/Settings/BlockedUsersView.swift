import SwiftUI

struct BlockedUsersView: View {
    @StateObject private var viewModel = BlockedUsersViewModel()
    
    var body: some View {
        List {
            if viewModel.blockedUsers.isEmpty {
                Text("No blocked users")
                    .foregroundColor(.secondary)
            } else {
                ForEach(viewModel.blockedUsers) { user in
                    HStack {
                        Text("\(user.firstName) \(user.lastName)")
                        Spacer()
                        Button("Unblock") {
                            viewModel.unblockUser(user)
                        }
                        .foregroundColor(.accentColor)
                    }
                }
            }
        }
        .navigationTitle("Blocked Users")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            viewModel.loadBlockedUsers()
        }
    }
} 