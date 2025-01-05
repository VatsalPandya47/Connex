import SwiftUI

struct ImageCarousel: View {
    let urls: [URL]
    let aspectRatio: CGFloat
    @State private var currentIndex = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $currentIndex) {
                ForEach(Array(urls.enumerated()), id: \.element) { index, url in
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color(.systemGray6)
                            .overlay {
                                ProgressView()
                            }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // Custom page indicator
            if urls.count > 1 {
                HStack(spacing: 8) {
                    ForEach(0..<urls.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentIndex ? Color.white : Color.white.opacity(0.5))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut, value: currentIndex)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.3))
                )
                .padding(.bottom, 8)
            }
        }
        .aspectRatio(aspectRatio, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// Now we can update the UserCard to use this component: 