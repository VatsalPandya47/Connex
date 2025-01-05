import SwiftUI
import PhotosUI

class ProfileEditViewModel: ObservableObject {
    @Published var photos: [UIImage] = []
    @Published var selectedItem: PhotosPickerItem? {
        didSet { handleSelectedPhoto() }
    }
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var bio: String = ""
    @Published var prompts: [EditablePrompt] = []
    @Published var selectedInterests: [String] = []
    @Published var showInterestsSheet = false
    
    let availablePrompts = [
        "The next skill I want to learn is...",
        "My perfect weekend is...",
        "A cause I'm passionate about is...",
        "My favorite travel story is...",
        "One thing I want to try is..."
    ]
    
    let availableInterests = [
        "Travel", "Photography", "Cooking", "Fitness",
        "Reading", "Music", "Art", "Technology",
        "Sports", "Movies", "Gaming", "Nature"
    ]
    
    struct EditablePrompt {
        var prompt: String
        var response: String
    }
    
    init(user: User?) {
        if let user = user {
            self.firstName = user.firstName
            self.lastName = user.lastName
            self.bio = user.bio ?? ""
            self.prompts = user.profilePrompts.map { EditablePrompt(prompt: $0.prompt, response: $0.response) }
            self.selectedInterests = user.interests
            // Load photos from URLs would go here
        }
    }
    
    private func handleSelectedPhoto() {
        guard let item = selectedItem else { return }
        
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    photos.append(image)
                }
            }
        }
    }
    
    func removePhoto(at index: Int) {
        photos.remove(at: index)
    }
    
    func addPrompt() {
        guard prompts.count < 3 else { return }
        prompts.append(EditablePrompt(prompt: availablePrompts[0], response: ""))
    }
    
    func toggleInterest(_ interest: String) {
        if selectedInterests.contains(interest) {
            selectedInterests.removeAll { $0 == interest }
        } else {
            selectedInterests.append(interest)
        }
    }
    
    func saveChanges() {
        // Implement save logic
    }
} 