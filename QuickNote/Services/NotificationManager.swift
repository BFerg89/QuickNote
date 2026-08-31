//
//  NotificationManager.swift
//  QuickNote
//
//  Created by Bennett Ferguson on 2026-08-30.
//

import Foundation
import UserNotifications

final class NotificationManager {
    static let manager = NotificationManager()

    func requestAuthorization() async -> Bool {
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: options)
        } catch {
            print("Error: \(error)")
            return false
        }
    }

    func isAuthorized() async -> Bool {
        let settings = await UNUserNotificationCenter.current()
            .notificationSettings()

        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined, .denied:
            return false
        @unknown default:
            return false
        }
    }
}
