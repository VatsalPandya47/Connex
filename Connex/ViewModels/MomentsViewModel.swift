import Foundation
import Combine
import UIKit

class MomentsViewModel: ObservableObject {
    @Published var moments: [Moment] = []
    @Published var isLoading = false
    @Published var showingCreateSheet = false
    
    private var cancellables = Set<AnyCancellable>()
    private let networkService = NetworkService.shared
    
    init() {
        loadMoments()
    }
    
    func loadMoments() {
        isLoading = true
        
        networkService.fetchUserMoments(userId: UUID()) // Replace with current user ID
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    print("Failed to load moments: \(error)")
                }
            }, receiveValue: { [weak self] moments in
                self?.moments = moments
            })
            .store(in: &cancellables)
    }
    
    func createNewMoment() {
        showingCreateSheet = true
    }
    
    func likeMoment(_ moment: Moment) {
        // Implement like functionality
    }
    
    func addComment(to moment: Moment, content: String) {
        // Implement comment functionality
    }
} 