import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            // Progress bar
            ProgressBar(currentStep: viewModel.currentStep, totalSteps: 3)
                .padding(.top)
            
            // Step content
            ScrollView {
                switch viewModel.currentStep {
                case 0:
                    InterestsSelectionView(
                        selectedInterests: $viewModel.selectedInterests,
                        availableInterests: viewModel.availableInterests
                    )
                case 1:
                    ProfilePhotoView(
                        selectedImage: $viewModel.selectedProfileImage,
                        showImagePicker: $viewModel.showImagePicker
                    )
                case 2:
                    BioAndPromptsView(
                        bio: $viewModel.bio,
                        selectedPrompts: $viewModel.selectedPrompts,
                        availablePrompts: viewModel.availablePrompts
                    )
                default:
                    EmptyView()
                }
            }
            
            Spacer()
            
            // Navigation buttons
            navigationButtons
        }
        .padding()
        .navigationTitle("Complete Your Profile")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
        .sheet(isPresented: $viewModel.showImagePicker) {
            ImagePicker(selectedImage: $viewModel.selectedProfileImage)
        }
    }
    
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            if viewModel.currentStep > 0 {
                Button("Back") {
                    withAnimation {
                        viewModel.currentStep -= 1
                    }
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            
            Button(viewModel.currentStep == 2 ? "Complete" : "Next") {
                if viewModel.currentStep == 2 {
                    viewModel.completeOnboarding { success in
                        if success {
                            dismiss()
                        }
                    }
                } else {
                    withAnimation {
                        viewModel.proceedToNextStep()
                    }
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(!viewModel.canProceed || viewModel.isLoading)
        }
    }
}

struct InterestsSelectionView: View {
    @Binding var selectedInterests: [String]
    let availableInterests: [String]
    
    var body: some View {
        VStack(spacing: 24) {
            Text("What are your interests?")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Select at least 3 interests to help us find better matches for you")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(availableInterests, id: \.self) { interest in
                    InterestButton(
                        title: interest,
                        isSelected: selectedInterests.contains(interest)
                    ) {
                        if selectedInterests.contains(interest) {
                            selectedInterests.removeAll { $0 == interest }
                        } else {
                            selectedInterests.append(interest)
                        }
                    }
                }
            }
        }
        .padding(.vertical)
    }
}

struct InterestButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color(.systemGray6))
                .cornerRadius(20)
        }
    }
}

struct ProfilePhotoView: View {
    @Binding var selectedImage: UIImage?
    @Binding var showImagePicker: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Add a profile photo")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Add a photo that clearly shows your face")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.accentColor, lineWidth: 2))
                
                Button("Change Photo") {
                    showImagePicker = true
                }
                .buttonStyle(SecondaryButtonStyle())
            } else {
                Button {
                    showImagePicker = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color(.systemGray6))
                            .frame(width: 200, height: 200)
                        
                        Image(systemName: "camera.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.accentColor)
                    }
                }
            }
        }
        .padding(.vertical)
    }
}

// Continue with BioAndPromptsView in the next message... 