import Foundation
import Combine

class MomentsManager: ObservableObject {
    static let shared = MomentsManager()
    private let networkService = NetworkService.shared
    private let imageManager = ImageManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    @Published private(set) var moments: [Moment] = []
    @Published private(set) var userMoments: [UUID: [Moment]] = [:]
    @Published var isLoading = false
    
    func loadMoments(for userId: UUID, refresh: Bool = false) {
        if refresh {
            userMoments[userId]?.removeAll()
        }
        
        isLoading = true
        
        networkService.makeRequest(endpoint: .moments(userId: userId))
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    print("Failed to load moments: \(error)")
                }
            }, receiveValue: { [weak self] (moments: [Moment]) in
                self?.userMoments[userId] = moments
            })
            .store(in: &cancellables)
    }
    
    func createMoment(content: String, image: UIImage?, privacy: Moment.Privacy) {
        let createMoment = { (imageURL: URL?) in
            let moment = CreateMomentRequest(
                content: content,
                mediaURL: imageURL,
                privacy: privacy
            )
            
            self.networkService.makeRequest(
                endpoint: .createMoment,
                body: moment
            )
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Failed to create moment: \(error)")
                }
            }, receiveValue: { [weak self] (moment: Moment) in
                self?.moments.insert(moment, at: 0)
                if let userId = AuthenticationService.shared.currentUser?.id {
                    self?.userMoments[userId]?.insert(moment, at: 0)
                }
            })
            .store(in: &self.cancellables)
        }
        
        if let image = image {
            imageManager.uploadImage(image)
                .sink(receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Failed to upload image: \(error)")
                        createMoment(nil)
                    }
                }, receiveValue: { url in
                    createMoment(url)
                })
                .store(in: &cancellables)
        } else {
            createMoment(nil)
        }
    }
    
    func likeMoment(_ moment: Moment) {
        networkService.makeRequest(endpoint: .likeMoment(moment.id))
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Failed to like moment: \(error)")
                }
            }, receiveValue: { [weak self] (updatedMoment: Moment) in
                self?.updateMoment(updatedMoment)
            })
            .store(in: &cancellables)
    }
    
    func commentOnMoment(_ moment: Moment, content: String) {
        let comment = CreateCommentRequest(content: content)
        
        networkService.makeRequest(
            endpoint: .commentOnMoment(moment.id),
            body: comment
        )
        .sink(receiveCompletion: { completion in
            if case .failure(let error) = completion {
                print("Failed to comment on moment: \(error)")
            }
        }, receiveValue: { [weak self] (updatedMoment: Moment) in
            self?.updateMoment(updatedMoment)
        })
        .store(in: &cancellables)
    }
    
    private func updateMoment(_ updatedMoment: Moment) {
        if let index = moments.firstIndex(where: { $0.id == updatedMoment.id }) {
            moments[index] = updatedMoment
        }
        
        if let userId = updatedMoment.userId,
           let index = userMoments[userId]?.firstIndex(where: { $0.id == updatedMoment.id }) {
            userMoments[userId]?[index] = updatedMoment
        }
    }
}

struct CreateMomentRequest: Codable {
    let content: String
    let mediaURL: URL?
    let privacy: Moment.Privacy
}

struct CreateCommentRequest: Codable {
    let content: String
} 