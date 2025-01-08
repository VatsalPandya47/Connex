import SwiftUI

struct ProfileCreationWizardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var currentStep = 0
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var age: Int?
    @State private var bio = ""
    @State private var selectedInterests: Set<String> = []
    @State private var profileImage: UIImage?
    
    let interests = ["Technology", "Business", "Arts", "Sports", "Music", "Travel", "Fitness"]
    
    var body: some View {
        NavigationView {
            VStack {
                switch currentStep {
                case 0:
                    BasicInfoView(firstName: $firstName, lastName: $lastName, age: $age)
                case 1:
                    ProfilePhotoView(selectedImage: $profileImage)
                case 2:
                    InterestsView(selectedInterests: $selectedInterests, allInterests: interests)
                case 3:
                    BioView(bio: $bio)
                default:
                    Text("Profile Complete")
                }
                
                HStack {
                    if currentStep > 0 {
                        Button("Previous") {
                            currentStep -= 1
                        }
                    }
                    
                    Button(currentStep < 3 ? "Next" : "Complete") {
                        if currentStep < 3 {
                            currentStep += 1
                        } else {
                            completeProfile()
                        }
                    }
                    .disabled(!isStepValid)
                }
                .padding()
            }
            .navigationTitle("Create Profile")
        }
    }
    
    private var isStepValid: Bool {
        switch currentStep {
        case 0: return !firstName.isEmpty && !lastName.isEmpty && age != nil
        case 1: return profileImage != nil
        case 2: return !selectedInterests.isEmpty
        case 3: return !bio.isEmpty
        default: return true
        }
    }
    
    private func completeProfile() {
        let user = AuthViewModel.User(
            id: UUID().uuidString,
            firstName: firstName,
            lastName: lastName,
            email: nil,
            profileImageURL: nil,
            bio: bio,
            interests: Array(selectedInterests),
            prompts: nil
        )
        
        authViewModel.completeProfileCreation(user: user)
    }
}

struct BasicInfoView: View {
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var age: Int?
    
    var body: some View {
        VStack {
            TextField("First Name", text: $firstName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Last Name", text: $lastName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Age", value: $age, format: .number)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
        }
        .padding()
    }
}

struct ProfilePhotoView: View {
    @Binding var selectedImage: UIImage?
    @State private var showImagePicker = false
    
    var body: some View {
        VStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .foregroundColor(.gray)
            }
            
            Button("Select Photo") {
                showImagePicker = true
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage)
        }
    }
}

struct InterestsView: View {
    @Binding var selectedInterests: Set<String>
    let allInterests: [String]
    
    var body: some View {
        List(allInterests, id: \.self) { interest in
            MultipleSelectionRow(title: interest, isSelected: selectedInterests.contains(interest)) {
                if selectedInterests.contains(interest) {
                    selectedInterests.remove(interest)
                } else {
                    selectedInterests.insert(interest)
                }
            }
        }
    }
}

struct BioView: View {
    @Binding var bio: String
    
    var body: some View {
        VStack {
            Text("Tell us about yourself")
                .font(.headline)
            
            TextEditor(text: $bio)
                .frame(height: 200)
                .border(Color.gray.opacity(0.2))
        }
        .padding()
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

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
} 