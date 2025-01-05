import SwiftUI

struct InterestSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedInterests: [String]
    let availableInterests: [String]
    
    // Minimum required interests before saving
    private let minimumInterests = 3
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header Text
                VStack(spacing: 8) {
                    Text("Select Your Interests")
                        .font(.title2)
                        .bold()
                    
                    Text("Choose at least \(minimumInterests) interests to help find meaningful connections")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)
                
                // Selected Interests Count
                Text("\(selectedInterests.count) selected")
                    .foregroundColor(.gray)
                    .font(.subheadline)
                
                // Interests Grid
                ScrollView {
                    FlowLayout(spacing: 12) {
                        ForEach(availableInterests, id: \.self) { interest in
                            InterestTag(
                                interest: interest,
                                isSelected: selectedInterests.contains(interest)
                            ) {
                                toggleInterest(interest)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .disabled(selectedInterests.count < minimumInterests)
                }
            }
        }
    }
    
    private func toggleInterest(_ interest: String) {
        if selectedInterests.contains(interest) {
            selectedInterests.removeAll { $0 == interest }
        } else {
            selectedInterests.append(interest)
        }
    }
}

// Preview Provider
struct InterestSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        InterestSelectionView(
            selectedInterests: .constant(["Travel", "Photography"]),
            availableInterests: [
                "Travel", "Photography", "Cooking", "Fitness",
                "Reading", "Music", "Art", "Technology"
            ]
        )
    }
} 