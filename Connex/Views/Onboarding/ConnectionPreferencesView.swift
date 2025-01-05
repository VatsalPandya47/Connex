import SwiftUI

struct ConnectionPreferencesView: View {
    @State private var selectedTypes: Set<User.ConnectionType> = []
    @State private var maxDistance: Double = 50
    @State private var ageRange: ClosedRange<Double> = 18...100
    
    var body: some View {
        VStack(spacing: 24) {
            Text("What are you looking for?")
                .font(.title2)
                .bold()
            
            // Connection Types
            VStack(alignment: .leading, spacing: 12) {
                Text("I'm interested in:")
                    .font(.headline)
                
                ForEach(User.ConnectionType.allCases, id: \.self) { type in
                    ConnectionTypeRow(
                        type: type,
                        isSelected: selectedTypes.contains(type),
                        action: { toggleType(type) }
                    )
                }
            }
            
            // Distance Slider
            VStack(alignment: .leading, spacing: 8) {
                Text("Maximum Distance")
                    .font(.headline)
                
                HStack {
                    Slider(value: $maxDistance, in: 1...100)
                    Text("\(Int(maxDistance)) km")
                }
            }
            
            // Age Range Slider
            VStack(alignment: .leading, spacing: 8) {
                Text("Age Range")
                    .font(.headline)
                
                RangeSlider(range: $ageRange, in: 18...100)
                
                Text("\(Int(ageRange.lowerBound)) - \(Int(ageRange.upperBound)) years")
            }
        }
        .padding()
    }
    
    private func toggleType(_ type: User.ConnectionType) {
        if selectedTypes.contains(type) {
            selectedTypes.remove(type)
        } else {
            selectedTypes.insert(type)
        }
    }
}

struct ConnectionTypeRow: View {
    let type: User.ConnectionType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(type.rawValue.capitalized)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3))
            )
        }
        .foregroundColor(.primary)
    }
} 