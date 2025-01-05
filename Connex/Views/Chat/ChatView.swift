import SwiftUI

struct ChatView: View {
    let conversation: Conversation
    @StateObject private var viewModel: ChatViewModel
    @FocusState private var isInputFocused: Bool
    
    init(conversation: Conversation) {
        self.conversation = conversation
        _viewModel = StateObject(wrappedValue: ChatViewModel(conversation: conversation))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.messages) { message in
                            MessageBubble(
                                message: message,
                                isFromCurrentUser: message.senderId == viewModel.currentUserId
                            )
                        }
                        
                        if viewModel.isOtherUserTyping {
                            TypingIndicator()
                                .padding(.horizontal)
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages) { messages in
                    if let lastMessage = messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Message input
            HStack(spacing: 12) {
                TextField("Message", text: $viewModel.messageText)
                    .textFieldStyle(.roundedBorder)
                    .focused($isInputFocused)
                    .onChange(of: viewModel.messageText) { _ in
                        viewModel.handleTyping()
                    }
                
                Button {
                    viewModel.sendMessage()
                    isInputFocused = false
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                }
                .disabled(viewModel.messageText.isEmpty)
            }
            .padding()
            .background(Color(.systemBackground))
            .shadow(radius: 2)
        }
        .navigationTitle(conversation.otherParticipant?.firstName ?? "Chat")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.markAsRead()
        }
    }
}

struct MessageBubble: View {
    let message: Message
    let isFromCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isFromCurrentUser { Spacer() }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(isFromCurrentUser ? Color.accentColor : Color(.systemGray6))
                    .foregroundColor(isFromCurrentUser ? .white : .primary)
                    .clipShape(BubbleShape(isFromCurrentUser: isFromCurrentUser))
                
                HStack(spacing: 4) {
                    Text(message.createdAt, style: .time)
                    
                    if isFromCurrentUser {
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
            }
            
            if !isFromCurrentUser { Spacer() }
        }
    }
}

struct BubbleShape: Shape {
    let isFromCurrentUser: Bool
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [
                .topLeft,
                .topRight,
                isFromCurrentUser ? .bottomLeft : .bottomRight
            ],
            cornerRadii: CGSize(width: 16, height: 16)
        )
        return Path(path.cgPath)
    }
}

struct TypingIndicator: View {
    @State private var offset: CGFloat = 0
    
    var body: some View {
        HStack {
            Text("typing")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.secondary)
                        .frame(width: 4, height: 4)
                        .offset(y: offset)
                        .animation(
                            Animation.easeInOut(duration: 0.3)
                                .repeatForever()
                                .delay(0.2 * Double(index)),
                            value: offset
                        )
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .clipShape(BubbleShape(isFromCurrentUser: false))
        .onAppear {
            offset = -5
        }
    }
} 