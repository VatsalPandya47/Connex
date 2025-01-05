import SwiftUI

struct ChatListView: View {
    @StateObject private var viewModel = ChatListViewModel()
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.conversations.isEmpty {
                    emptyStateView
                } else {
                    List {
                        ForEach(viewModel.sortedConversations()) { conversation in
                            NavigationLink {
                                ChatDetailView(conversation: conversation)
                            } label: {
                                ConversationRow(conversation: conversation)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    viewModel.deleteConversation(conversation)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Messages")
            .refreshable {
                viewModel.loadConversations()
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .loadingOverlay(isLoading: viewModel.isLoading)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "message")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Messages Yet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Connect with others to start chatting")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct ConversationRow: View {
    let conversation: Conversation
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile image
            if let imageURL = conversation.otherUser.profileImageURLs.first {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color(.systemGray5)
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(conversation.otherUser.initials)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.secondary)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(conversation.otherUser.firstName)
                        .font(.headline)
                    
                    if conversation.unreadCount > 0 {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 8, height: 8)
                    }
                    
                    Spacer()
                    
                    if let timestamp = conversation.lastMessage?.timestamp {
                        Text(timestamp.timeAgoDisplay())
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let lastMessage = conversation.lastMessage {
                    Text(lastMessage.content)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 4)
    }
} 