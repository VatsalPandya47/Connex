import SwiftUI

struct ProfileView: View {
    let user: User
    @StateObject private var viewModel: ProfileViewModel
    @State private var showEditProfile = false
    
    init(user: User) {
        self.user = user
        _viewModel = StateObject(wrappedValue: ProfileViewModel(user: user))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile header
                ProfileHeader(user: user)
                
                // Bio and interests
                VStack(alignment: .leading, spacing: 16) {
                    if let bio = user.bio {
                        Text(bio)
                            .font(.body)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Interests")
                            .font(.headline)
                        
                        FlowLayout(spacing: 8) {
                            ForEach(user.interests, id: \.self) { interest in
                                Text(interest)
                                    .font(.subheadline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(16)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Profile prompts
                VStack(spacing: 16) {
                    Text("About Me")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ForEach(user.profilePrompts, id: \.question) { prompt in
                        ProfilePromptCard(prompt: prompt)
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if viewModel.isCurrentUser {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showEditProfile = true
                    } label: {
                        Image(systemName: "pencil")
                    }
                }
            }
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView(user: user)
        }
    }
}

struct ProfileHeader: View {
    let user: User
    
    var body: some View {
        VStack(spacing: 16) {
            // Profile image
            if let profileImageURL = user.profileImageURLs.first {
                AsyncImage(url: profileImageURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color(.systemGray6)
                }
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 1)
                )
            }
            
            // User info
            VStack(spacing: 4) {
                Text("\(user.firstName) \(user.lastName)")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                if let headline = user.headline {
                    Text(headline)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.secondary)
                    Text("\(user.location.city), \(user.location.country)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }
}

struct ProfilePromptCard: View {
    let prompt: User.ProfilePrompt
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(prompt.question)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Text(prompt.answer)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct FlowLayout: Layout {
    let spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.width ?? 0,
            spacing: spacing,
            subviews: subviews
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            spacing: spacing,
            subviews: subviews
        )
        
        for (index, subview) in subviews.enumerated() {
            let point = result.points[index]
            subview.place(at: point, proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        let size: CGSize
        let points: [CGPoint]
        
        init(in width: CGFloat, spacing: CGFloat, subviews: Subviews) {
            var height: CGFloat = 0
            var row: CGFloat = 0
            var x: CGFloat = 0
            
            var points: [CGPoint] = []
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > width {
                    // Move to next row
                    x = 0
                    row += 1
                }
                
                points.append(CGPoint(x: x, y: row * (size.height + spacing)))
                height = max(height, (row + 1) * (size.height + spacing))
                x += size.width + spacing
            }
            
            self.points = points
            self.size = CGSize(width: width, height: height)
        }
    }
} 