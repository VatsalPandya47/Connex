import Foundation
import UIKit
import Combine

class CreateMomentViewModel: ObservableObject {
    @Published var content = ""
    @Published var selectedImage: UIImage?
    @Published var privacy = Moment.Privacy.public
    @Published var showImagePicker = false
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let momentsManager = MomentsManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    var canSubmit: Bool {
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func createMoment(completion: @escaping (Bool) -> Void) {
        guard canSubmit else { return }
        
        isLoading = true
        momentsManager.createMoment(
            content: content,
            image: selectedImage,
            privacy: privacy
        )
        
        // Reset form
        content = ""
        selectedImage = nil
        privacy = .public
        
        completion(true)
    }
    
    func removeImage() {
        selectedImage = nil
    }
} 