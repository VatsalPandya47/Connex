import SwiftUI

struct ProfileEditView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var bio: String = ""
    @State private var interests: [String] = []
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    
                    TextEditor(text: $bio)
                        .frame(height: 100)
                }
                
                Section(header: Text("Profile Photo")) {
                    Button(action: { showImagePicker = true }) {
                        HStack {
                            if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "camera.fill")
                                Text("Change Profile Photo")
                            }
                        }
                    }
                }
                
                Section(header: Text("Interests")) {
                    NavigationLink(destination: InterestSelectionView(selectedInterests: $interests)) {
                        Text("Edit Interests")
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") { saveProfile() }
            )
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
            }
            .onAppear {
                loadCurrentUserData()
            }
        }
    }
    
    private func loadCurrentUserData() {
        guard let user = authViewModel.currentUser else { return }
        firstName = user.firstName
        lastName = user.lastName
        bio = user.bio ?? ""
        interests = user.interests
    }
    
    private func saveProfile() {
        guard let user = authViewModel.currentUser else { return }
        
        // Update Firestore
        let updateData: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "bio": bio,
            "interests": interests
        ]
        
        FirebaseManager.shared.firestore
            .collection("users")
            .document(user.id)
            .updateData(updateData) { error in
                if let error = error {
                    print("Error updating profile: \(error.localizedDescription)")
                } else {
                    // Update local user object
                    var updatedUser = user
                    updatedUser.firstName = firstName
                    updatedUser.lastName = lastName
                    updatedUser.bio = bio
                    updatedUser.interests = interests
                    
                    authViewModel.currentUser = updatedUser
                    
                    // Upload profile photo if selected
                    uploadProfilePhotoIfNeeded()
                    
                    dismiss()
                }
            }
    }
    
    private func uploadProfilePhotoIfNeeded() {
        guard let imageData = selectedImage?.jpegData(compressionQuality: 0.5),
              let user = authViewModel.currentUser else { return }
        
        let storageRef = FirebaseManager.shared.storage
            .reference()
            .child("profile_images/\(user.id).jpg")
        
        storageRef.putData(imageData) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                return
            }
            
            storageRef.downloadURL { url, error in
                if let downloadURL = url {
                    // Update Firestore with image URL
                    FirebaseManager.shared.firestore
                        .collection("users")
                        .document(user.id)
                        .updateData(["profileImageURL": downloadURL.absoluteString])
                }
            }
        }
    }
}

struct InterestSelectionView: View {
    @Binding var selectedInterests: [String]
    
    let allInterests = [
        "Technology", "Networking", "Entrepreneurship", 
        "Design", "Marketing", "Finance", 
        "Arts", "Music", "Sports"
    ]
    
    var body: some View {
        List {
            ForEach(allInterests, id: \.self) { interest in
                MultipleSelectionRow(title: interest, isSelected: selectedInterests.contains(interest)) {
                    if selectedInterests.contains(interest) {
                        selectedInterests.removeAll { $0 == interest }
                    } else {
                        selectedInterests.append(interest)
                    }
                }
            }
        }
        .navigationTitle("Select Interests")
    }
}

struct MultipleSelectionRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
    }
} 