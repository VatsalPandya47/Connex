import SwiftUI

struct ChatListView: View {
    @StateObject private var viewModel = ChatViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.conversations) { conversation in
                    NavigationLink(destination: ChatDetailView(conversation: conversation)) {
                        ChatRow(conversation: conversation)
                    }
                }
            }
            .navigationTitle("Chats")
        }
    }
}

struct ChatRow: View {
    let conversation: Conversation
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: conversation.otherUser.profileImageURLs.first) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(Color.gray.opacity(0.2))
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(conversation.otherUser.firstName) \(conversation.otherUser.lastName)")
                    .font(.headline)
                
                Text(conversation.lastMessage?.content ?? "")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            Spacer()
            
            if let date = conversation.lastMessage?.timestamp {
                Text(date, style: .time)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
    }
} 