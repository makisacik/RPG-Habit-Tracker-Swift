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
        showProgress: Bool = false
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
    }
}

extension Quest {
    func isCompleted(on date: Date, calendar: Calendar = .current) -> Bool {
        switch repeatType {
        case .oneTime:
            // For one-time quests, if they are completed at the due date, they show as completed for all dates
            let dueDateAnchor = calendar.startOfDay(for: dueDate)
            return completions.contains(dueDateAnchor)
        case .daily, .weekly:
            return completions.contains(calendar.startOfDay(for: date))
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
        if isFinished { return false }

        let today = calendar.startOfDay(for: date)

        switch repeatType {
        case .oneTime:
            // For one-time quests, check if due date is in the past
            if dueDate < today { return false }
            // Check if completed at the due date anchor
            let dueDateAnchor = calendar.startOfDay(for: dueDate)
            return !completions.contains(dueDateAnchor)
        case .daily:
            // For daily quests, they're active on any day they haven't been completed
            return !isCompleted(on: today, calendar: calendar)
        case .weekly:
            // For weekly quests, they're active on any week they haven't been completed
            return !isCompletedThisWeek(asOf: today, calendar: calendar)
        }
    }
}
