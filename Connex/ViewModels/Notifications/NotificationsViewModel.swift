import Foundation
import Combine

class NotificationsViewModel: ObservableObject {
    @Published private(set) var notifications: [Notification] = []
    
    private let notificationService = NotificationService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        notificationService.$notifications
            .assign(to: &$notifications)
    }
    
    func loadNotifications() {
        notificationService.loadNotifications()
    }
    
    func markAsRead(_ notificationId: String) {
        notificationService.markAsRead(notificationId)
    }
    
    func markAllAsRead() {
        notificationService.markAllAsRead()
    }
} 