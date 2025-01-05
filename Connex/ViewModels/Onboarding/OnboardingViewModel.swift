import Foundation
import Combine
import UIKit

class OnboardingViewModel: ObservableObject {
    @Published var currentStep = 0
    @Published var selectedInterests: [String] = []
    @Published var selectedProfileImage: UIImage?
    @Published var bio = ""
    @Published var selectedPrompts: [User.ProfilePrompt] = []
    @Published var showImagePicker = false
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let networkService = NetworkService.shared
    private let imageManager = ImageManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    let availableInterests = [
        "Travel", "Photography", "Cooking", "Fitness",
        "Reading", "Music", "Art", "Technology",
        "Sports", "Movies", "Gaming", "Fashion",
        "Nature", "Food", "Science", "Business"
    ]
    
    let availablePrompts = [
        "What's your idea of a perfect day?",
        "What's the best advice you've ever received?",
        "What's your favorite travel story?",
        "What are you passionate about?",
        "What's your life goal?"
    ]
    
    var canProceed: Bool {
        switch currentStep {
        case 0: // Interests
            return selectedInterests.count >= AppConfig.Limits.minInterests
        case 1: // Profile Photo
            return selectedProfileImage != nil
        case 2: // Bio & Prompts
            return !bio.isEmpty && !selectedPrompts.isEmpty
        default:
            return false
        }
    }
    
    func proceedToNextStep() {
        guard canProceed else { return }
        currentStep += 1
    }
    
    func completeOnboarding(completion: @escaping (Bool) -> Void) {
        guard let currentUser = AuthenticationService.shared.currentUser else { return }
        isLoading = true
        
        let uploadImage = { [weak self] (completion: @escaping (URL?) -> Void) in
            guard let image = self?.selectedProfileImage else {
                completion(nil)
                return
            }
            
            self?.imageManager.uploadImage(image)
                .sink(receiveCompletion: { completionStatus in
                    if case .failure = completionStatus {
                        completion(nil)
                    }
                }, receiveValue: { url in
                    completion(url)
                })
                .store(in: &self!.cancellables)
        }
        
        uploadImage { [weak self] imageURL in
            guard let self = self else { return }
            
            var updatedUser = currentUser
            updatedUser.interests = self.selectedInterests
            updatedUser.bio = self.bio
            updatedUser.profilePrompts = self.selectedPrompts
            
            if let imageURL = imageURL {
                updatedUser.profileImageURLs = [imageURL]
            }
            
            self.networkService.makeRequest(
                endpoint: .updateProfile(updatedUser.id),
                body: updatedUser
            )
            .sink(receiveCompletion: { [weak self] completionStatus in
                self?.isLoading = false
                if case .failure(let error) = completionStatus {
                    self?.errorMessage = error.localizedDescription
                    self?.showError = true
                    completion(false)
                }
            }, receiveValue: { _ in
                completion(true)
            })
            .store(in: &self.cancellables)
        }
    }
} 