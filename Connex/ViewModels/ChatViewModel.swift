import Foundation
import Combine

class ChatViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var isLoading = false
    private var cancellables = Set<AnyCancellable>()
    
    private let networkService = NetworkService.shared
    
    init() {
        loadConversations()
    }
    
    func loadConversations() {
        isLoading = true
        
        // In a real app, this would fetch from the network service
        // For now, we'll use sample data
        conversations = [
            Conversation(
                id: UUID(),
                otherUser: User.sampleUser(),
                lastMessage: Conversation.Message(
                    id: UUID(),
                    senderId: UUID(),
                    content: "Hey, would you like to grab coffee?",
                    timestamp: Date(),
                    isRead: false,
                    type: .text
                ),
                unreadCount: 1,
                isActive: true
            )
        ]
        
        isLoading = false
    }
} 