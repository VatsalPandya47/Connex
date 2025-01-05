import Foundation
import Combine

class ChatListViewModel: ObservableObject {
    @Published private(set) var conversations: [Conversation] = []
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let chatManager = ChatManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        loadConversations()
    }
    
    private func setupBindings() {
        chatManager.$conversations
            .assign(to: &$conversations)
    }
    
    func loadConversations() {
        chatManager.loadConversations()
    }
    
    func markAsRead(_ conversation: Conversation) {
        // Update conversation read status
    }
    
    func deleteConversation(_ conversation: Conversation) {
        // Implement conversation deletion
    }
    
    func sortedConversations() -> [Conversation] {
        conversations.sorted { $0.lastMessage?.timestamp ?? $0.createdAt > $1.lastMessage?.timestamp ?? $1.createdAt }
    }
} 