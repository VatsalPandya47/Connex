import SwiftUI

struct ConversationsView: View {
    @StateObject private var viewModel = ConversationsViewModel()
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.conversations.isEmpty {
                    EmptyStateView(
                        image: "bubble.left.and.bubble.right",
                        title: "No Conversations",
                        message: "Start connecting with others to begin chatting"
                    )
                } else {
                    List {
                        ForEach(viewModel.conversations) { conversation in
                            NavigationLink {
                                ChatView(conversation: conversation)
                            } label: {
                                ConversationRow(conversation: conversation)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        viewModel.loadConversations()
                    }
                }
            }
            .navigationTitle("Messages")
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .loadingOverlay(isLoading: viewModel.isLoading)
        }
    }
}

struct ConversationRow: View {
    let conversation: Conversation
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile image
            if let imageURL = conversation.otherParticipant?.profileImageURLs.first {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color(.systemGray6)
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            }
            
            // Conversation info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    if let name = conversation.otherParticipant.map({ "\($0.firstName) \($0.lastName)" }) {
                        Text(name)
                            .font(.headline)
                    }
                    
                    Spacer()
                    
                    if let date = conversation.lastMessage?.createdAt {
                        Text(date, style: .relative)
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
            
            // Unread indicator
            if conversation.unreadCount > 0 {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 4)
    }
} 