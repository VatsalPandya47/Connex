import SwiftUI

struct LoadingView: View {
    let message: String
    
    var body: some View {
        VStack {
            ProgressView()
            Text(message)
        }
    }
}

struct LoadingOverlay: ViewModifier {
    let isLoading: Bool
    let message: String
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isLoading {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                LoadingView(message: message)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(radius: 8)
                    )
                    .padding(32)
            }
        }
    }
}

extension View {
    func loadingOverlay(isLoading: Bool, message: String = "Loading...") -> some View {
        modifier(LoadingOverlay(isLoading: isLoading, message: message))
    }
} 