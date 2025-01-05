struct MessageBubble: View {
    let message: Message
    let isFromCurrentUser: Bool
    let onReaction: (String) -> Void
    let onDelete: () -> Void
    
    @State private var showReactionMenu = false
    @State private var showDeleteAlert = false
    
    private let reactions = ["👍", "❤️", "😊", "😂", "👏", "🎉"]
    
    var body: some View {
        HStack {
            if isFromCurrentUser { Spacer() }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                // Message content
                if message.isDeleted {
                    Text("This message was deleted")
                        .italic()
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .clipShape(BubbleShape(isFromCurrentUser: isFromCurrentUser))
                } else {
                    Text(message.content)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(isFromCurrentUser ? Color.accentColor : Color(.systemGray6))
                        .foregroundColor(isFromCurrentUser ? .white : .primary)
                        .clipShape(BubbleShape(isFromCurrentUser: isFromCurrentUser))
                        .contextMenu {
                            // Reactions menu
                            ForEach(reactions, id: \.self) { reaction in
                                Button {
                                    onReaction(reaction)
                                } label: {
                                    Text(reaction)
                                }
                            }
                            
                            if isFromCurrentUser {
                                Divider()
                                Button(role: .destructive) {
                                    showDeleteAlert = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                }
                
                // Message metadata
                HStack(spacing: 4) {
                    Text(message.createdAt, style: .time)
                    
                    if isFromCurrentUser && !message.isDeleted {
                        switch message.status {
                        case .sending:
                            ProgressView()
                                .scaleEffect(0.5)
                        case .sent:
                            Image(systemName: "checkmark")
                        case .delivered:
                            Image(systemName: "checkmark.circle")
                        case .read:
                            Image(systemName: "checkmark.circle.fill")
                        case .failed:
                            Image(systemName: "exclamationmark.circle")
                                .foregroundColor(.red)
                        }
                    }
                }
                .font(.caption2)
                .foregroundColor(.secondary)
                
                // Reactions
                if !message.reactions.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(message.reactions, id: \.createdAt) { reaction in
                            Text(reaction.reaction)
                                .font(.caption)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
            
            if !isFromCurrentUser { Spacer() }
        }
        .alert("Delete Message", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                onDelete()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this message? This action cannot be undone.")
        }
    }
} 