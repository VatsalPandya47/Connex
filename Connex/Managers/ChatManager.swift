import Foundation
import Combine

class ChatManager: ObservableObject {
    static let shared = ChatManager()
    private let networkService = NetworkService.shared
    private var webSocketTask: URLSessionWebSocketTask?
    private var cancellables = Set<AnyCancellable>()
    
    @Published private(set) var conversations: [Conversation] = []
    @Published private(set) var activeConversation: Conversation?
    @Published private(set) var messages: [Message] = []
    
    init() {
        setupWebSocket()
        loadConversations()
    }
    
    private func setupWebSocket() {
        guard let url = URL(string: "\(AppConfig.API.baseURL.replacingOccurrences(of: "http", with: "ws"))/chat") else { return }
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        receiveMessage()
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    if let data = text.data(using: .utf8),
                       let chatMessage = try? JSONDecoder().decode(Message.self, from: data) {
                        DispatchQueue.main.async {
                            self?.handleIncomingMessage(chatMessage)
                        }
                    }
                case .data(let data):
                    if let chatMessage = try? JSONDecoder().decode(Message.self, from: data) {
                        DispatchQueue.main.async {
                            self?.handleIncomingMessage(chatMessage)
                        }
                    }
                @unknown default:
                    break
                }
                self?.receiveMessage()
            case .failure(let error):
                print("WebSocket error: \(error)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self?.setupWebSocket()
                }
            }
        }
    }
    
    private func handleIncomingMessage(_ message: Message) {
        if message.conversationId == activeConversation?.id {
            messages.append(message)
        }
        
        // Update conversation last message
        if let index = conversations.firstIndex(where: { $0.id == message.conversationId }) {
            conversations[index].lastMessage = message
            conversations[index].unreadCount += 1
        }
    }
    
    func loadConversations() {
        networkService.makeRequest(endpoint: .conversations)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Failed to load conversations: \(error)")
                }
            }, receiveValue: { [weak self] (conversations: [Conversation]) in
                self?.conversations = conversations
            })
            .store(in: &cancellables)
    }
    
    func sendMessage(_ content: String, in conversation: Conversation) {
        let message = ["content": content, "type": "text"]
        guard let data = try? JSONEncoder().encode(message) else { return }
        
        webSocketTask?.send(.data(data)) { error in
            if let error = error {
                print("Error sending message: \(error)")
            }
        }
    }
    
    func setActiveConversation(_ conversation: Conversation) {
        activeConversation = conversation
        loadMessages(for: conversation)
    }
    
    private func loadMessages(for conversation: Conversation) {
        networkService.makeRequest(endpoint: .messages(conversationId: conversation.id))
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Failed to load messages: \(error)")
                }
            }, receiveValue: { [weak self] (messages: [Message]) in
                self?.messages = messages
            })
            .store(in: &cancellables)
    }
    
    deinit {
        webSocketTask?.cancel()
    }
} 