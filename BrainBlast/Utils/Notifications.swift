//
//  Notifications.swift
//  AINotes
//
//  Created by Andrew Garcia on 1/9/25.
//

import UserNotifications

class NotificationManager {
    static var hasAskedForPermission: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "hasAskedForPermission")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "hasAskedForPermission")
        }
    }

    static func areNotificationsAuthorized(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            completion(settings.authorizationStatus == .authorized)
        }
    }

    // Function to request permission to notify
    static func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            hasAskedForPermission = true
            completion(granted)
            
//            if granted {
//                Task {
//                    await API.Users.updateNotificationSettings(true)
//                }
//            }
        }
    }
}
