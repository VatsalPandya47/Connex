import Foundation
import Combine

class ChatDetailViewModel: ObservableObject {
    @Published var messages: [Conversation.Message] = []
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    
    func sendMessage(_ content: String) {
        guard !content.isEmpty else { return }
        
        let message = Conversation.Message(
            id: UUID(),
            senderId: UUID(), // Replace with current user ID
            content: content,
            timestamp: Date(),
            isRead: false,
            type: .text
        )
        
        messages.append(message)
        // In a real app, send to server
    }
    
    func attachMedia() {
        // Implement media attachment
    }
} 