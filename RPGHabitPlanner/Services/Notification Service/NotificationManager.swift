//
//  NotificationManager.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 1.08.2025.
//

import Foundation
import UserNotifications
import UIKit

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    func scheduleQuestNotification(for quest: Quest) {
        let content = UNMutableNotificationContent()
        content.title = "quest_reminder_title".localized
        content.body = quest.title
        content.sound = .default

        let calendar = Calendar.current
        let startDate = quest.creationDate
        let endDate = quest.dueDate
        let notificationTime = DateComponents(hour: 11, minute: 0)

        // guard endDate >= Date() else { return }

        switch quest.repeatType {
        case .oneTime:
            if let afterCreation = calendar.date(byAdding: .day, value: 1, to: startDate) {
                scheduleNotification(id: quest.id.uuidString + "_afterCreation",
                                     content: content,
                                     date: afterCreation,
                                     time: notificationTime)
            }

            if let beforeDue = calendar.date(byAdding: .day, value: -1, to: endDate) {
                scheduleNotification(id: quest.id.uuidString + "_beforeDue",
                                     content: content,
                                     date: beforeDue,
                                     time: notificationTime)
            }

        case .daily:
            var nextDate = startDate
            while nextDate <= endDate {
                scheduleNotification(id: "\(quest.id.uuidString)_\(nextDate)",
                                     content: content,
                                     date: nextDate,
                                     time: notificationTime)
                nextDate = calendar.date(byAdding: .day, value: 1, to: nextDate)!
            }

        case .weekly:
            var nextDate = startDate
            while nextDate <= endDate {
                scheduleNotification(id: "\(quest.id.uuidString)_\(nextDate)",
                                     content: content,
                                     date: nextDate,
                                     time: notificationTime)
                nextDate = calendar.date(byAdding: .weekOfYear, value: 1, to: nextDate)!
            }
        case .scheduled:
            // For scheduled quests, schedule notifications only on the specified days
            var nextDate = startDate
            while nextDate <= endDate {
                let weekday = calendar.component(.weekday, from: nextDate)
                if quest.scheduledDays.contains(weekday) {
                    scheduleNotification(id: "\(quest.id.uuidString)_\(nextDate)",
                                         content: content,
                                         date: nextDate,
                                         time: notificationTime)
                }
                nextDate = calendar.date(byAdding: .day, value: 1, to: nextDate)!
            }
        }
    }

    private func scheduleNotification(id: String, content: UNMutableNotificationContent, date: Date, time: DateComponents) {
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
        dateComponents.hour = time.hour
        dateComponents.minute = time.minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule:", error.localizedDescription)
            } else {
                print("Scheduled notification:", id)
            }
        }
    }

    func cancelQuestNotifications(questId: UUID) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let idsToRemove = requests
                .map { $0.identifier }
                .filter { $0.hasPrefix(questId.uuidString) }

            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: idsToRemove)

            print("Removed notifications:", idsToRemove)
        }
    }


    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error:", error.localizedDescription)
            }
            completion(granted)
        }
    }

    func checkAndRequestPermission(shouldRequestIfDenied: Bool = false, completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestPermission(completion: completion)
            case .denied:
                if shouldRequestIfDenied {
                    self.requestPermission(completion: completion)
                } else {
                    completion(false)
                }
            case .authorized, .provisional, .ephemeral:
                completion(true)
            @unknown default:
                completion(false)
            }
        }
    }

    func handleNotificationForQuest(_ quest: Quest, enabled: Bool) {
        if enabled {
            checkAndRequestPermission(shouldRequestIfDenied: true) { granted in
                if granted {
                    self.scheduleQuestNotification(for: quest)
                } else {
                    print(" Notifications not granted for quest:", quest.title)
                }
            }
        } else {
            cancelQuestNotifications(questId: quest.id)
        }
    }

    // MARK: - First Quest Notification Permission

    func requestPermissionForFirstQuest(completion: @escaping (Bool) -> Void) {
        // Check if this is the first quest
        let hasCreatedQuestBefore = UserDefaults.standard.bool(forKey: "hasCreatedQuestBefore")

        if !hasCreatedQuestBefore {
            // This is the first quest, check current status first
            checkAndRequestPermission(shouldRequestIfDenied: false) { granted in
                DispatchQueue.main.async {
                    if granted {
                        // Already has permission, mark as created and continue
                        UserDefaults.standard.set(true, forKey: "hasCreatedQuestBefore")
                        completion(true)
                    } else {
                        // No permission yet, will be handled by custom bottom sheet
                        completion(false)
                    }
                }
            }
        } else {
            // Not the first quest, just check current status
            checkAndRequestPermission(shouldRequestIfDenied: false, completion: completion)
        }
    }
    
    func shouldShowCustomNotificationPrompt() -> Bool {
        // Check if this is the first quest and user hasn't been asked yet
        let hasCreatedQuestBefore = UserDefaults.standard.bool(forKey: "hasCreatedQuestBefore")
        let hasShownCustomPrompt = UserDefaults.standard.bool(forKey: "hasShownCustomNotificationPrompt")
        
        return !hasCreatedQuestBefore && !hasShownCustomPrompt
    }
    
    func markCustomNotificationPromptShown() {
        UserDefaults.standard.set(true, forKey: "hasShownCustomNotificationPrompt")
    }

    // MARK: - Settings Helper

    func getNotificationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }

    func openNotificationSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}
