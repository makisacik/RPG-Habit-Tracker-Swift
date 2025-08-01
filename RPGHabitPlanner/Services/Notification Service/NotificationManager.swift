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
                print("❌ Notification permission error:", error.localizedDescription)
            } else {
                print(granted ? "✅ Notifications allowed" : "⚠️ Notifications not allowed")
            }
        }
    }
    
    func scheduleQuestNotification(for quest: Quest) {
        let content = UNMutableNotificationContent()
        content.title = quest.title
        content.body = quest.info.isEmpty ? "Your quest is due!" : quest.info
        content.sound = .default
        
        let trigger: UNNotificationTrigger?
        
        switch quest.repeatType {
        case .oneTime:
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: quest.dueDate)
            trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
        case .daily:
            let components = Calendar.current.dateComponents([.hour, .minute], from: quest.dueDate)
            trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            
        case .weekly:
            let components = Calendar.current.dateComponents([.weekday, .hour, .minute], from: quest.dueDate)
            trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            
        case .everyXWeeks:
            guard let weeks = quest.repeatIntervalWeeks else { return }
            let seconds = weeks * 7 * 24 * 60 * 60
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds), repeats: true)
        }
        
        let request = UNNotificationRequest(identifier: quest.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule notification:", error.localizedDescription)
            } else {
                print("📅 Notification scheduled for quest:", quest.title)
            }
        }
    }
    
    func cancelQuestNotification(id: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
    }
}
