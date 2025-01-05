import SwiftUI

struct RangeSlider: View {
    @Binding var range: ClosedRange<Int>
    let bounds: ClosedRange<Int>
    
    @State private var leftThumbLocation: CGFloat = 0
    @State private var rightThumbLocation: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(height: 4)
                
                // Selected Range
                Rectangle()
                    .fill(Color.accentColor)
                    .frame(width: rightThumbLocation - leftThumbLocation, height: 4)
                    .offset(x: leftThumbLocation)
                
                // Left Thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: 24, height: 24)
                    .shadow(radius: 2)
                    .offset(x: leftThumbLocation - 12)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                updateLeftThumb(value: value, width: geometry.size.width)
                            }
                    )
                
                // Right Thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: 24, height: 24)
                    .shadow(radius: 2)
                    .offset(x: rightThumbLocation - 12)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                updateRightThumb(value: value, width: geometry.size.width)
                            }
                    )
            }
            .onAppear {
                // Initialize thumb locations
                let width = geometry.size.width
                let rangeLength = CGFloat(bounds.upperBound - bounds.lowerBound)
                
                leftThumbLocation = width * CGFloat(range.lowerBound - bounds.lowerBound) / rangeLength
                rightThumbLocation = width * CGFloat(range.upperBound - bounds.lowerBound) / rangeLength
            }
        }
        .frame(height: 24)
    }
    
    private func updateLeftThumb(value: DragGesture.Value, width: CGFloat) {
        let newLocation = max(0, min(rightThumbLocation - 24, value.location.x))
        leftThumbLocation = newLocation
        
        let rangeLength = CGFloat(bounds.upperBound - bounds.lowerBound)
        let newValue = Int(round(Double(bounds.lowerBound) + Double(newLocation) * Double(rangeLength) / Double(width)))
        range = newValue...range.upperBound
    }
    
    private func updateRightThumb(value: DragGesture.Value, width: CGFloat) {
        let newLocation = min(width, max(leftThumbLocation + 24, value.location.x))
        rightThumbLocation = newLocation
        
        let rangeLength = CGFloat(bounds.upperBound - bounds.lowerBound)
        let newValue = Int(round(Double(bounds.lowerBound) + Double(newLocation) * Double(rangeLength) / Double(width)))
        range = range.lowerBound...newValue
    }
} 