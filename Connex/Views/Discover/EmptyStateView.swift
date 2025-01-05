import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No More Profiles")
                .font(.title2)
                .bold()
            
            Text("Check back later for new potential connections")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
} 