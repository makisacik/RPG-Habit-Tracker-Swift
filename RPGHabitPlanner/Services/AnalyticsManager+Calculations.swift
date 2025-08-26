//
//  AnalyticsManager+Calculations.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 27.07.2025.
//

import Foundation

// MARK: - AnalyticsManager Calculations Extension

extension AnalyticsManager {
    // MARK: - Calculation Helper Methods
    
    func calculateAverageCompletionTime(quests: [Quest]) -> TimeInterval {
        let finishedQuests = quests.filter { $0.isFinished && $0.completionDate != nil }
        guard !finishedQuests.isEmpty else { return 0 }
        
        let totalTime = finishedQuests.reduce(0.0) { total, quest in
            guard let completionDate = quest.completionDate else { return total }
            return total + completionDate.timeIntervalSince(quest.creationDate)
        }
        
        return totalTime / Double(finishedQuests.count)
    }
    
    func calculateMostProductiveHour(quests: [Quest]) -> Int {
        let finishedQuests = quests.filter { $0.isFinished && $0.completionDate != nil }
        guard !finishedQuests.isEmpty else { return 12 }
        
        var hourCounts: [Int: Int] = [:]
        for quest in finishedQuests {
            guard let completionDate = quest.completionDate else { continue }
            let hour = calendar.component(.hour, from: completionDate)
            hourCounts[hour, default: 0] += 1
        }
        
        return hourCounts.max { $0.value < $1.value }?.key ?? 12
    }
    
    func calculatePreferredDifficulty(quests: [Quest]) -> Int {
        guard !quests.isEmpty else { return 2 }
        
        var difficultyCounts: [Int: Int] = [:]
        for quest in quests {
            difficultyCounts[quest.difficulty, default: 0] += 1
        }
        
        return difficultyCounts.max { $0.value < $1.value }?.key ?? 2
    }
    
    func calculateStreakAnalytics() -> StreakAnalytics {
        let currentStreak = streakManager.currentStreak
        let longestStreak = streakManager.longestStreak
        
        // For now, return basic streak data
        // This can be enhanced when more detailed streak tracking is implemented
        return StreakAnalytics(
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            averageStreakLength: Double(longestStreak),
            streakBreakPatterns: [],
            bestStreakDay: calendar.component(.weekday, from: Date())
        )
    }
    
    func calculateWeeklyTrends(quests: [Quest]) -> [WeeklyTrend] {
        // Calculate trends for the last 4 weeks
        let endDate = Date()
        let startDate = calendar.date(byAdding: .weekOfYear, value: -4, to: endDate) ?? endDate
        
        var trends: [WeeklyTrend] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            let weekStart = calendar.dateInterval(of: .weekOfYear, for: currentDate)?.start ?? currentDate
            let weekEnd = calendar.dateInterval(of: .weekOfYear, for: currentDate)?.end ?? currentDate
            
            let weekQuests = quests.filter { quest in
                quest.creationDate >= weekStart && quest.creationDate < weekEnd
            }
            
            let weekFinishedQuests = weekQuests.filter { $0.isFinished }
            let completionRate = weekQuests.isEmpty ? 0.0 : Double(weekFinishedQuests.count) / Double(weekQuests.count)
            let averageDifficulty = weekQuests.isEmpty ? 0.0 : Double(weekQuests.reduce(0) { $0 + $1.difficulty }) / Double(weekQuests.count)
            
            trends.append(WeeklyTrend(
                weekStartDate: weekStart,
                questsCreated: weekQuests.count,
                questsCompleted: weekFinishedQuests.count,
                completionRate: completionRate,
                averageDifficulty: averageDifficulty
            ))
            
            currentDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate) ?? currentDate
        }
        
        return trends
    }
    
    func calculateDifficultySuccessRates(quests: [Quest]) -> [Int: Double] {
        var difficultyStats: [Int: (total: Int, completed: Int)] = [:]
        
        for quest in quests {
            let stats = difficultyStats[quest.difficulty, default: (0, 0)]
            difficultyStats[quest.difficulty] = (stats.total + 1, stats.completed + (quest.isFinished ? 1 : 0))
        }
        
        return difficultyStats.mapValues { stats in
            stats.total == 0 ? 0.0 : Double(stats.completed) / Double(stats.total)
        }
    }
    
    func calculateExperienceProgress(user: UserEntity) -> Double {
        let currentLevel = Int(user.level)
        let currentExp = Int(user.exp)
        let expForCurrentLevel = calculateExperienceForLevel(currentLevel)
        let expForNextLevel = calculateExperienceForLevel(currentLevel + 1)
        let expNeeded = expForNextLevel - expForCurrentLevel
        let expProgress = currentExp - expForCurrentLevel
        
        return expNeeded == 0 ? 1.0 : Double(expProgress) / Double(expNeeded)
    }
    
    func calculateExperienceToNextLevel(currentLevel: Int) -> Int {
        let expForCurrentLevel = calculateExperienceForLevel(currentLevel)
        let expForNextLevel = calculateExperienceForLevel(currentLevel + 1)
        return expForNextLevel - expForCurrentLevel
    }
    
    func calculateExperienceForLevel(_ level: Int) -> Int {
        // Simple experience formula: 100 * level^2
        return 100 * level * level
    }
    
    func calculateLevelUpRate(user: UserEntity) -> Double {
        // For now, return a default rate
        // This can be enhanced when level history tracking is implemented
        return 1.0 // 1 level per week
    }
    
    func calculateCurrencyAnalytics(user: UserEntity) -> CurrencyAnalytics {
        return CurrencyAnalytics(
            totalCoinsEarned: Int(user.coins),
            totalGemsEarned: Int(user.gems),
            averageCoinsPerQuest: 10.0, // Default value
            averageGemsPerQuest: 1.0, // Default value
            earningRate: 50.0 // Default: 50 coins per week
        )
    }
    
    func calculateAchievementAnalytics() -> AchievementAnalytics {
        let allAchievements = achievementManager.getAllAchievements()
        let unlockedAchievements = allAchievements.filter { achievementManager.isAchievementUnlocked($0.id) }
        
        return AchievementAnalytics(
            totalAchievements: allAchievements.count,
            unlockedAchievements: unlockedAchievements.count,
            unlockRate: allAchievements.isEmpty ? 0.0 : Double(unlockedAchievements.count) / Double(allAchievements.count),
            recentUnlocks: Array(unlockedAchievements.prefix(3)),
            nextAchievements: Array(allAchievements.filter { !achievementManager.isAchievementUnlocked($0.id) }.prefix(3))
        )
    }
}
