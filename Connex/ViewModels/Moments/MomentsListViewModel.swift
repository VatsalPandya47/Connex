import Foundation
import Combine
import UIKit

class MomentsListViewModel: ObservableObject {
    @Published private(set) var moments: [Moment] = []
    @Published var showCreateMoment = false
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let momentsManager = MomentsManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        loadMoments()
    }
    
    private func setupBindings() {
        momentsManager.$moments
            .assign(to: &$moments)
        
        momentsManager.$isLoading
            .assign(to: &$isLoading)
    }
    
    func loadMoments() {
        guard let userId = AuthenticationService.shared.currentUser?.id else { return }
        momentsManager.loadMoments(for: userId, refresh: true)
    }
    
    func createMoment(content: String, image: UIImage?, privacy: Moment.Privacy) {
        momentsManager.createMoment(content: content, image: image, privacy: privacy)
    }
    
    func likeMoment(_ moment: Moment) {
        momentsManager.likeMoment(moment)
    }
    
    func commentOnMoment(_ moment: Moment, content: String) {
        momentsManager.commentOnMoment(moment, content: content)
    }
} 