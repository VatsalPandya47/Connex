import SwiftUI

struct ConnectionCard: View {
    let user: User
    @State private var offset: CGSize = .zero
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Profile Image
            AsyncImage(url: user.profileImageURLs.first) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
            }
            .frame(height: 400)
            .clipped()
            
            // User Info
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(user.firstName) \(user.lastName)")
                        .font(.title2)
                        .bold()
                    
                    if user.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.blue)
                    }
                }
                
                if let bio = user.bio {
                    Text(bio)
                        .foregroundColor(.gray)
                }
                
                // Interests Tags
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(user.interests, id: \.self) { interest in
                            Text(interest)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(16)
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 5)
        .offset(offset)
        .rotationEffect(.degrees(Double(offset.width) * 0.1))
        .animation(.interactiveSpring(), value: offset)
    }
} 