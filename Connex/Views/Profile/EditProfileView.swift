import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: EditProfileViewModel
    
    init(user: User) {
        _viewModel = StateObject(wrappedValue: EditProfileViewModel(user: user))
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Profile Images
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.images.indices, id: \.self) { index in
                                ProfileImageItem(
                                    image: viewModel.images[index],
                                    onDelete: {
                                        viewModel.removeImage(at: index)
                                    }
                                )
                            }
                            
                            if viewModel.images.count < 6 {
                                PhotosPicker(
                                    selection: $viewModel.selectedItem,
                                    matching: .images
                                ) {
                                    AddImageButton()
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("Profile Photos")
                } footer: {
                    Text("Add up to 6 photos")
                }
                
                // Basic Info
                Section("Basic Information") {
                    TextField("First Name", text: $viewModel.firstName)
                    TextField("Last Name", text: $viewModel.lastName)
                    TextField("Headline", text: $viewModel.headline)
                    TextField("Bio", text: $viewModel.bio, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                // Location
                Section("Location") {
                    TextField("City", text: $viewModel.city)
                    TextField("Country", text: $viewModel.country)
                }
                
                // Interests
                Section("Interests") {
                    ForEach(viewModel.interests, id: \.self) { interest in
                        HStack {
                            Text(interest)
                            Spacer()
                            Button {
                                viewModel.removeInterest(interest)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    HStack {
                        TextField(
                            "Add interest",
                            text: $viewModel.newInterest
                        )
                        
                        Button("Add") {
                            viewModel.addInterest()
                        }
                        .disabled(viewModel.newInterest.isEmpty)
                    }
                }
                
                // Profile Prompts
                Section("Profile Prompts") {
                    ForEach(viewModel.prompts.indices, id: \.self) { index in
                        VStack(alignment: .leading) {
                            Text(viewModel.prompts[index].question)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextField(
                                "Your answer",
                                text: $viewModel.prompts[index].answer
                            )
                        }
                    }
                    
                    Button("Add Prompt") {
                        viewModel.addPrompt()
                    }
                    .disabled(viewModel.prompts.count >= 3)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await viewModel.saveProfile()
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.hasChanges)
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .loadingOverlay(
                isLoading: viewModel.isLoading,
                message: "Saving changes..."
            )
        }
    }
}

// MARK: - Supporting Views

struct ProfileImageItem: View {
    let image: UIImage
    let onDelete: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.5))
                    )
            }
            .padding(4)
        }
    }
}

struct AddImageButton: View {
    var body: some View {
        VStack {
            Image(systemName: "plus.circle.fill")
                .font(.title)
            Text("Add Photo")
                .font(.caption)
        }
        .foregroundColor(.accentColor)
        .frame(width: 100, height: 100)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
} 