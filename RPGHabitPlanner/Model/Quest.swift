//
//  QuestProtocol.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 30.10.2024.
//

import Foundation

enum QuestRepeatType: String, Codable {
    case oneTime
    case daily
    case weekly
    case scheduled
    
    var localizedTitle: String {
        switch self {
        case .oneTime:
            return "one_time".localized
        case .daily:
            return "daily".localized
        case .weekly:
            return "weekly".localized
        case .scheduled:
            return "scheduled".localized
        }
    }
}

struct Quest: Identifiable, Equatable {
    let id: UUID
    var title: String
    var isMainQuest: Bool
    var info: String
    var difficulty: Int
    let creationDate: Date
    var dueDate: Date
    var isActive: Bool
    var progress: Int
    var isCompleted: Bool
    var completionDate: Date?
    var isFinished: Bool
    var isFinishedDate: Date?
    var tasks: [QuestTask]
    var repeatType: QuestRepeatType
    var completions: Set<Date>
    var tags: Set<Tag>
    var showProgress: Bool
    var scheduledDays: Set<Int> // Days of week (1 = Sunday, 2 = Monday, ..., 7 = Saturday)
    var reminderTimes: Set<Date> // Times when reminders should be sent (30 minutes before)
    var enableReminders: Bool // Whether reminders are enabled for this quest

    init(
        id: UUID = UUID(),
        title: String,
        isMainQuest: Bool,
        info: String,
        difficulty: Int,
        creationDate: Date,
        dueDate: Date,
        isActive: Bool,
        progress: Int,
        isCompleted: Bool = false,
        completionDate: Date? = nil,
        isFinished: Bool = false,
        isFinishedDate: Date? = nil,
        tasks: [QuestTask] = [],
        repeatType: QuestRepeatType = .oneTime,
        completions: Set<Date> = [],
        tags: Set<Tag> = [],
        showProgress: Bool = false,
        scheduledDays: Set<Int> = [],
        reminderTimes: Set<Date> = [],
        enableReminders: Bool = false
    ) {
        self.id = id
        self.title = title
        self.isMainQuest = isMainQuest
        self.info = info
        self.difficulty = difficulty
        self.creationDate = creationDate
        self.dueDate = dueDate
        self.isActive = isActive
        self.progress = progress
        self.isCompleted = isCompleted
        self.completionDate = completionDate
        self.isFinished = isFinished
        self.isFinishedDate = isFinishedDate
        self.tasks = tasks
        self.repeatType = repeatType
        self.completions = completions
        self.tags = tags
        self.showProgress = showProgress
        self.scheduledDays = scheduledDays
        self.reminderTimes = reminderTimes
        self.enableReminders = enableReminders
    }
}

extension Quest {
    func isCompleted(on date: Date, calendar: Calendar = .current) -> Bool {
        switch repeatType {
        case .oneTime:
            // For one-time quests, if they are completed at the due date, they show as completed for all dates
            let dueDateAnchor = calendar.startOfDay(for: dueDate)
            let isCompleted = completions.contains(dueDateAnchor)
            print("🔍 Quest '\(title)' isCompleted(on: \(date)) one-time: dueDateAnchor = \(dueDateAnchor), isCompleted = \(isCompleted)")
            return isCompleted
        case .daily:
            let dateAnchor = calendar.startOfDay(for: date)
            let isCompleted = completions.contains(dateAnchor)
            print("🔍 Quest '\(title)' isCompleted(on: \(date)) daily: dateAnchor = \(dateAnchor), isCompleted = \(isCompleted)")
            return isCompleted
        case .weekly:
            // For weekly quests, check if the week anchor is in completions
            let weekAnchor = weekAnchor(for: date, calendar: calendar)
            let isCompleted = completions.contains(weekAnchor)
            print("🔍 Quest '\(title)' isCompleted(on: \(date)) weekly: weekAnchor = \(weekAnchor), isCompleted = \(isCompleted)")
            return isCompleted
        case .scheduled:
            // For scheduled quests, check if completed on this specific date
            let dateAnchor = calendar.startOfDay(for: date)
            let isCompleted = completions.contains(dateAnchor)
            print("🔍 Quest '\(title)' isCompleted(on: \(date)) scheduled: dateAnchor = \(dateAnchor), isCompleted = \(isCompleted)")
            return isCompleted
        }
    }

    func isCompletedThisWeek(asOf date: Date, calendar: Calendar = .current) -> Bool {
        let weekAnchor = weekAnchor(for: date, calendar: calendar)
        return completions.contains(weekAnchor)
    }

    private func weekAnchor(for date: Date, calendar: Calendar = .current) -> Date {
        let comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        let start = calendar.date(from: comps) ?? date
        return calendar.startOfDay(for: start)
    }

    func isActive(on date: Date, calendar: Calendar = .current) -> Bool {
        // If quest is marked as finished, it's not active
        if isFinished {
            print("❌ Quest '\(title)' is finished, not active")
            return false
        }

        let today = calendar.startOfDay(for: date)
        print("🔍 Checking if quest '\(title)' is active on \(today)")

        switch repeatType {
        case .oneTime:
            // For one-time quests, check if due date is in the past
            if dueDate < today {
                print("❌ Quest '\(title)' due date \(dueDate) is in the past")
                return false
            }
            // Check if completed at the due date anchor
            let dueDateAnchor = calendar.startOfDay(for: dueDate)
            let isCompletedAtDueDate = completions.contains(dueDateAnchor)
            print("🔍 Quest '\(title)' one-time: dueDateAnchor = \(dueDateAnchor), isCompletedAtDueDate = \(isCompletedAtDueDate)")
            return !isCompletedAtDueDate
        case .daily:
            // For daily quests, they're active on any day they haven't been completed
            let isCompletedToday = isCompleted(on: today, calendar: calendar)
            print("🔍 Quest '\(title)' daily: isCompletedToday = \(isCompletedToday)")
            return !isCompletedToday
        case .weekly:
            // For weekly quests, they're active on any week they haven't been completed
            let isCompletedThisWeek = isCompletedThisWeek(asOf: today, calendar: calendar)
            print("🔍 Quest '\(title)' weekly: isCompletedThisWeek = \(isCompletedThisWeek)")
            return !isCompletedThisWeek
        case .scheduled:
            // For scheduled quests, they're active if the date is in scheduledDays and not completed
            let weekday = calendar.component(.weekday, from: date)
            let isScheduledDay = scheduledDays.contains(weekday)
            let isCompletedToday = isCompleted(on: date, calendar: calendar)
            print("🔍 Quest '\(title)' scheduled: weekday = \(weekday), isScheduledDay = \(isScheduledDay), isCompletedToday = \(isCompletedToday)")
            return isScheduledDay && !isCompletedToday
        }
    }

    /// Determines if this completion should trigger the finish confirmation popup
    func shouldShowFinishConfirmation(on date: Date, calendar: Calendar = .current) -> Bool {
        switch repeatType {
        case .oneTime:
            // Always show for one-time quests when completed
            return true
        case .daily:
            // Show if this is the last day of the quest (due date)
            let today = calendar.startOfDay(for: date)
            let dueDate = calendar.startOfDay(for: self.dueDate)
            return today >= dueDate
        case .weekly:
            // Show if this is the last week of the quest (due date week)
            let today = calendar.startOfDay(for: date)
            let dueDate = calendar.startOfDay(for: self.dueDate)
            let todayWeek = weekAnchor(for: today, calendar: calendar)
            let dueDateWeek = weekAnchor(for: dueDate, calendar: calendar)
            return todayWeek >= dueDateWeek
        case .scheduled:
            // Show if this is the last scheduled day of the quest (due date)
            let today = calendar.startOfDay(for: date)
            let dueDate = calendar.startOfDay(for: self.dueDate)
            return today >= dueDate
        }
    }
}
