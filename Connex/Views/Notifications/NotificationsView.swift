import SwiftUI

struct NotificationsView: View {
    @StateObject private var viewModel = NotificationsViewModel()
    
    var body: some View {
        NavigationView {
            List {
                if viewModel.notifications.isEmpty {
                    EmptyStateView(
                        image: "bell",
                        title: "No Notifications",
                        message: "You're all caught up!"
                    )
                } else {
                    ForEach(viewModel.notifications) { notification in
                        NotificationRow(notification: notification)
                            .onAppear {
                                if !notification.isRead {
                                    viewModel.markAsRead(notification.id)
                                }
                            }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Notifications")
            .toolbar {
                if !viewModel.notifications.isEmpty {
                    Button("Mark All Read") {
                        viewModel.markAllAsRead()
                    }
                }
            }
            .refreshable {
                viewModel.loadNotifications()
            }
        }
    }
}

struct NotificationRow: View {
    let notification: Notification
    
    var body: some View {
        NavigationLink {
            destinationView
        } label: {
            HStack(spacing: 12) {
                // Notification icon or user image
                if let imageURL = notification.data.imageURL {
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color(.systemGray6)
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                } else {
                    Image(systemName: iconName)
                        .font(.title2)
                        .foregroundColor(.accentColor)
                        .frame(width: 50, height: 50)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(notification.data.title)
                        .font(.headline)
                    
                    Text(notification.data.body)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if !notification.isRead {
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    private var iconName: String {
        switch notification.type {
        case .connectionRequest:
            return "person.badge.plus"
        case .connectionAccepted:
            return "checkmark.circle"
        case .newMessage:
            return "bubble.left"
        }
    }
    
    @ViewBuilder
    private var destinationView: some View {
        switch notification.type {
        case .connectionRequest, .connectionAccepted:
            if let userId = notification.data.metadata["userId"] {
                ProfileView(userId: userId)
            }
        case .newMessage:
            if let conversationId = notification.data.metadata["conversationId"] {
                ChatView(conversationId: conversationId)
            }
        }
    }
} 