import Foundation
import Combine
import UIKit

class ProfileViewModel: ObservableObject {
    @Published var user: User
    @Published var moments: [Moment] = []
    @Published var isEditing = false
    @Published var showImagePicker = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var isLoading = false
    
    private let networkService = NetworkService.shared
    private let imageManager = ImageManager.shared
    private let momentsManager = MomentsManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // Editable fields
    @Published var editableFirstName: String
    @Published var editableLastName: String
    @Published var editableBio: String
    @Published var editableInterests: [String]
    @Published var editablePrompts: [User.ProfilePrompt]
    @Published var selectedProfileImage: UIImage?
    
    init(user: User) {
        self.user = user
        self.editableFirstName = user.firstName
        self.editableLastName = user.lastName
        self.editableBio = user.bio ?? ""
        self.editableInterests = user.interests
        self.editablePrompts = user.profilePrompts
        
        setupBindings()
        loadMoments()
    }
    
    private func setupBindings() {
        momentsManager.$userMoments
            .map { $0[self.user.id] ?? [] }
            .assign(to: &$moments)
    }
    
    func loadMoments() {
        momentsManager.loadMoments(for: user.id)
    }
    
    func saveProfile() {
        isLoading = true
        
        let updateProfile = { [weak self] (imageURL: URL?) in
            guard let self = self else { return }
            
            var updatedUser = self.user
            updatedUser.firstName = self.editableFirstName
            updatedUser.lastName = self.editableLastName
            updatedUser.bio = self.editableBio
            updatedUser.interests = self.editableInterests
            updatedUser.profilePrompts = self.editablePrompts
            
            if let imageURL = imageURL {
                updatedUser.profileImageURLs = [imageURL] + updatedUser.profileImageURLs
            }
            
            self.networkService.makeRequest(
                endpoint: .updateProfile(updatedUser.id),
                body: updatedUser
            )
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                    self?.showError = true
                }
            }, receiveValue: { [weak self] (updatedUser: User) in
                self?.user = updatedUser
                self?.isEditing = false
            })
            .store(in: &self.cancellables)
        }
        
        if let image = selectedProfileImage {
            imageManager.uploadImage(image)
                .sink(receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        self?.showError = true
                        self?.isLoading = false
                    }
                }, receiveValue: { url in
                    updateProfile(url)
                })
                .store(in: &cancellables)
        } else {
            updateProfile(nil)
        }
    }
    
    func addMoment(content: String, image: UIImage?, privacy: Moment.Privacy) {
        momentsManager.createMoment(content: content, image: image, privacy: privacy)
    }
    
    func likeMoment(_ moment: Moment) {
        momentsManager.likeMoment(moment)
    }
    
    func commentOnMoment(_ moment: Moment, content: String) {
        momentsManager.commentOnMoment(moment, content: content)
    }
} 