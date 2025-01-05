import SwiftUI

struct FilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedInterests: Set<String>
    @Binding var maxDistance: Double
    
    let availableInterests = [
        "Travel", "Photography", "Cooking", "Fitness",
        "Reading", "Music", "Art", "Technology",
        "Sports", "Movies", "Gaming", "Fashion"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Distance") {
                    VStack {
                        Slider(value: $maxDistance, in: 1...100, step: 1) {
                            Text("Maximum Distance")
                        }
                        
                        HStack {
                            Text("Within")
                            Spacer()
                            Text("\(Int(maxDistance)) km")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("Interests") {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 8) {
                            ForEach(availableInterests, id: \.self) { interest in
                                InterestToggle(
                                    title: interest,
                                    isSelected: selectedInterests.contains(interest)
                                ) {
                                    if selectedInterests.contains(interest) {
                                        selectedInterests.remove(interest)
                                    } else {
                                        selectedInterests.insert(interest)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        selectedInterests.removeAll()
                        maxDistance = 50
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct InterestToggle: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.accentColor : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
} 