import SwiftUI

struct DiscoverView: View {
    @StateObject private var viewModel = DiscoverViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.potentialConnections.isEmpty {
                    EmptyStateView()
                } else {
                    ConnectionCardStack(
                        connections: viewModel.potentialConnections,
                        onLike: viewModel.handleLike,
                        onPass: viewModel.handlePass
                    )
                }
            }
            .navigationTitle("Discover")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: viewModel.showFilters) {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
            }
        }
    }
}

struct ConnectionCardStack: View {
    let connections: [User]
    let onLike: (User) -> Void
    let onPass: (User) -> Void
    
    var body: some View {
        ZStack {
            ForEach(connections) { user in
                ConnectionCard(user: user)
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                if value.translation.width > 100 {
                                    onLike(user)
                                } else if value.translation.width < -100 {
                                    onPass(user)
                                }
                            }
                    )
            }
        }
    }
} 