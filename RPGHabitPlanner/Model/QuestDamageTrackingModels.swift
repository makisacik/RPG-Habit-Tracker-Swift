//
//  QuestDamageTrackingModels.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import Foundation

// MARK: - Damage Tracking Models

struct QuestDamageTracker: Identifiable, Equatable {
    let id: UUID
    let questId: UUID
    var lastDamageCheckDate: Date
    var totalDamageTaken: Int
    var damageHistory: [DamageEvent]
    var isActive: Bool
    
    init(
        id: UUID = UUID(),
        questId: UUID,
        lastDamageCheckDate: Date = Date(),
        totalDamageTaken: Int = 0,
        damageHistory: [DamageEvent] = [],
        isActive: Bool = true
    ) {
        self.id = id
        self.questId = questId
        self.lastDamageCheckDate = lastDamageCheckDate
        self.totalDamageTaken = totalDamageTaken
        self.damageHistory = damageHistory
        self.isActive = isActive
    }
}

struct DamageEvent: Identifiable, Equatable {
    let id: UUID
    let date: Date
    let damageAmount: Int
    let reason: String
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        damageAmount: Int,
        reason: String
    ) {
        self.id = id
        self.date = date
        self.damageAmount = damageAmount
        self.reason = reason
    }
}

// MARK: - Damage Calculation Constants

enum QuestDamageConstants {
    static let dailyQuestDamagePerDay = 3
    static let weeklyQuestDamage = 8
    static let oneTimeQuestDamage = 10
    static let scheduledQuestDamagePerDay = 5
    static let maxDamagePerSession = 12  // Maximum damage that can be taken in one session
}

// MARK: - Damage Calculation Result

struct DamageCalculationResult {
    let damageAmount: Int
    let missedDays: Int
    let reason: String
    let lastCheckDate: Date
    let newLastCheckDate: Date
    
    init(
        damageAmount: Int,
        missedDays: Int,
        reason: String,
        lastCheckDate: Date,
        newLastCheckDate: Date = Date()
    ) {
        self.damageAmount = damageAmount
        self.missedDays = missedDays
        self.reason = reason
        self.lastCheckDate = lastCheckDate
        self.newLastCheckDate = newLastCheckDate
    }
}

// MARK: - Quest Type Damage Calculation

enum QuestTypeDamageCalculator {
    case daily
    case weekly
    case oneTime
    case scheduled
    
    func calculateDamage(
        quest: Quest,
        lastDamageCheckDate: Date,
        currentDate: Date = Date()
    ) -> DamageCalculationResult {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: lastDamageCheckDate)
        let endDate = calendar.startOfDay(for: currentDate)
        
        switch self {
        case .daily:
            return calculateDailyQuestDamage(
                quest: quest,
                startDate: startDate,
                endDate: endDate
            )
        case .weekly:
            return calculateWeeklyQuestDamage(
                quest: quest,
                startDate: startDate,
                endDate: endDate
            )
        case .oneTime:
            return calculateOneTimeQuestDamage(
                quest: quest,
                startDate: startDate,
                endDate: endDate
            )
        case .scheduled:
            return calculateScheduledQuestDamage(
                quest: quest,
                startDate: startDate,
                endDate: endDate
            )
        }
    }
    
    private func calculateDailyQuestDamage(
        quest: Quest,
        startDate: Date,
        endDate: Date
    ) -> DamageCalculationResult {
        let calendar = Calendar.current
        let dueDate = calendar.startOfDay(for: quest.dueDate)
        
        // Add 1 day grace period to due date
        let gracePeriodDate = calendar.date(byAdding: .day, value: 1, to: dueDate) ?? dueDate

        // Calculate missed days from the day after last check until today
        let checkStartDate = calendar.date(byAdding: .day, value: 1, to: startDate) ?? startDate
        var actualMissedDays = 0
        var currentDate = checkStartDate
        
        while currentDate <= endDate {
            let dayStart = calendar.startOfDay(for: currentDate)
            
            // Only count if the day is after grace period date
            if dayStart > gracePeriodDate {
                // Once overdue, only check for overdue damage, not completion
                actualMissedDays += 1
            }
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        let damageAmount = actualMissedDays * QuestDamageConstants.dailyQuestDamagePerDay
        let reason = String(format: "daily_quest_missed_reason".localized, quest.title, actualMissedDays)
        
        return DamageCalculationResult(
            damageAmount: damageAmount,
            missedDays: actualMissedDays,
            reason: reason,
            lastCheckDate: endDate  // Fix: Use endDate as the new last check date
        )
    }
    
    private func calculateWeeklyQuestDamage(
        quest: Quest,
        startDate: Date,
        endDate: Date
    ) -> DamageCalculationResult {
        let calendar = Calendar.current
        let dueDate = calendar.startOfDay(for: quest.dueDate)
        
        // Add 1 day grace period to due date
        let gracePeriodDate = calendar.date(byAdding: .day, value: 1, to: dueDate) ?? dueDate

        // Calculate missed weeks from the day after last check until today
        let checkStartDate = calendar.date(byAdding: .day, value: 1, to: startDate) ?? startDate
        var missedWeeks = 0
        var currentDate = checkStartDate
        
        while currentDate <= endDate {
            let dayStart = calendar.startOfDay(for: currentDate)
            
            // Only check weeks that are after the grace period date
            if dayStart > gracePeriodDate {
                // Get the week that just ended (previous week)
                let previousWeekStart = calendar.date(byAdding: .weekOfYear, value: -1, to: dayStart) ?? dayStart
                let weekAnchor = weekAnchor(for: previousWeekStart, calendar: calendar)
                
                // Check if this previous week is the due date week or later
                let dueDateWeekAnchor = self.weekAnchor(for: dueDate, calendar: calendar)
                if weekAnchor >= dueDateWeekAnchor {
                    // Once overdue, only check for overdue damage, not completion
                    missedWeeks += 1
                }
            }
            
            // Move to next week
            currentDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate) ?? currentDate
        }
        
        let damageAmount = missedWeeks * QuestDamageConstants.weeklyQuestDamage
        let reason = missedWeeks > 0 ? String(format: "weekly_quest_missed_reason".localized, quest.title, missedWeeks) : String(format: "weekly_quest_not_overdue_reason".localized, quest.title)
        
        return DamageCalculationResult(
            damageAmount: damageAmount,
            missedDays: missedWeeks,
            reason: reason,
            lastCheckDate: endDate  // Fix: Use endDate as the new last check date
        )
    }
    
    private func weekAnchor(for date: Date, calendar: Calendar = .current) -> Date {
        let comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        let start = calendar.date(from: comps) ?? date
        return calendar.startOfDay(for: start)
    }
    
    private func calculateOneTimeQuestDamage(
        quest: Quest,
        startDate: Date,
        endDate: Date
    ) -> DamageCalculationResult {
        let calendar = Calendar.current
        let dueDate = calendar.startOfDay(for: quest.dueDate)
        
        // Add 1 day grace period to due date
        let gracePeriodDate = calendar.date(byAdding: .day, value: 1, to: dueDate) ?? dueDate

        // Check if quest is still overdue since last check (after grace period)
        let isStillOverdue = gracePeriodDate < endDate
        
        let damageAmount = isStillOverdue ? QuestDamageConstants.oneTimeQuestDamage : 0
        let reason = isStillOverdue ? String(format: "one_time_quest_overdue_reason".localized, quest.title) : String(format: "one_time_quest_not_overdue_reason".localized, quest.title)
        
        return DamageCalculationResult(
            damageAmount: damageAmount,
            missedDays: isStillOverdue ? 1 : 0,
            reason: reason,
            lastCheckDate: endDate  // Fix: Use endDate as the new last check date
        )
    }
    
    private func calculateScheduledQuestDamage(
        quest: Quest,
        startDate: Date,
        endDate: Date
    ) -> DamageCalculationResult {
        let calendar = Calendar.current
        
        // Add 1 day grace period to due date
        let dueDate = calendar.startOfDay(for: quest.dueDate)
        let gracePeriodDate = calendar.date(byAdding: .day, value: 1, to: dueDate) ?? dueDate
        
        // Calculate missed scheduled days from the day after last check until today
        let checkStartDate = calendar.date(byAdding: .day, value: 1, to: startDate) ?? startDate
        var missedScheduledDays = 0
        var currentDate = checkStartDate
        
        while currentDate <= endDate {
            let dayStart = calendar.startOfDay(for: currentDate)
            let weekday = calendar.component(.weekday, from: dayStart)
            
            // Check if this day is a scheduled day AND quest wasn't completed AND after grace period
            if quest.scheduledDays.contains(weekday) &&
               !quest.completions.contains(dayStart) &&
               dayStart > gracePeriodDate {
                missedScheduledDays += 1
            }
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        let damageAmount = missedScheduledDays * QuestDamageConstants.scheduledQuestDamagePerDay
        let reason = missedScheduledDays > 0 ?
            String(format: "scheduled_quest_missed_reason".localized, quest.title, missedScheduledDays) :
            String(format: "scheduled_quest_not_overdue_reason".localized, quest.title)
        
        return DamageCalculationResult(
            damageAmount: damageAmount,
            missedDays: missedScheduledDays,
            reason: reason,
            lastCheckDate: endDate  // Fix: Use endDate as the new last check date
        )
    }
}
