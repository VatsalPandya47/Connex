import Foundation
import UserNotifications
import Combine

class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    private let notificationCenter = UNUserNotificationCenter.current()
    
    @Published private(set) var isAuthorized = false
    
    override init() {
        super.init()
        notificationCenter.delegate = self
        checkAuthorizationStatus()
    }
    
    func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.isAuthorized = granted
            }
            if let error = error {
                print("Notification authorization error: \(error)")
            }
        }
    }
    
    private func checkAuthorizationStatus() {
        notificationCenter.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func scheduleNotification(title: String, body: String, userInfo: [AnyHashable: Any] = [:]) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.userInfo = userInfo
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func handleRemoteNotification(_ userInfo: [AnyHashable: Any]) {
        // Parse notification payload and handle different types
        guard let type = userInfo["type"] as? String else { return }
        
        switch type {
        case "newMessage":
            if let conversationId = userInfo["conversationId"] as? String {
                NotificationCenter.default.post(
                    name: .newMessageReceived,
                    object: nil,
                    userInfo: ["conversationId": conversationId]
                )
            }
        case "newConnection":
            if let userId = userInfo["userId"] as? String {
                NotificationCenter.default.post(
                    name: .newConnectionReceived,
                    object: nil,
                    userInfo: ["userId": userId]
                )
            }
        case "momentLike":
            if let momentId = userInfo["momentId"] as? String {
                NotificationCenter.default.post(
                    name: .momentLikeReceived,
                    object: nil,
                    userInfo: ["momentId": momentId]
                )
            }
        default:
            break
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        handleRemoteNotification(response.notification.request.content.userInfo)
        completionHandler()
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let newMessageReceived = Notification.Name("newMessageReceived")
    static let newConnectionReceived = Notification.Name("newConnectionReceived")
    static let momentLikeReceived = Notification.Name("momentLikeReceived")
} 