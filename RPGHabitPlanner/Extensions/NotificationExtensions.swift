//
//  NotificationExtensions.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 18.08.2025.
//

import Foundation

// MARK: - Quest Update Notifications
extension Notification.Name {
    static let questUpdated = Notification.Name("questUpdated")
    static let questDeleted = Notification.Name("questDeleted")
    static let questCreated = Notification.Name("questCreated")
    static let questCompletedFromDetail = Notification.Name("questCompletedFromDetail")
}
