//
//  NotificationManager.swift
//  QuickNote
//
//  Created by Bennett Ferguson on 2026-08-30.
//

import Foundation
import SwiftData
import UserNotifications

final class NotificationManager {
    static let manager = NotificationManager()
    static let enabledPreferenceKey = "notifications_enabled"

    private var notificationsEnabled: Bool {
        UserDefaults.standard.bool(forKey: Self.enabledPreferenceKey)
    }

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

    //Fix later for the case of user turning notifications off and on
    func cancelAllPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func cancelPendingNotification(note: Note) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["note-\(note.createdAt.timeIntervalSince1970)"])
    }

    //Assumes the supplied note has dueDate != nil
    func scheduleNotification(note: Note) async {
        guard notificationsEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = note.title ?? "Jots"
        content.body = note.processedText ?? note.rawText

        let calendar = Calendar.current
        let now = Date()

        guard let fireDate = notificationDate(
            for: note,
            calendar: calendar,
            now: now
        ) else { return }

        let dateComponents = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: fireDate
        )

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: false
        )

        let identifier = "note-\(note.createdAt.timeIntervalSince1970)"

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        do {
            let center = UNUserNotificationCenter.current()
            try await center.add(request)

            if !notificationsEnabled || note.isDeleted || note.dueDate == nil {
                center.removePendingNotificationRequests(
                    withIdentifiers: [identifier]
                )
            }
        } catch {
            print("Failed to schedule notification: \(error)")
        }
    }

    private func notificationDate(
        for note: Note,
        calendar: Calendar,
        now: Date
    ) -> Date? {
        if let dueTime = note.dueTime {
            return dueTime > now ? dueTime : nil
        }

        guard let dueDate = note.dueDate,
              let defaultDate = calendar.date(
                bySettingHour: 9,
                minute: 0,
                second: 0,
                of: dueDate
              ) else {
            return nil
        }

        if defaultDate > now {
            return defaultDate
        }

        guard calendar.isDate(dueDate, inSameDayAs: now),
              let midnight = calendar.date(
                byAdding: .day,
                value: 1,
                to: calendar.startOfDay(for: dueDate)
              ) else {
            return nil
        }

        let remainingFromCreation = midnight.timeIntervalSince(note.createdAt)
        guard remainingFromCreation > 0 else { return nil }

        let fallbackDate = note.createdAt.addingTimeInterval(
            remainingFromCreation / 3
        )

        return fallbackDate > now ? fallbackDate : nil
    }
}
