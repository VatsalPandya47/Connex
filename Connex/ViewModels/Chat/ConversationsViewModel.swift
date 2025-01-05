import Foundation
import Combine

class ConversationsViewModel: ObservableObject {
    @Published private(set) var conversations: [Conversation] = []
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let chatService = ChatService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        loadConversations()
    }
    
    private func setupBindings() {
        chatService.$conversations
            .assign(to: &$conversations)
    }
    
    func loadConversations() {
        isLoading = true
        
        chatService.loadConversations()
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        self?.showError = true
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
} 