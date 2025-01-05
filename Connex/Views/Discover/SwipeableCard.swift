import SwiftUI

struct SwipeableCard<Content: View>: View {
    let content: Content
    let onSwipeLeft: () -> Void
    let onSwipeRight: () -> Void
    
    @State private var offset = CGSize.zero
    @State private var initialOffset = CGSize.zero
    
    init(
        @ViewBuilder content: () -> Content,
        onSwipeLeft: @escaping () -> Void,
        onSwipeRight: @escaping () -> Void
    ) {
        self.content = content()
        self.onSwipeLeft = onSwipeLeft
        self.onSwipeRight = onSwipeRight
    }
    
    var body: some View {
        content
            .offset(x: offset.width, y: 0)
            .rotationEffect(.degrees(Double(offset.width / 20)))
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        offset = CGSize(
                            width: initialOffset.width + gesture.translation.width,
                            height: 0
                        )
                    }
                    .onEnded { gesture in
                        let width = gesture.translation.width
                        let threshold: CGFloat = 100
                        
                        if width > threshold {
                            withAnimation(.spring()) {
                                offset.width = 500
                            }
                            onSwipeRight()
                        } else if width < -threshold {
                            withAnimation(.spring()) {
                                offset.width = -500
                            }
                            onSwipeLeft()
                        } else {
                            withAnimation(.spring()) {
                                offset = .zero
                            }
                        }
                    }
            )
    }
} 