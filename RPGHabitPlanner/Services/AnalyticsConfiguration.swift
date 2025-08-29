//
//  AnalyticsConfiguration.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 27.07.2025.
//

import Foundation

// MARK: - Analytics Configuration

struct AnalyticsConfiguration {
    // MARK: - Quest Performance Thresholds
    
    struct QuestPerformance {
        /// Minimum number of quests to consider for analytics
        static let minimumQuestsForAnalysis = 5
        
        /// Success rate threshold for difficulty adjustment recommendations
        static let lowSuccessRateThreshold = 0.5
        
        /// Success rate threshold for increasing difficulty
        static let highSuccessRateThreshold = 0.8
        
        /// Default difficulty level when no data is available
        static let defaultDifficulty = 2
        
        /// Minimum difficulty level
        static let minimumDifficulty = 1
        
        /// Maximum difficulty level
        static let maximumDifficulty = 5
    }
    
    // MARK: - Time and Session Analytics
    
    struct TimeAnalytics {
        /// Default most productive hour when no data is available
        static let defaultMostProductiveHour = 12
        
        /// Default most active day when no data is available (1 = Sunday)
        static let defaultMostActiveDay = 1
        
        /// Default session duration in seconds (5 minutes)
        static let defaultSessionDuration: TimeInterval = 300
        
        /// Default session frequency per week
        static let defaultSessionFrequency = 5.0
        
        /// Default app open frequency per week
        static let defaultAppOpenFrequency = 7.0
        
        /// Time window for timing recommendations (in hours)
        static let timingRecommendationWindow = 1
    }
    
    // MARK: - Progression Analytics
    
    struct Progression {
        /// Default level when no data is available
        static let defaultLevel = 1
        
        /// Default experience to next level
        static let defaultExperienceToNextLevel = 100
        
        /// Default level up rate per week
        static let defaultLevelUpRate = 1.0
        
        /// Experience formula multiplier
        static let experienceFormulaMultiplier = 100
    }
    
    // MARK: - Currency Analytics
    
    struct Currency {
        /// Default average coins per quest
        static let defaultAverageCoinsPerQuest = 0.0
        
        /// Default average gems per quest
        static let defaultAverageGemsPerQuest = 1.0
        
        /// Default earning rate per week
        static let defaultEarningRate = 50.0
    }
    
    // MARK: - Streak Analytics
    
    struct Streak {
        /// Threshold for streak motivation messages
        static let recordStreakThreshold = 0.5 // 50% of longest streak
    }
    
    // MARK: - Achievement Analytics
    
    struct Achievement {
        /// Threshold for achievement recommendations
        static let lowUnlockRateThreshold = 0.3
    }
    
    // MARK: - Customization Analytics
    
    struct Customization {
        /// Threshold for occasional customization
        static let occasionalCustomizationThreshold = 3
        
        /// Threshold for active customization
        static let activeCustomizationThreshold = 5
    }
    
    // MARK: - Weekly Trends
    
    struct WeeklyTrends {
        /// Number of weeks to analyze for trends
        static let analysisWeeks = 4
    }
    
    // MARK: - UserDefaults Keys
    
    struct UserDefaultsKeys {
        static let customizationFrequencyPrefix = "customization_frequency_"
        static let lastCustomizationDatePrefix = "last_customization_date_"
    }
}
