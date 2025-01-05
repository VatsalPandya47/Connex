import SwiftUI

struct RangeSlider: View {
    @Binding var range: ClosedRange<Double>
    let bounds: ClosedRange<Double>
    
    init(range: Binding<ClosedRange<Double>>, in bounds: ClosedRange<Double>) {
        self._range = range
        self.bounds = bounds
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 4)
                
                // Selected Range
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: width(for: range, in: geometry), height: 4)
                    .offset(x: position(for: range.lowerBound, in: geometry))
                
                // Lower Handle
                handle(for: range.lowerBound, in: geometry)
                    .gesture(dragGesture(for: \.lowerBound, in: geometry))
                
                // Upper Handle
                handle(for: range.upperBound, in: geometry)
                    .gesture(dragGesture(for: \.upperBound, in: geometry))
            }
        }
        .frame(height: 30)
    }
    
    private func handle(for value: Double, in geometry: GeometryProxy) -> some View {
        Circle()
            .fill(Color.white)
            .frame(width: 24, height: 24)
            .shadow(radius: 4)
            .offset(x: position(for: value, in: geometry))
    }
    
    private func position(for value: Double, in geometry: GeometryProxy) -> CGFloat {
        let percentage = (value - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound)
        return (geometry.size.width - 24) * CGFloat(percentage)
    }
    
    private func width(for range: ClosedRange<Double>, in geometry: GeometryProxy) -> CGFloat {
        let lowerPercentage = (range.lowerBound - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound)
        let upperPercentage = (range.upperBound - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound)
        return (geometry.size.width - 24) * CGFloat(upperPercentage - lowerPercentage)
    }
    
    private func dragGesture(for bound: WritableKeyPath<ClosedRange<Double>, Double>, in geometry: GeometryProxy) -> some Gesture {
        DragGesture()
            .onChanged { value in
                let percentage = value.location.x / (geometry.size.width - 24)
                let newValue = bounds.lowerBound + (bounds.upperBound - bounds.lowerBound) * Double(percentage)
                let clampedValue = max(bounds.lowerBound, min(bounds.upperBound, newValue))
                
                if bound == \.lowerBound {
                    range = min(clampedValue, range.upperBound - 1)...range.upperBound
                } else {
                    range = range.lowerBound...max(clampedValue, range.lowerBound + 1)
                }
            }
    }
} 