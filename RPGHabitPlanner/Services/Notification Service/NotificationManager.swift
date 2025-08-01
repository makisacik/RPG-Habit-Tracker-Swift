//
//  NotificationManager.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 1.08.2025.
//

import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error:", error.localizedDescription)
            } else {
                print(granted ? "Notifications allowed" : "Notifications not allowed")
            }
        }
    }
    
    func scheduleQuestNotification(for quest: Quest) {
        let content = UNMutableNotificationContent()
        content.title = "Traveller, don't forget your quest!"
        content.body = quest.title
        content.sound = .default
        
        let calendar = Calendar.current
        let startDate = quest.creationDate
        let endDate = quest.dueDate
        let notificationTime = DateComponents(hour: 11, minute: 0)
        
        guard endDate > Date() else { return }
        
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
            
        case .everyXWeeks:
            guard let weeks = quest.repeatIntervalWeeks else { return }
            var nextDate = startDate
            while nextDate <= endDate {
                scheduleNotification(id: "\(quest.id.uuidString)_\(nextDate)",
                                     content: content,
                                     date: nextDate,
                                     time: notificationTime)
                nextDate = calendar.date(byAdding: .weekOfYear, value: weeks, to: nextDate)!
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
            
            print("🗑 Removed notifications:", idsToRemove)
        }
    }

}
