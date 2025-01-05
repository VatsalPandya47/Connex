import Foundation
import Combine

class AccountSettingsViewModel: ObservableObject {
    @Published var showDeleteConfirmation = false
    private var cancellables = Set<AnyCancellable>()
    private let networkService = NetworkService.shared
    
    func deleteAccount() {
        // Implement account deletion
        networkService.deleteAccount()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Failed to delete account: \(error)")
                }
            }, receiveValue: { _ in
                // Handle successful deletion
            })
            .store(in: &cancellables)
    }
} 