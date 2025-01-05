import SwiftUI

struct InterestsPageView: View {
    @State private var selectedInterests: Set<String> = []
    
    let availableInterests = [
        "Travel", "Photography", "Cooking", "Fitness",
        "Reading", "Music", "Art", "Technology",
        "Sports", "Movies", "Gaming", "Nature"
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            Text("What are you interested in?")
                .font(.title2)
                .bold()
            
            Text("Select at least 3 interests")
                .foregroundColor(.gray)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(availableInterests, id: \.self) { interest in
                    InterestTag(
                        interest: interest,
                        isSelected: selectedInterests.contains(interest),
                        action: { toggleInterest(interest) }
                    )
                }
            }
            .padding()
        }
    }
    
    private func toggleInterest(_ interest: String) {
        if selectedInterests.contains(interest) {
            selectedInterests.remove(interest)
        } else {
            selectedInterests.insert(interest)
        }
    }
}

struct InterestTag: View {
    let interest: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Text(interest)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color.gray.opacity(0.1))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
            .onTapGesture(perform: action)
    }
} 