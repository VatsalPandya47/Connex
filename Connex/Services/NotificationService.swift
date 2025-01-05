import Foundation
import Combine
import UserNotifications

class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    @Published private(set) var notifications: [Notification] = []
    @Published private(set) var unreadCount = 0
    
    private let networkService = NetworkService.shared
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupPushNotifications()
        loadNotifications()
    }
    
    private func setupPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func loadNotifications() {
        networkService.makeRequest(endpoint: .notifications)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] (notifications: [Notification]) in
                    self?.notifications = notifications
                    self?.updateUnreadCount()
                }
            )
            .store(in: &cancellables)
    }
    
    func markAsRead(_ notificationId: String) {
        networkService.makeRequest(endpoint: .markNotificationRead(notificationId))
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] (notification: Notification) in
                    self?.updateNotification(notification)
                }
            )
            .store(in: &cancellables)
    }
    
    func markAllAsRead() {
        networkService.makeRequest(endpoint: .markAllNotificationsRead)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in
                    self?.notifications = self?.notifications.map { notification in
                        var updatedNotification = notification
                        updatedNotification.isRead = true
                        return updatedNotification
                    } ?? []
                    self?.updateUnreadCount()
                }
            )
            .store(in: &cancellables)
    }
    
    private func updateNotification(_ notification: Notification) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index] = notification
            updateUnreadCount()
        }
    }
    
    private func updateUnreadCount() {
        unreadCount = notifications.filter { !$0.isRead }.count
        UIApplication.shared.applicationIconBadgeNumber = unreadCount
    }
    
    func handlePushNotification(_ userInfo: [AnyHashable: Any]) {
        guard let notificationData = try? JSONSerialization.data(withJSONObject: userInfo),
              let notification = try? JSONDecoder().decode(Notification.self, from: notificationData) else {
            return
        }
        
        notifications.insert(notification, at: 0)
        updateUnreadCount()
    }
} 