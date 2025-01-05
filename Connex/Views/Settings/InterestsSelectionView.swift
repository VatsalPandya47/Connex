import SwiftUI

struct InterestsSelectionView: View {
    @Binding var selectedInterests: [String]
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    // This would typically come from an API or configuration
    private let availableInterests = [
        "Technology", "Programming", "iOS Development", "SwiftUI",
        "Photography", "Travel", "Reading", "Writing",
        "Music", "Movies", "Sports", "Fitness",
        "Cooking", "Food", "Art", "Design",
        "Nature", "Hiking", "Gaming", "Business"
    ]
    
    private var filteredInterests: [String] {
        if searchText.isEmpty {
            return availableInterests
        }
        return availableInterests.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        List {
            ForEach(filteredInterests, id: \.self) { interest in
                Button {
                    toggleInterest(interest)
                } label: {
                    HStack {
                        Text(interest)
                            .foregroundColor(.primary)
                        Spacer()
                        if selectedInterests.contains(interest) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search interests")
        .navigationTitle("Interests")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
    
    private func toggleInterest(_ interest: String) {
        if let index = selectedInterests.firstIndex(of: interest) {
            selectedInterests.remove(at: index)
        } else {
            selectedInterests.append(interest)
        }
    }
} 