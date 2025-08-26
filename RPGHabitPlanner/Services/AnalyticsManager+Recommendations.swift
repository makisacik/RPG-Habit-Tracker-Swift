//
//  AnalyticsManager+Recommendations.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 27.07.2025.
//

import Foundation

// MARK: - AnalyticsManager Recommendations Extension

extension AnalyticsManager {
    // MARK: - Recommendation Methods
    
    func getDifficultyRecommendation(summary: AnalyticsSummary) -> PersonalizedRecommendation? {
        let successRates = summary.questPerformance.difficultySuccessRates
        let preferredDifficulty = summary.questPerformance.preferredDifficulty
        
        // Check if user is struggling with current difficulty
        if let currentSuccessRate = successRates[preferredDifficulty], currentSuccessRate < 0.5 {
            return PersonalizedRecommendation(
                type: .difficultyAdjustment,
                title: String(localized: "analytics_recommendation_difficulty_title"),
                description: String(localized: "analytics_recommendation_difficulty_description"),
                priority: .medium,
                actionable: true,
                actionTitle: String(localized: "adjust_difficulty"),
                actionData: ["suggestedDifficulty": max(1, preferredDifficulty - 1)]
            )
        }
        
        // Check if user can handle higher difficulty
        if let currentSuccessRate = successRates[preferredDifficulty], currentSuccessRate > 0.8 {
            return PersonalizedRecommendation(
                type: .difficultyAdjustment,
                title: String(localized: "analytics_recommendation_increase_difficulty_title"),
                description: String(localized: "analytics_recommendation_increase_difficulty_description"),
                priority: .low,
                actionable: true,
                actionTitle: String(localized: "increase_difficulty"),
                actionData: ["suggestedDifficulty": min(5, preferredDifficulty + 1)]
            )
        }
        
        return nil
    }
    
    func getStreakRecommendation(summary: AnalyticsSummary) -> PersonalizedRecommendation? {
        let currentStreak = summary.questPerformance.streakData.currentStreak
        let longestStreak = summary.questPerformance.streakData.longestStreak
        
        if currentStreak == 0 && longestStreak > 0 {
            return PersonalizedRecommendation(
                type: .streakBuilding,
                title: String(localized: "analytics_recommendation_streak_title"),
                description: String(localized: "analytics_recommendation_streak_description"),
                priority: .high,
                actionable: true,
                actionTitle: String(localized: "start_streak"),
                actionData: nil
            )
        }
        
        if currentStreak > 0 && currentStreak < longestStreak / 2 {
            return PersonalizedRecommendation(
                type: .streakBuilding,
                title: String(localized: "analytics_recommendation_streak_continue_title"),
                description: String(localized: "analytics_recommendation_streak_continue_description"),
                priority: .medium,
                actionable: true,
                actionTitle: String(localized: "continue_streak"),
                actionData: nil
            )
        }
        
        return nil
    }
    
    func getAchievementRecommendation(summary: AnalyticsSummary) -> PersonalizedRecommendation? {
        let unlockRate = summary.progression.achievements.unlockRate
        
        if unlockRate < 0.3 {
            return PersonalizedRecommendation(
                type: .achievementGoal,
                title: String(localized: "analytics_recommendation_achievements_title"),
                description: String(localized: "analytics_recommendation_achievements_description"),
                priority: .medium,
                actionable: true,
                actionTitle: String(localized: "view_achievements"),
                actionData: nil
            )
        }
        
        return nil
    }
    
    func getTimingRecommendation(summary: AnalyticsSummary) -> PersonalizedRecommendation? {
        let mostProductiveHour = summary.questPerformance.mostProductiveHour
        let currentHour = calendar.component(.hour, from: Date())
        
        // If it's close to the user's most productive hour, suggest creating a quest
        if abs(currentHour - mostProductiveHour) <= 1 {
            return PersonalizedRecommendation(
                type: .timing,
                title: String(localized: "analytics_recommendation_timing_title"),
                description: String(localized: "analytics_recommendation_timing_description"),
                priority: .medium,
                actionable: true,
                actionTitle: String(localized: "create_quest_now"),
                actionData: nil
            )
        }
        
        return nil
    }
}
