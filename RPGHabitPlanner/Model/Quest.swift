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
    var tasks: [QuestTask]
    var repeatType: QuestRepeatType
    var completions: Set<Date>

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
        tasks: [QuestTask] = [],
        repeatType: QuestRepeatType = .oneTime,
        completions: Set<Date> = []
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
        self.tasks = tasks
        self.repeatType = repeatType
        self.completions = completions
    }
}

extension Quest {
    func isCompleted(on date: Date, calendar: Calendar = .current) -> Bool {
        completions.contains(calendar.startOfDay(for: date))
    }

    func isCompletedThisWeek(asOf date: Date, calendar: Calendar = .current) -> Bool {
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)),
              let range = calendar.range(of: .day, in: .weekOfYear, for: date),
              let endOfWeek = calendar.date(byAdding: .day, value: range.count - 1, to: startOfWeek)
        else { return false }
        let days = stride(from: 0, through: (range.count - 1), by: 1).compactMap {
            calendar.date(byAdding: .day, value: $0, to: startOfWeek).map { calendar.startOfDay(for: $0) }
        }
        return (days.contains { completions.contains($0) }) &&
               date >= startOfWeek &&
               date <= endOfWeek
    }

    func isActive(on date: Date, calendar: Calendar = .current) -> Bool {
        let today = calendar.startOfDay(for: date)
        if dueDate < today { return false }
        switch repeatType {
        case .oneTime:
            return !isCompleted
        case .daily:
            return !isCompleted(on: today, calendar: calendar)
        case .weekly:
            return !isCompletedThisWeek(asOf: today, calendar: calendar)
        }
    }
}
