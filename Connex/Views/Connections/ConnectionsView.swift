import SwiftUI

struct ConnectionsView: View {
    @StateObject private var viewModel = ConnectionsViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom segmented control
                Picker("", selection: $selectedTab) {
                    Text("Connections").tag(0)
                    Text("Requests (\(viewModel.pendingRequests.count))").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                TabView(selection: $selectedTab) {
                    // Active connections
                    ConnectionsList(
                        connections: viewModel.connections,
                        onBlock: viewModel.blockUser
                    )
                    .tag(0)
                    
                    // Pending requests
                    RequestsList(
                        requests: viewModel.pendingRequests,
                        onAccept: viewModel.acceptConnection,
                        onDecline: viewModel.declineConnection
                    )
                    .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("Network")
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

struct ConnectionsList: View {
    let connections: [Connection]
    let onBlock: (String) -> Void
    
    var body: some View {
        List {
            if connections.isEmpty {
                EmptyStateView(
                    image: "person.2",
                    title: "No Connections",
                    message: "Start connecting with others to grow your network"
                )
            } else {
                ForEach(connections) { connection in
                    ConnectionRow(connection: connection, onBlock: onBlock)
                }
            }
        }
        .listStyle(.plain)
    }
}

struct RequestsList: View {
    let requests: [Connection]
    let onAccept: (String) -> Void
    let onDecline: (String) -> Void
    
    var body: some View {
        List {
            if requests.isEmpty {
                EmptyStateView(
                    image: "person.badge.plus",
                    title: "No Pending Requests",
                    message: "You don't have any connection requests at the moment"
                )
            } else {
                ForEach(requests) { request in
                    RequestRow(
                        request: request,
                        onAccept: onAccept,
                        onDecline: onDecline
                    )
                }
            }
        }
        .listStyle(.plain)
    }
}

struct ConnectionRow: View {
    let connection: Connection
    let onBlock: (String) -> Void
    @State private var showBlockAlert = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile image
            AsyncImage(url: connection.user.profileImageURLs.first) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color(.systemGray6)
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            // User info
            VStack(alignment: .leading, spacing: 4) {
                Text("\(connection.user.firstName) \(connection.user.lastName)")
                    .font(.headline)
                
                if let headline = connection.user.headline {
                    Text(headline)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Actions menu
            Menu {
                NavigationLink {
                    ProfileView(user: connection.user)
                } label: {
                    Label("View Profile", systemImage: "person")
                }
                
                NavigationLink {
                    ChatView(conversation: Conversation(participants: [connection.user]))
                } label: {
                    Label("Message", systemImage: "bubble.left")
                }
                
                Button(role: .destructive) {
                    showBlockAlert = true
                } label: {
                    Label("Block", systemImage: "slash.circle")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
        .alert("Block User", isPresented: $showBlockAlert) {
            Button("Block", role: .destructive) {
                onBlock(connection.otherUserId)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to block this user? They will no longer be able to contact you.")
        }
    }
}

struct RequestRow: View {
    let request: Connection
    let onAccept: (String) -> Void
    let onDecline: (String) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile image
            AsyncImage(url: request.user.profileImageURLs.first) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color(.systemGray6)
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            // User info
            VStack(alignment: .leading, spacing: 4) {
                Text("\(request.user.firstName) \(request.user.lastName)")
                    .font(.headline)
                
                if let headline = request.user.headline {
                    Text(headline)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 8) {
                Button {
                    onDecline(request.id)
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.secondary)
                        .frame(width: 40, height: 40)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
                
                Button {
                    onAccept(request.id)
                } label: {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.accentColor)
                        .clipShape(Circle())
                }
            }
        }
        .padding(.vertical, 4)
    }
} 