import Foundation
import Combine

class ChatViewModel: ObservableObject {
    @Published private(set) var messages: [Message] = []
    @Published var messageText = ""
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published private(set) var isOtherUserTyping = false
    private var typingTimer: Timer?
    
    let currentUserId: String
    private let conversation: Conversation
    private let chatService = ChatService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init(conversation: Conversation) {
        self.conversation = conversation
        self.currentUserId = AuthenticationService.shared.currentUser?.id ?? ""
        loadMessages()
    }
    
    func loadMessages() {
        isLoading = true
        
        chatService.loadMessages(for: conversation.id)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        self?.showError = true
                    }
                },
                receiveValue: { [weak self] messages in
                    self?.messages = messages
                }
            )
            .store(in: &cancellables)
    }
    
    func sendMessage() {
        guard !messageText.isEmpty else { return }
        let content = messageText
        messageText = ""
        
        chatService.sendMessage(content, in: conversation.id)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        self?.showError = true
                    }
                },
                receiveValue: { [weak self] message in
                    self?.messages.append(message)
                }
            )
            .store(in: &cancellables)
    }
    
    func markAsRead() {
        chatService.markAsRead(conversation.id)
    }
    
    func handleTyping() {
        chatService.sendTypingIndicator(in: conversation.id, isTyping: true)
        
        // Reset typing timer
        typingTimer?.invalidate()
        typingTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            self?.chatService.sendTypingIndicator(in: self?.conversation.id ?? "", isTyping: false)
        }
    }
    
    private func setupTypingBindings() {
        chatService.$typingUsers
            .map { [weak self] typingUsers in
                guard let self = self,
                      let typingUserId = typingUsers[self.conversation.id] else {
                    return false
                }
                return typingUserId != self.currentUserId
            }
            .assign(to: &$isOtherUserTyping)
    }
    
    func addReaction(_ reaction: String, to messageId: String) {
        chatService.addReaction(reaction, to: messageId)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        self?.showError = true
                    }
                },
                receiveValue: { [weak self] message in
                    if let index = self?.messages.firstIndex(where: { $0.id == message.id }) {
                        self?.messages[index] = message
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func removeReaction(from messageId: String) {
        chatService.removeReaction(from: messageId)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        self?.showError = true
                    }
                },
                receiveValue: { [weak self] message in
                    if let index = self?.messages.firstIndex(where: { $0.id == message.id }) {
                        self?.messages[index] = message
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func deleteMessage(_ messageId: String) {
        chatService.deleteMessage(messageId)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        self?.showError = true
                    }
                },
                receiveValue: { [weak self] message in
                    if let index = self?.messages.firstIndex(where: { $0.id == message.id }) {
                        self?.messages[index] = message
                    }
                }
            )
            .store(in: &cancellables)
    }
} 