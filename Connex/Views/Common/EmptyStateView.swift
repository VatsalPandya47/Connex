import SwiftUI

struct EmptyStateView: View {
    let image: String
    let title: String
    let message: String
    var action: (() -> Void)?
    var actionTitle: String?
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: image)
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if let action = action, let actionTitle = actionTitle {
                Button(action: action) {
                    Text(actionTitle)
                        .fontWeight(.semibold)
                }
                .primaryButton()
                .padding(.top)
            }
        }
        .padding()
    }
}

#Preview {
    EmptyStateView(
        image: "sparkles",
        title: "No Results Found",
        message: "Try adjusting your filters or check back later",
        action: {},
        actionTitle: "Refresh"
    )
} 