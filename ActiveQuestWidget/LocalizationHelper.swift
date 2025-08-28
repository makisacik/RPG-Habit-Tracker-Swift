//
//  LocalizationHelper.swift
//  ActiveQuestWidget
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import Foundation

/// Simple localization helper for widget extensions
struct LocalizationHelper {
    /// Localizes a string using the widget's bundle
    /// - Parameter key: The localization key
    /// - Returns: Localized string or the key if not found
    static func localized(_ key: String) -> String {
        return NSLocalizedString(key, bundle: Bundle.main, comment: "")
    }

    /// Localizes a string with format arguments
    /// - Parameters:
    ///   - key: The localization key
    ///   - arguments: Format arguments
    /// - Returns: Localized and formatted string
    static func localized(_ key: String, arguments: CVarArg...) -> String {
        let format = NSLocalizedString(key, bundle: Bundle.main, comment: "")
        return String(format: format, arguments: arguments)
    }
}

// MARK: - Widget-specific localization keys
extension LocalizationHelper {
    // Focus Timer related
    static let remaining = "remaining"
    static let focusTimer = "focus_timer"
    static let percentComplete = "percent_complete"
    static let complete = "complete"

    // Widget specific
    static let activeQuest = "active_quest"
    static let noActiveQuests = "no_active_quests"
    static let allQuestsCompleted = "all_quests_completed"
    static let startYourAdventure = "start_your_adventure"
    static let createYourFirstQuest = "create_your_first_quest"
    static let overdue = "overdue"
    static let dueToday = "due_today"
    static let dueTomorrow = "due_tomorrow"
    static let daysLeft = "days_left"
    static let untitledQuest = "untitled_quest"
    
    // Daily Quest Summary Widget
    static let dailyQuests = "daily_quests"
    static let questsCompleted = "quests_completed"
    static let moreQuests = "more_quests"
    static let dailyQuestSummary = "daily_quest_summary"
    static let dailyQuestWidgetDescription = "daily_quest_widget_description"
}
