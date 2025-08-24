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
        
        // Calculate missed days from the day after last check until today
        let checkStartDate = calendar.date(byAdding: .day, value: 1, to: startDate) ?? startDate
        let missedDays = calendar.dateComponents([.day], from: checkStartDate, to: endDate).day ?? 0
        
        // Only count days that are after the due date and not completed
        var actualMissedDays = 0
        var currentDate = checkStartDate
        
        while currentDate <= endDate {
            let dayStart = calendar.startOfDay(for: currentDate)
            
            // Only count if the day is after due date and quest wasn't completed on that day
            if dayStart > dueDate && !quest.completions.contains(dayStart) {
                actualMissedDays += 1
            }
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        let damageAmount = actualMissedDays * QuestDamageConstants.dailyQuestDamagePerDay
        let reason = "Daily quest '\(quest.title)' missed \(actualMissedDays) day(s)"
        
        return DamageCalculationResult(
            damageAmount: damageAmount,
            missedDays: actualMissedDays,
            reason: reason,
            lastCheckDate: startDate
        )
    }
    
    private func calculateWeeklyQuestDamage(
        quest: Quest,
        startDate: Date,
        endDate: Date
    ) -> DamageCalculationResult {
        let calendar = Calendar.current
        let dueDate = calendar.startOfDay(for: quest.dueDate)
        
        // Check if quest is overdue since last check
        let isOverdue = dueDate < endDate && !quest.isCompleted
        
        let damageAmount = isOverdue ? QuestDamageConstants.weeklyQuestDamage : 0
        let reason = isOverdue ? "Weekly quest '\(quest.title)' is overdue" : "Weekly quest '\(quest.title)' is not overdue"
        
        return DamageCalculationResult(
            damageAmount: damageAmount,
            missedDays: isOverdue ? 1 : 0,
            reason: reason,
            lastCheckDate: startDate
        )
    }
    
    private func calculateOneTimeQuestDamage(
        quest: Quest,
        startDate: Date,
        endDate: Date
    ) -> DamageCalculationResult {
        let calendar = Calendar.current
        let dueDate = calendar.startOfDay(for: quest.dueDate)
        
        // Check if quest is still overdue since last check
        let isStillOverdue = dueDate < endDate && !quest.isCompleted
        
        let damageAmount = isStillOverdue ? QuestDamageConstants.oneTimeQuestDamage : 0
        let reason = isStillOverdue ? "One-time quest '\(quest.title)' is still overdue" : "One-time quest '\(quest.title)' is not overdue"
        
        return DamageCalculationResult(
            damageAmount: damageAmount,
            missedDays: isStillOverdue ? 1 : 0,
            reason: reason,
            lastCheckDate: startDate
        )
    }
    
    private func calculateScheduledQuestDamage(
        quest: Quest,
        startDate: Date,
        endDate: Date
    ) -> DamageCalculationResult {
        let calendar = Calendar.current
        
        // Calculate missed scheduled days from the day after last check until today
        let checkStartDate = calendar.date(byAdding: .day, value: 1, to: startDate) ?? startDate
        var missedScheduledDays = 0
        var currentDate = checkStartDate
        
        while currentDate <= endDate {
            let dayStart = calendar.startOfDay(for: currentDate)
            let weekday = calendar.component(.weekday, from: dayStart)
            
            // Check if this day is a scheduled day and quest wasn't completed
            if quest.scheduledDays.contains(weekday) && !quest.completions.contains(dayStart) {
                missedScheduledDays += 1
            }
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        let damageAmount = missedScheduledDays * QuestDamageConstants.scheduledQuestDamagePerDay
        let reason = "Scheduled quest '\(quest.title)' missed \(missedScheduledDays) scheduled day(s)"
        
        return DamageCalculationResult(
            damageAmount: damageAmount,
            missedDays: missedScheduledDays,
            reason: reason,
            lastCheckDate: startDate
        )
    }
}
