import SwiftUI

struct DiscoverView: View {
    @StateObject private var viewModel = DiscoverViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.suggestions.isEmpty {
                    EmptyStateView(
                        image: "sparkles",
                        title: "No More Suggestions",
                        message: "Check back later for more connection suggestions"
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Current suggestion card
                            if let user = viewModel.suggestions[safe: viewModel.currentIndex] {
                                SwipeableCard(
                                    content: {
                                        UserCard(user: user)
                                    },
                                    onSwipeLeft: {
                                        viewModel.skipUser()
                                    },
                                    onSwipeRight: {
                                        viewModel.sendConnectionRequest(to: user)
                                    }
                                )
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                                .id(user.id)
                            }
                            
                            // Connection tips
                            ConnectionTips()
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Discover")
            .refreshable {
                viewModel.loadSuggestions()
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .loadingOverlay(isLoading: viewModel.isLoading)
        }
    }
}

// MARK: - Supporting Views

struct UserCard: View {
    let user: User
    
    var body: some View {
        VStack(spacing: 0) {
            ImageCarousel(
                urls: user.profileImageURLs,
                aspectRatio: 4/5
            )
            
            // User info
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(user.firstName) \(user.lastName), \(user.age)")
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
                
                if let bio = user.bio {
                    Text(bio)
                        .font(.body)
                }
                
                // Interests
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
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
            .padding()
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 8)
    }
}

struct ConnectionTips: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tips for Connecting")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                TipRow(
                    icon: "person.2.fill",
                    title: "Be Genuine",
                    description: "Share authentic interests and experiences"
                )
                
                TipRow(
                    icon: "message.fill",
                    title: "Start a Conversation",
                    description: "Ask questions about their interests and experiences"
                )
                
                TipRow(
                    icon: "hand.raised.fill",
                    title: "Be Respectful",
                    description: "Maintain professional and courteous communication"
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 8)
    }
}

struct TipRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.accentColor)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
} 