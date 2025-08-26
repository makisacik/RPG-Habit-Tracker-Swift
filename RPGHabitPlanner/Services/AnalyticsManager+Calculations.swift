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
        var hourCounts: [Int: Int] = [:]
        
        // Count quest creation times
        for quest in quests {
            let creationHour = calendar.component(.hour, from: quest.creationDate)
            hourCounts[creationHour, default: 0] += 1
        }
        
        // Count quest completion times (both partial and finished)
        for quest in quests {
            // Count the main completion date if it exists
            if let completionDate = quest.completionDate {
                let completionHour = calendar.component(.hour, from: completionDate)
                hourCounts[completionHour, default: 0] += 1
            }
            
            // Count all completion history dates
            for completionDate in quest.completions {
                let completionHour = calendar.component(.hour, from: completionDate)
                hourCounts[completionHour, default: 0] += 1
            }
        }
        
        // Count task completions from CompletionTracker
        let completionRecords = CompletionTracker.shared.getCompletionRecords()
        for record in completionRecords {
            let completionHour = calendar.component(.hour, from: record.completionDate)
            hourCounts[completionHour, default: 0] += 1
        }
        
        // Return the hour with the most activity, or default to configured value if no data
        return hourCounts.max { $0.value < $1.value }?.key ?? AnalyticsConfiguration.TimeAnalytics.defaultMostProductiveHour
    }
    
    func calculateMostActiveDay(quests: [Quest]) -> Int {
        var dayCounts: [Int: Int] = [:]
        
        // Count quest creation times
        for quest in quests {
            let creationDay = calendar.component(.weekday, from: quest.creationDate)
            dayCounts[creationDay, default: 0] += 1
        }
        
        // Count quest completion times
        for quest in quests {
            if let completionDate = quest.completionDate {
                let completionDay = calendar.component(.weekday, from: completionDate)
                dayCounts[completionDay, default: 0] += 1
            }
            
            for completionDate in quest.completions {
                let completionDay = calendar.component(.weekday, from: completionDate)
                dayCounts[completionDay, default: 0] += 1
            }
        }
        
        // Count task completions
        let completionRecords = CompletionTracker.shared.getCompletionRecords()
        for record in completionRecords {
            let completionDay = calendar.component(.weekday, from: record.completionDate)
            dayCounts[completionDay, default: 0] += 1
        }
        
        return dayCounts.max { $0.value < $1.value }?.key ?? AnalyticsConfiguration.TimeAnalytics.defaultMostActiveDay // Default to Sunday
    }
    
    func calculateSessionFrequency() -> Double {
        let completionRecords = CompletionTracker.shared.getCompletionRecords()
        
        // Group completions by day
        var dailyCompletions: [Date: Int] = [:]
        for record in completionRecords {
            let day = calendar.startOfDay(for: record.completionDate)
            dailyCompletions[day, default: 0] += 1
        }
        
        // Calculate average sessions per week
        let totalDays = dailyCompletions.count
        let weeks = max(1, totalDays / 7)
        
        return Double(totalDays) / Double(weeks)
    }
    
    func calculateAppOpenFrequency(quests: [Quest]) -> Double {
        // Group quest creations by day
        var dailyCreations: [Date: Int] = [:]
        for quest in quests {
            let day = calendar.startOfDay(for: quest.creationDate)
            dailyCreations[day, default: 0] += 1
        }
        
        // Calculate average app opens per week
        let totalDays = dailyCreations.count
        let weeks = max(1, totalDays / 7)
        
        return Double(totalDays) / Double(weeks)
    }
    
    func calculatePreferredDifficulty(quests: [Quest]) -> Int {
        guard !quests.isEmpty else { return AnalyticsConfiguration.QuestPerformance.defaultDifficulty }
        
        var difficultyCounts: [Int: Int] = [:]
        for quest in quests {
            difficultyCounts[quest.difficulty, default: 0] += 1
        }
        
        return difficultyCounts.max { $0.value < $1.value }?.key ?? AnalyticsConfiguration.QuestPerformance.defaultDifficulty
    }
    
    func calculateStreakAnalytics() -> StreakAnalytics {
        let currentStreak = streakManager.currentStreak
        let longestStreak = streakManager.longestStreak

        // Ensure currentStreak never exceeds longestStreak to prevent ProgressView issues
        let safeCurrentStreak = min(currentStreak, longestStreak)
        let safeLongestStreak = max(1, longestStreak) // Ensure we have a minimum value
        
        // For now, return basic streak data
        // This can be enhanced when more detailed streak tracking is implemented
        return StreakAnalytics(
            currentStreak: safeCurrentStreak,
            longestStreak: safeLongestStreak,
            averageStreakLength: Double(safeLongestStreak),
            streakBreakPatterns: [],
            bestStreakDay: calendar.component(.weekday, from: Date())
        )
    }
    
    func calculateWeeklyTrends(quests: [Quest]) -> [WeeklyTrend] {
        // Calculate trends for the configured number of weeks
        let endDate = Date()
        let startDate = calendar.date(byAdding: .weekOfYear, value: -AnalyticsConfiguration.WeeklyTrends.analysisWeeks, to: endDate) ?? endDate
        
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
        // Experience formula using configured multiplier
        return AnalyticsConfiguration.Progression.experienceFormulaMultiplier * level * level
    }
    
    func calculateLevelUpRate(user: UserEntity) -> Double {
        // For now, return a default rate
        // This can be enhanced when level history tracking is implemented
        return AnalyticsConfiguration.Progression.defaultLevelUpRate // Default level up rate
    }
    
    func calculateCurrencyAnalytics(user: UserEntity) -> CurrencyAnalytics {
        return CurrencyAnalytics(
            totalCoinsEarned: Int(user.coins),
            totalGemsEarned: Int(user.gems),
            averageCoinsPerQuest: AnalyticsConfiguration.Currency.defaultAverageCoinsPerQuest,
            averageGemsPerQuest: AnalyticsConfiguration.Currency.defaultAverageGemsPerQuest,
            earningRate: AnalyticsConfiguration.Currency.defaultEarningRate
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
    
    func calculateCustomizationAnalytics(for user: UserEntity) -> CustomizationAnalytics {
        // Get the user's customization entity
        guard let customizationEntity = customizationService.fetchCustomization(for: user) else {
            return CustomizationAnalytics(
                mostUsedPreset: nil,
                customizationFrequency: 0,
                preferredColors: [],
                preferredAccessories: [],
                lastCustomizationDate: nil
            )
        }
        
        // Get customization frequency from UserDefaults tracking
        let customizationFrequency = getCustomizationFrequency(for: user.id?.uuidString ?? "")
        let lastCustomizationDate = getLastCustomizationDate(for: user.id?.uuidString ?? "")
        
        // Analyze preferred colors and accessories from current customization
        let customization = customizationEntity.toCharacterCustomization()
        var preferredColors: [String] = []
        var preferredAccessories: [String] = []
        
        // Add hair color
        preferredColors.append(customization.hairColor.rawValue)
        
        // Add eye color
        preferredColors.append(customization.eyeColor.rawValue)
        
        // Add accessories
        if let accessory = customization.accessory {
            preferredAccessories.append(accessory.rawValue)
        }
        
        if let headGear = customization.headGear {
            preferredAccessories.append(headGear.rawValue)
        }
        
        if let mustache = customization.mustache {
            preferredAccessories.append(mustache.rawValue)
        }
        
        if let flower = customization.flower {
            preferredAccessories.append(flower.rawValue)
        }
        
        if let pet = customization.pet {
            preferredAccessories.append(pet.rawValue)
        }
        
        if let wings = customization.wings {
            preferredAccessories.append(wings.rawValue)
        }
        
        // Get most used preset (for now, return nil as preset tracking would need additional implementation)
        let mostUsedPreset: String? = nil
        
        return CustomizationAnalytics(
            mostUsedPreset: mostUsedPreset,
            customizationFrequency: customizationFrequency,
            preferredColors: preferredColors,
            preferredAccessories: preferredAccessories,
            lastCustomizationDate: lastCustomizationDate
        )
    }
    
    // MARK: - Customization Tracking Helper Methods
    
    private func getCustomizationFrequency(for userId: String) -> Int {
        let userDefaults = UserDefaults.standard
        let key = AnalyticsConfiguration.UserDefaultsKeys.customizationFrequencyPrefix + userId
        return userDefaults.integer(forKey: key)
    }
    
    private func getLastCustomizationDate(for userId: String) -> Date? {
        let userDefaults = UserDefaults.standard
        let key = AnalyticsConfiguration.UserDefaultsKeys.lastCustomizationDatePrefix + userId
        let timeInterval = userDefaults.double(forKey: key)
        return timeInterval > 0 ? Date(timeIntervalSince1970: timeInterval) : nil
    }
    
    func incrementCustomizationCount(for userId: String) {
        let userDefaults = UserDefaults.standard
        let frequencyKey = AnalyticsConfiguration.UserDefaultsKeys.customizationFrequencyPrefix + userId
        let dateKey = AnalyticsConfiguration.UserDefaultsKeys.lastCustomizationDatePrefix + userId
        
        let currentCount = userDefaults.integer(forKey: frequencyKey)
        userDefaults.set(currentCount + 1, forKey: frequencyKey)
        userDefaults.set(Date().timeIntervalSince1970, forKey: dateKey)
    }
}
