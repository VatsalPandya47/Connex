import Foundation
import Combine

class ChatService: ObservableObject {
    static let shared = ChatService()
    
    @Published private(set) var conversations: [Conversation] = []
    @Published private(set) var activeConversation: Conversation?
    @Published private(set) var typingUsers: [String: String] = [:] // [conversationId: userId]
    
    private let networkService = NetworkService.shared
    private var messageSubscription: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupBindings()
    }
    
    private func setupBindings() {
        // Listen for new messages from WebSocket
        messageSubscription = NetworkService.shared.messageUpdates
            .sink { [weak self] message in
                self?.handleIncomingMessage(message)
            }
    }
    
    func loadConversations() -> AnyPublisher<[Conversation], Error> {
        networkService.makeRequest(endpoint: .conversations)
            .handleEvents(receiveOutput: { [weak self] conversations in
                self?.conversations = conversations
            })
            .eraseToAnyPublisher()
    }
    
    func loadMessages(for conversationId: String, before date: Date? = nil) -> AnyPublisher<[Message], Error> {
        networkService.makeRequest(
            endpoint: .messages(conversationId),
            body: date.map { ["before": $0] }
        )
    }
    
    func sendMessage(_ content: String, in conversationId: String) -> AnyPublisher<Message, Error> {
        let tempId = UUID().uuidString
        let tempMessage = Message(
            id: tempId,
            conversationId: conversationId,
            senderId: AuthenticationService.shared.currentUser?.id ?? "",
            content: content,
            type: .text,
            createdAt: Date(),
            status: .sending
        )
        
        // Optimistically update UI
        handleIncomingMessage(tempMessage)
        
        return networkService.makeRequest(
            endpoint: .sendMessage(conversationId),
            body: ["content": content]
        )
        .handleEvents(receiveOutput: { [weak self] message in
            self?.updateMessage(tempId, with: message)
        })
        .eraseToAnyPublisher()
    }
    
    func markAsRead(_ conversationId: String) {
        guard let conversation = conversations.first(where: { $0.id == conversationId }),
              conversation.unreadCount > 0 else {
            return
        }
        
        networkService.makeRequest(
            endpoint: .markAsRead(conversationId)
        )
        .sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] in
                self?.updateConversation(conversationId) { conversation in
                    conversation.unreadCount = 0
                }
            }
        )
        .store(in: &cancellables)
    }
    
    func sendTypingIndicator(in conversationId: String, isTyping: Bool) {
        networkService.makeRequest(
            endpoint: .typing(conversationId),
            body: ["isTyping": isTyping]
        )
        .sink(
            receiveCompletion: { _ in },
            receiveValue: { _ in }
        )
        .store(in: &cancellables)
    }
    
    private func handleIncomingMessage(_ message: Message) {
        // Update conversation with new message
        updateConversation(message.conversationId) { conversation in
            conversation.lastMessage = message
            conversation.updatedAt = message.createdAt
            
            if message.senderId != AuthenticationService.shared.currentUser?.id {
                conversation.unreadCount += 1
            }
        }
    }
    
    private func updateMessage(_ tempId: String, with message: Message) {
        // Update the temporary message with the real one from the server
        if let index = conversations.firstIndex(where: { $0.id == message.conversationId }) {
            conversations[index].lastMessage = message
        }
    }
    
    private func updateConversation(_ id: String, update: (inout Conversation) -> Void) {
        if let index = conversations.firstIndex(where: { $0.id == id }) {
            var conversation = conversations[index]
            update(&conversation)
            conversations[index] = conversation
        }
    }
    
    private func handleTypingIndicator(_ payload: [String: Any]) {
        guard let conversationId = payload["conversationId"] as? String,
              let userId = payload["userId"] as? String,
              let isTyping = payload["isTyping"] as? Bool else {
            return
        }
        
        if isTyping {
            typingUsers[conversationId] = userId
        } else {
            typingUsers.removeValue(forKey: conversationId)
        }
    }
    
    func addReaction(_ reaction: String, to messageId: String) -> AnyPublisher<Message, Error> {
        networkService.makeRequest(
            endpoint: .addReaction(messageId),
            body: ["reaction": reaction]
        )
        .handleEvents(receiveOutput: { [weak self] message in
            self?.updateMessageInConversation(message)
        })
        .eraseToAnyPublisher()
    }
    
    func removeReaction(from messageId: String) -> AnyPublisher<Message, Error> {
        networkService.makeRequest(endpoint: .removeReaction(messageId))
            .handleEvents(receiveOutput: { [weak self] message in
                self?.updateMessageInConversation(message)
            })
            .eraseToAnyPublisher()
    }
    
    func deleteMessage(_ messageId: String) -> AnyPublisher<Message, Error> {
        networkService.makeRequest(endpoint: .deleteMessage(messageId))
            .handleEvents(receiveOutput: { [weak self] message in
                self?.updateMessageInConversation(message)
            })
            .eraseToAnyPublisher()
    }
    
    private func updateMessageInConversation(_ message: Message) {
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            messages[index] = message
        }
    }
} 