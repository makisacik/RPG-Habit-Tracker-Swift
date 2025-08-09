//
//  QuestLogService.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 9.08.2025.
//

import Foundation
import CoreData

extension QuestEntity {
    var repeatKind: QuestRepeatType { QuestRepeatType(rawValue: repeatType) ?? .oneTime }
}

final class QuestLogService {
    private let context: NSManagedObjectContext
    private let calendar = Calendar.current

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func markCompleted(_ quest: QuestEntity, on date: Date = .now) throws {
        let anchor: Date
        switch quest.repeatKind {
        case .daily:
            anchor = dayAnchor(date, calendar: calendar)
        case .weekly:
            anchor = weekAnchor(date, calendar: calendar)
        case .oneTime:
            anchor = dayAnchor(date, calendar: calendar)
        }

        if try fetchCompletion(quest: quest, on: anchor) != nil { return }
        
        let completion = QuestCompletionEntity(context: context)
        completion.id = UUID()
        completion.date = anchor
        completion.quest = quest
        quest.isCompleted = true
        quest.completionDate = date
        try context.save()
    }

    func unmarkCompleted(_ quest: QuestEntity, on date: Date = .now) throws {
        let anchor: Date
        switch quest.repeatKind {
        case .daily:
            anchor = dayAnchor(date, calendar: calendar)
        case .weekly:
            anchor = weekAnchor(date, calendar: calendar)
        case .oneTime:
            anchor = dayAnchor(date, calendar: calendar)
        }

        if let existingCompletion = try fetchCompletion(quest: quest, on: anchor) {
            context.delete(existingCompletion)
            quest.isCompleted = false
            try context.save()
        }
    }


    func isCompleted(_ quest: QuestEntity, on date: Date = .now) throws -> Bool {
        let anchor: Date
        switch quest.repeatKind {
        case .daily:
            anchor = dayAnchor(date, calendar: calendar)
        case .weekly:
            anchor = weekAnchor(date, calendar: calendar)
        case .oneTime:
            anchor = dayAnchor(date, calendar: calendar)
        }
        return try fetchCompletion(quest: quest, on: anchor) != nil
    }

    func completedCount(_ quest: QuestEntity, from startDate: Date, to endDate: Date) throws -> Int {
        let startOfStartDate = calendar.startOfDay(for: startDate)
        let startOfEndDate = calendar.startOfDay(for: endDate)
        let request: NSFetchRequest<QuestCompletionEntity> = QuestCompletionEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "quest == %@ AND date >= %@ AND date <= %@",
            quest, startOfStartDate as NSDate, startOfEndDate as NSDate
        )
        return try context.count(for: request)
    }

    func completionDates(_ quest: QuestEntity, from startDate: Date, to endDate: Date) throws -> [Date] {
        let startOfStartDate = calendar.startOfDay(for: startDate)
        let startOfEndDate = calendar.startOfDay(for: endDate)
        let request: NSFetchRequest<QuestCompletionEntity> = QuestCompletionEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "quest == %@ AND date >= %@ AND date <= %@",
            quest, startOfStartDate as NSDate, startOfEndDate as NSDate
        )
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        return try context.fetch(request).map { $0.date }
    }

    func currentStreak(_ quest: QuestEntity, asOf date: Date = .now) throws -> Int {
        var streak = 0
        var currentDay = calendar.startOfDay(for: date)
        while try isCompleted(quest, on: currentDay) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDay) else { break }
            currentDay = previousDay
        }
        return streak
    }

    func isCompletedThisWeek(_ quest: QuestEntity, asOf date: Date = .now) throws -> Bool {
        let weekAnchor = weekAnchor(date, calendar: calendar)
        return try fetchCompletion(quest: quest, on: weekAnchor) != nil
    }

    func refreshState(for quest: QuestEntity, on date: Date = .now) throws {
        if let due = quest.dueDate, date > due {
            quest.isActive = false
            quest.isCompleted = true
            try context.save()
            return
        }
        switch quest.repeatKind {
        case .oneTime:
            quest.isActive = !(quest.isCompleted)
        case .daily:
            let doneToday = try isCompleted(quest, on: date)
            quest.isCompleted = doneToday
            quest.isActive = !doneToday
        case .weekly:
            let doneThisWeek = try isCompletedThisWeek(quest, asOf: date)
            quest.isCompleted = doneThisWeek
            quest.isActive = !doneThisWeek
        }
        try context.save()
    }

    func refreshAll(on date: Date = .now) throws {
        let request: NSFetchRequest<QuestEntity> = QuestEntity.fetchRequest()
        let quests = try context.fetch(request)
        for quest in quests {
            try refreshState(for: quest, on: date)
        }
    }

    private func fetchCompletion(quest: QuestEntity, on day: Date) throws -> QuestCompletionEntity? {
        let request: NSFetchRequest<QuestCompletionEntity> = QuestCompletionEntity.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "quest == %@ AND date == %@", quest, day as NSDate)
        return try context.fetch(request).first
    }
}
