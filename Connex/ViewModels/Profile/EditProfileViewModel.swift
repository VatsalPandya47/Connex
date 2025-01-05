import SwiftUI
import PhotosUI

@MainActor
class EditProfileViewModel: ObservableObject {
    @Published var images: [UIImage] = []
    @Published var selectedItem: PhotosPickerItem? {
        didSet { handleSelectedItem() }
    }
    
    @Published var firstName: String
    @Published var lastName: String
    @Published var headline: String
    @Published var bio: String
    @Published var city: String
    @Published var country: String
    @Published var interests: [String]
    @Published var prompts: [User.ProfilePrompt]
    @Published var newInterest = ""
    
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let user: User
    private let networkService = NetworkService.shared
    private let imageManager = ImageManager.shared
    
    var hasChanges: Bool {
        firstName != user.firstName ||
        lastName != user.lastName ||
        headline != user.headline ?? "" ||
        bio != user.bio ?? "" ||
        city != user.location.city ||
        country != user.location.country ||
        interests != user.interests ||
        prompts != user.profilePrompts
    }
    
    init(user: User) {
        self.user = user
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.headline = user.headline ?? ""
        self.bio = user.bio ?? ""
        self.city = user.location.city
        self.country = user.location.country
        self.interests = user.interests
        self.prompts = user.profilePrompts
        
        // Load existing images
        Task {
            await loadExistingImages()
        }
    }
    
    private func loadExistingImages() async {
        for url in user.profileImageURLs {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    await MainActor.run {
                        images.append(image)
                    }
                }
            } catch {
                print("Error loading image: \(error)")
            }
        }
    }
    
    private func handleSelectedItem() {
        guard let item = selectedItem else { return }
        
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    images.append(image)
                }
            }
        }
    }
    
    func removeImage(at index: Int) {
        images.remove(at: index)
    }
    
    func addInterest() {
        guard !newInterest.isEmpty else { return }
        interests.append(newInterest)
        newInterest = ""
    }
    
    func removeInterest(_ interest: String) {
        interests.removeAll { $0 == interest }
    }
    
    func addPrompt() {
        prompts.append(User.ProfilePrompt(question: "What's your favorite...", answer: ""))
    }
    
    func saveProfile() async {
        isLoading = true
        
        // First upload any new images
        var imageURLs: [URL] = []
        for image in images {
            do {
                let url = try await imageManager.uploadImage(image)
                imageURLs.append(url)
            } catch {
                errorMessage = "Failed to upload images: \(error.localizedDescription)"
                showError = true
                isLoading = false
                return
            }
        }
        
        // Update profile
        let updatedUser = User(
            id: user.id,
            firstName: firstName,
            lastName: lastName,
            email: user.email,
            dateOfBirth: user.dateOfBirth,
            location: User.Location(
                latitude: user.location.latitude,
                longitude: user.location.longitude,
                city: city,
                country: country
            ),
            profileImageURLs: imageURLs,
            bio: bio.isEmpty ? nil : bio,
            headline: headline.isEmpty ? nil : headline,
            interests: interests,
            profilePrompts: prompts,
            lastActive: user.lastActive,
            createdAt: user.createdAt
        )
        
        do {
            try await networkService.updateProfile(updatedUser)
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            isLoading = false
        }
    }
} 