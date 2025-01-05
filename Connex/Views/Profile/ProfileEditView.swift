import SwiftUI
import PhotosUI

struct ProfileEditView: View {
    let user: User?
    @StateObject private var viewModel: ProfileEditViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(user: User?) {
        self.user = user
        self._viewModel = StateObject(wrappedValue: ProfileEditViewModel(user: user))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Photos")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.photos.indices, id: \.self) { index in
                                PhotoCell(photo: viewModel.photos[index]) {
                                    viewModel.removePhoto(at: index)
                                }
                            }
                            
                            if viewModel.photos.count < 6 {
                                PhotosPicker(selection: $viewModel.selectedItem) {
                                    AddPhotoCell()
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 120)
                }
                
                Section(header: Text("Basic Information")) {
                    TextField("First Name", text: $viewModel.firstName)
                    TextField("Last Name", text: $viewModel.lastName)
                    TextField("Bio", text: $viewModel.bio)
                        .multilineTextAlignment(.leading)
                }
                
                Section(header: Text("Prompts")) {
                    ForEach(viewModel.prompts.indices, id: \.self) { index in
                        VStack(alignment: .leading) {
                            Menu {
                                ForEach(viewModel.availablePrompts, id: \.self) { prompt in
                                    Button(prompt) {
                                        viewModel.prompts[index].prompt = prompt
                                    }
                                }
                            } label: {
                                Text(viewModel.prompts[index].prompt)
                                    .foregroundColor(.blue)
                            }
                            
                            TextField("Your answer", text: $viewModel.prompts[index].response)
                        }
                    }
                    
                    if viewModel.prompts.count < 3 {
                        Button("Add Prompt") {
                            viewModel.addPrompt()
                        }
                    }
                }
                
                Section(header: Text("Interests")) {
                    ScrollView {
                        FlowLayout(spacing: 8) {
                            ForEach(viewModel.selectedInterests, id: \.self) { interest in
                                InterestTag(
                                    interest: interest,
                                    isSelected: true
                                ) {
                                    viewModel.toggleInterest(interest)
                                }
                            }
                        }
                    }
                    
                    Button("Edit Interests") {
                        viewModel.showInterestsSheet = true
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.saveChanges()
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $viewModel.showInterestsSheet) {
                InterestSelectionView(
                    selectedInterests: $viewModel.selectedInterests,
                    availableInterests: viewModel.availableInterests
                )
            }
        }
    }
}

struct PhotoCell: View {
    let photo: UIImage
    let onDelete: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: photo)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            }
            .padding(4)
        }
    }
}

struct AddPhotoCell: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [5]))
                .frame(width: 100, height: 100)
            
            Image(systemName: "plus")
                .font(.title)
                .foregroundColor(.gray)
        }
    }
} 