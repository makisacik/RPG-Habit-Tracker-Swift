//
//  AnalyticsModels.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 27.07.2025.
//

import Foundation

// MARK: - Analytics Data Models

struct QuestPerformanceData {
    let totalQuests: Int
    let finishedQuests: Int // Quests completed for good
    let partiallyCompletedQuests: Int // Quests with some completions but not finished
    let completionRate: Double // Rate of finished quests
    let partialCompletionRate: Double // Rate of quests with any completions
    let averageCompletionTime: TimeInterval
    let mostProductiveHour: Int
    let preferredDifficulty: Int
    let streakData: StreakAnalytics
    let weeklyTrends: [WeeklyTrend]
    let difficultySuccessRates: [Int: Double]
}

struct StreakAnalytics {
    let currentStreak: Int
    let longestStreak: Int
    let averageStreakLength: Double
    let streakBreakPatterns: [StreakBreakPattern]
    let bestStreakDay: Int // 1 = Sunday, 7 = Saturday
}

struct StreakBreakPattern {
    let dayOfWeek: Int
    let frequency: Int
    let averageBreakLength: Int
}

struct WeeklyTrend {
    let weekStartDate: Date
    let questsCreated: Int
    let questsCompleted: Int
    let completionRate: Double
    let averageDifficulty: Double
}

struct ProgressionAnalytics {
    let currentLevel: Int
    let experienceProgress: Double
    let experienceToNextLevel: Int
    let totalExperience: Int
    let levelUpRate: Double // levels per week
    let currencyEarned: CurrencyAnalytics
    let achievements: AchievementAnalytics
}

struct CurrencyAnalytics {
    let totalCoinsEarned: Int
    let totalGemsEarned: Int
    let totalCoinsSpent: Int
    let totalGemsSpent: Int
    let currentCoins: Int
    let currentGems: Int
    let averageCoinsPerQuest: Double
    let averageGemsPerQuest: Double
    let earningRate: Double // currency per week
    let transactions: [CurrencyTransaction]
}

struct CurrencyTransaction {
    let id: UUID
    let type: TransactionType
    let amount: Int
    let currency: CurrencyType
    let source: TransactionSource
    let timestamp: Date
    let questId: UUID?
    let description: String?
}

enum TransactionType {
    case earned
    case spent
}

enum CurrencyType {
    case coins
    case gems
}

enum TransactionSource {
    case questCompletion
    case taskCompletion
    case achievement
    case shop
    case booster
    case dailyReward
    case levelUp
    case other
}

struct AchievementAnalytics {
    let totalAchievements: Int
    let unlockedAchievements: Int
    let unlockRate: Double
    let recentUnlocks: [AchievementDefinition]
    let nextAchievements: [AchievementDefinition]
}

struct CustomizationAnalytics {
    let mostUsedPreset: String?
    let customizationFrequency: Int
    let preferredColors: [String]
    let preferredAccessories: [String]
    let lastCustomizationDate: Date?
}

struct EngagementAnalytics {
    let sessionFrequency: Double // sessions per week
    let averageSessionDuration: TimeInterval
    let mostActiveDay: Int
    let mostActiveHour: Int
    let featureUsage: [String: Int]
    let appOpenFrequency: Double
}

struct PersonalizedRecommendation {
    let type: RecommendationType
    let title: String
    let description: String
    let priority: RecommendationPriority
    let actionable: Bool
    let actionTitle: String?
    let actionData: [String: Any]?
}

enum RecommendationType {
    case questCreation
    case difficultyAdjustment
    case streakBuilding
    case achievementGoal
    case customization
    case timing
    case engagement
}

enum RecommendationPriority {
    case high
    case medium
    case low
}

// MARK: - Analytics Summary

struct AnalyticsSummary {
    let questPerformance: QuestPerformanceData
    let progression: ProgressionAnalytics
    let customization: CustomizationAnalytics
    let engagement: EngagementAnalytics
    let recommendations: [PersonalizedRecommendation]
    let lastUpdated: Date
}

// MARK: - Time Period Analytics

struct TimePeriodAnalytics {
    let period: AnalyticsPeriod
    let startDate: Date
    let endDate: Date
    let questPerformance: QuestPerformanceData
    let progression: ProgressionAnalytics
    let engagement: EngagementAnalytics
}

enum AnalyticsPeriod {
    case week
    case month
    case quarter
    case year
    case allTime
}

// MARK: - Analytics Filters

struct AnalyticsFilters {
    let timePeriod: AnalyticsPeriod
    let questTypes: Set<AnalyticsQuestType>
    let difficultyRange: ClosedRange<Int>?
    let includeCompleted: Bool
    let includeActive: Bool
}

enum AnalyticsQuestType {
    case main
    case side
    case daily
    case weekly
    case monthly
    case oneTime
}
