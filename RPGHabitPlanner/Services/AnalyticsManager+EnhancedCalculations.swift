//
//  AnalyticsManager+EnhancedCalculations.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 27.07.2025.
//

import Foundation

// MARK: - AnalyticsManager Enhanced Calculations Extension

extension AnalyticsManager {
    // MARK: - Enhanced Quest Performance Analytics
    
    func calculateEnhancedQuestPerformance(quests: [Quest]) -> EnhancedQuestPerformance {
        let totalQuests = quests.count
        let finishedQuests = quests.filter { $0.isFinished }
        let partiallyCompletedQuests = quests.filter { $0.isCompleted && !$0.isFinished }
        let activeQuests = quests.filter { !$0.isFinished && $0.isActive }
        let expiredQuests = quests.filter { !$0.isActive && !$0.isFinished }
        
        // Calculate completion rates
        let completionRate = totalQuests > 0 ? Double(finishedQuests.count) / Double(totalQuests) : 0.0
        let partialCompletionRate = totalQuests > 0 ? Double(partiallyCompletedQuests.count) / Double(totalQuests) : 0.0
        let activeQuestRate = totalQuests > 0 ? Double(activeQuests.count) / Double(totalQuests) : 0.0
        let expirationRate = totalQuests > 0 ? Double(expiredQuests.count) / Double(totalQuests) : 0.0
        
        // Calculate average completion time
        let averageCompletionTime = calculateAverageCompletionTime(quests: finishedQuests)
        
        // Calculate difficulty distribution
        let difficultyDistribution = calculateDifficultyDistribution(quests: quests)
        
        // Calculate quest type distribution
        let questTypeDistribution = calculateQuestTypeDistribution(quests: quests)
        
        // Calculate productivity patterns
        let productivityPatterns = calculateProductivityPatterns(quests: quests)
        
        return EnhancedQuestPerformance(
            totalQuests: totalQuests,
            finishedQuests: finishedQuests.count,
            partiallyCompletedQuests: partiallyCompletedQuests.count,
            activeQuests: activeQuests.count,
            expiredQuests: expiredQuests.count,
            completionRate: completionRate,
            partialCompletionRate: partialCompletionRate,
            activeQuestRate: activeQuestRate,
            expirationRate: expirationRate,
            averageCompletionTime: averageCompletionTime,
            difficultyDistribution: difficultyDistribution,
            questTypeDistribution: questTypeDistribution,
            productivityPatterns: productivityPatterns
        )
    }
    
    // MARK: - Difficulty Distribution Analysis
    
    private func calculateDifficultyDistribution(quests: [Quest]) -> [Int: DifficultyStats] {
        var distribution: [Int: DifficultyStats] = [:]
        
        for difficulty in 1...AnalyticsConfiguration.QuestPerformance.maximumDifficulty {
            let questsWithDifficulty = quests.filter { $0.difficulty == difficulty }
            let completedQuests = questsWithDifficulty.filter { $0.isFinished }
            let completionRate = questsWithDifficulty.isEmpty ? 0.0 : Double(completedQuests.count) / Double(questsWithDifficulty.count)
            
            distribution[difficulty] = DifficultyStats(
                totalQuests: questsWithDifficulty.count,
                completedQuests: completedQuests.count,
                completionRate: completionRate,
                averageCompletionTime: calculateAverageCompletionTime(quests: completedQuests)
            )
        }
        
        return distribution
    }
    
    // MARK: - Quest Type Distribution Analysis
    
    private func calculateQuestTypeDistribution(quests: [Quest]) -> [QuestRepeatType: QuestTypeStats] {
        var distribution: [QuestRepeatType: QuestTypeStats] = [:]
        
        let allRepeatTypes: [QuestRepeatType] = [.oneTime, .daily, .weekly, .scheduled]
        for repeatType in allRepeatTypes {
            let questsOfType = quests.filter { $0.repeatType == repeatType }
            let completedQuests = questsOfType.filter { $0.isFinished }
            let completionRate = questsOfType.isEmpty ? 0.0 : Double(completedQuests.count) / Double(questsOfType.count)
            
            distribution[repeatType] = QuestTypeStats(
                totalQuests: questsOfType.count,
                completedQuests: completedQuests.count,
                completionRate: completionRate,
                averageCompletionTime: calculateAverageCompletionTime(quests: completedQuests)
            )
        }
        
        return distribution
    }
    
    // MARK: - Productivity Patterns Analysis
    
    private func calculateProductivityPatterns(quests: [Quest]) -> ProductivityPatterns {
        let mostProductiveHour = calculateMostProductiveHour(quests: quests)
        let mostActiveDay = calculateMostActiveDay(quests: quests)
        let hourlyProductivity = calculateHourlyProductivity(quests: quests)
        let dailyProductivity = calculateDailyProductivity(quests: quests)
        let weeklyProductivity = calculateWeeklyProductivity(quests: quests)
        
        return ProductivityPatterns(
            mostProductiveHour: mostProductiveHour,
            mostActiveDay: mostActiveDay,
            hourlyProductivity: hourlyProductivity,
            dailyProductivity: dailyProductivity,
            weeklyProductivity: weeklyProductivity
        )
    }
    
    private func calculateHourlyProductivity(quests: [Quest]) -> [Int: Int] {
        var hourlyCounts: [Int: Int] = [:]
        
        // Initialize all hours with 0
        for hour in 0..<24 {
            hourlyCounts[hour] = 0
        }
        
        // Count quest creations and completions by hour
        for quest in quests {
            let creationHour = calendar.component(.hour, from: quest.creationDate)
            hourlyCounts[creationHour, default: 0] += 1
            
            if let completionDate = quest.completionDate {
                let completionHour = calendar.component(.hour, from: completionDate)
                hourlyCounts[completionHour, default: 0] += 1
            }
            
            for completionDate in quest.completions {
                let completionHour = calendar.component(.hour, from: completionDate)
                hourlyCounts[completionHour, default: 0] += 1
            }
        }
        
        return hourlyCounts
    }
    
    private func calculateDailyProductivity(quests: [Quest]) -> [Int: Int] {
        var dailyCounts: [Int: Int] = [:]
        
        // Initialize all days with 0
        for day in 1...7 {
            dailyCounts[day] = 0
        }
        
        // Count quest creations and completions by day
        for quest in quests {
            let creationDay = calendar.component(.weekday, from: quest.creationDate)
            dailyCounts[creationDay, default: 0] += 1
            
            if let completionDate = quest.completionDate {
                let completionDay = calendar.component(.weekday, from: completionDate)
                dailyCounts[completionDay, default: 0] += 1
            }
            
            for completionDate in quest.completions {
                let completionDay = calendar.component(.weekday, from: completionDate)
                dailyCounts[completionDay, default: 0] += 1
            }
        }
        
        return dailyCounts
    }
    
    private func calculateWeeklyProductivity(quests: [Quest]) -> [Date: Int] {
        var weeklyCounts: [Date: Int] = [:]
        
        for quest in quests {
            let weekStart = calendar.dateInterval(of: .weekOfYear, for: quest.creationDate)?.start ?? quest.creationDate
            weeklyCounts[weekStart, default: 0] += 1
            
            if let completionDate = quest.completionDate {
                let completionWeekStart = calendar.dateInterval(of: .weekOfYear, for: completionDate)?.start ?? completionDate
                weeklyCounts[completionWeekStart, default: 0] += 1
            }
        }
        
        return weeklyCounts
    }
    
    // MARK: - Enhanced Streak Analytics
    
    func calculateEnhancedStreakAnalytics() -> EnhancedStreakAnalytics {
        let currentStreak = streakManager.currentStreak
        let longestStreak = streakManager.longestStreak
        
        // Calculate streak patterns
        let streakPatterns = calculateStreakPatterns()
        let streakBreakPatterns = calculateStreakBreakPatterns()
        let streakRecoveryTime = calculateStreakRecoveryTime()
        
        // Calculate streak motivation score
        let motivationScore = calculateStreakMotivationScore(currentStreak: currentStreak, longestStreak: longestStreak)
        
        return EnhancedStreakAnalytics(
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            averageStreakLength: Double(longestStreak),
            streakPatterns: streakPatterns,
            streakBreakPatterns: streakBreakPatterns,
            streakRecoveryTime: streakRecoveryTime,
            motivationScore: motivationScore,
            bestStreakDay: calendar.component(.weekday, from: Date())
        )
    }
    
    private func calculateStreakPatterns() -> [StreakPattern] {
        // This would be enhanced with actual streak history tracking
        // For now, return basic patterns
        return []
    }
    
    private func calculateStreakBreakPatterns() -> [StreakBreakPattern] {
        // This would be enhanced with actual streak break history tracking
        // For now, return basic patterns
        return []
    }
    
    private func calculateStreakRecoveryTime() -> TimeInterval {
        // This would calculate average time to recover from streak breaks
        // For now, return default value
        return 24 * 60 * 60 // 1 day in seconds
    }
    
    private func calculateStreakMotivationScore(currentStreak: Int, longestStreak: Int) -> Double {
        guard longestStreak > 0 else { return 0.0 }
        
        let currentRatio = Double(currentStreak) / Double(longestStreak)
        
        if currentStreak >= longestStreak {
            return 1.0 // Perfect score for new record
        } else if currentRatio >= AnalyticsConfiguration.Streak.recordStreakThreshold {
            return 0.8 // High motivation when close to record
        } else if currentStreak > 0 {
            return 0.6 // Moderate motivation for active streak
        } else {
            return 0.2 // Low motivation when no active streak
        }
    }
    
    // MARK: - Enhanced Engagement Analytics
    
    func calculateEnhancedEngagementAnalytics(quests: [Quest]) -> EnhancedEngagementAnalytics {
        let sessionFrequency = calculateSessionFrequency()
        let appOpenFrequency = calculateAppOpenFrequency(quests: quests)
        let featureUsage = calculateFeatureUsage()
        let retentionMetrics = calculateRetentionMetrics()
        
        return EnhancedEngagementAnalytics(
            sessionFrequency: sessionFrequency,
            appOpenFrequency: appOpenFrequency,
            featureUsage: featureUsage,
            retentionMetrics: retentionMetrics,
            engagementScore: calculateEngagementScore(
                sessionFrequency: sessionFrequency,
                appOpenFrequency: appOpenFrequency,
                featureUsage: featureUsage
            )
        )
    }
    
    private func calculateFeatureUsage() -> [String: FeatureUsageStats] {
        // This would track actual feature usage
        // For now, return default values
        return [
            "quests": FeatureUsageStats(usageCount: 0, lastUsed: nil, averageSessionTime: 0),
            "calendar": FeatureUsageStats(usageCount: 0, lastUsed: nil, averageSessionTime: 0),
            "character": FeatureUsageStats(usageCount: 0, lastUsed: nil, averageSessionTime: 0),
            "analytics": FeatureUsageStats(usageCount: 0, lastUsed: nil, averageSessionTime: 0)
        ]
    }
    
    private func calculateRetentionMetrics() -> RetentionMetrics {
        // This would calculate actual retention metrics
        // For now, return default values
        return RetentionMetrics(
            dailyRetention: 0.7,
            weeklyRetention: 0.5,
            monthlyRetention: 0.3,
            averageSessionDuration: AnalyticsConfiguration.TimeAnalytics.defaultSessionDuration
        )
    }
    
    private func calculateEngagementScore(sessionFrequency: Double, appOpenFrequency: Double, featureUsage: [String: FeatureUsageStats]) -> Double {
        // Calculate engagement score based on multiple factors
        let sessionScore = min(sessionFrequency / 7.0, 1.0) // Normalize to 0-1
        let appOpenScore = min(appOpenFrequency / 14.0, 1.0) // Normalize to 0-1
        let featureScore = Double(featureUsage.values.filter { $0.usageCount > 0 }.count) / Double(featureUsage.count)
        
        // Weighted average
        return (sessionScore * 0.4 + appOpenScore * 0.3 + featureScore * 0.3)
    }
}

// MARK: - Enhanced Analytics Models

struct EnhancedQuestPerformance {
    let totalQuests: Int
    let finishedQuests: Int
    let partiallyCompletedQuests: Int
    let activeQuests: Int
    let expiredQuests: Int
    let completionRate: Double
    let partialCompletionRate: Double
    let activeQuestRate: Double
    let expirationRate: Double
    let averageCompletionTime: TimeInterval
    let difficultyDistribution: [Int: DifficultyStats]
    let questTypeDistribution: [QuestRepeatType: QuestTypeStats]
    let productivityPatterns: ProductivityPatterns
}

struct DifficultyStats {
    let totalQuests: Int
    let completedQuests: Int
    let completionRate: Double
    let averageCompletionTime: TimeInterval
}

struct QuestTypeStats {
    let totalQuests: Int
    let completedQuests: Int
    let completionRate: Double
    let averageCompletionTime: TimeInterval
}

struct ProductivityPatterns {
    let mostProductiveHour: Int
    let mostActiveDay: Int
    let hourlyProductivity: [Int: Int]
    let dailyProductivity: [Int: Int]
    let weeklyProductivity: [Date: Int]
}

struct EnhancedStreakAnalytics {
    let currentStreak: Int
    let longestStreak: Int
    let averageStreakLength: Double
    let streakPatterns: [StreakPattern]
    let streakBreakPatterns: [StreakBreakPattern]
    let streakRecoveryTime: TimeInterval
    let motivationScore: Double
    let bestStreakDay: Int
}

struct StreakPattern {
    let patternType: String
    let frequency: Int
    let averageLength: Int
}

struct EnhancedEngagementAnalytics {
    let sessionFrequency: Double
    let appOpenFrequency: Double
    let featureUsage: [String: FeatureUsageStats]
    let retentionMetrics: RetentionMetrics
    let engagementScore: Double
}

struct FeatureUsageStats {
    let usageCount: Int
    let lastUsed: Date?
    let averageSessionTime: TimeInterval
}

struct RetentionMetrics {
    let dailyRetention: Double
    let weeklyRetention: Double
    let monthlyRetention: Double
    let averageSessionDuration: TimeInterval
}
