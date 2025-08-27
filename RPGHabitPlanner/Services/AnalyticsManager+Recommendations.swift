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
        if let currentSuccessRate = successRates[preferredDifficulty], currentSuccessRate < AnalyticsConfiguration.QuestPerformance.lowSuccessRateThreshold {
            return PersonalizedRecommendation(
                type: .difficultyAdjustment,
                title: "analytics_recommendation_difficulty_title".localized,
                description: "analytics_recommendation_difficulty_description".localized,
                priority: .medium,
                actionable: true,
                actionTitle: "adjust_difficulty".localized,
                actionData: ["suggestedDifficulty": max(AnalyticsConfiguration.QuestPerformance.minimumDifficulty, preferredDifficulty - 1)]
            )
        }
        
        // Check if user can handle higher difficulty
        if let currentSuccessRate = successRates[preferredDifficulty], currentSuccessRate > AnalyticsConfiguration.QuestPerformance.highSuccessRateThreshold {
            return PersonalizedRecommendation(
                type: .difficultyAdjustment,
                title: "analytics_recommendation_increase_difficulty_title".localized,
                description: "analytics_recommendation_increase_difficulty_description".localized,
                priority: .low,
                actionable: true,
                actionTitle: "increase_difficulty".localized,
                actionData: ["suggestedDifficulty": min(AnalyticsConfiguration.QuestPerformance.maximumDifficulty, preferredDifficulty + 1)]
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
                title: "analytics_recommendation_streak_title".localized,
                description: "analytics_recommendation_streak_description".localized,
                priority: .high,
                actionable: true,
                actionTitle: "start_streak".localized,
                actionData: nil
            )
        }
        
        if currentStreak > 0 && currentStreak < Int(Double(longestStreak) * AnalyticsConfiguration.Streak.recordStreakThreshold) {
            return PersonalizedRecommendation(
                type: .streakBuilding,
                title: "analytics_recommendation_streak_continue_title".localized,
                description: "analytics_recommendation_streak_continue_description".localized,
                priority: .medium,
                actionable: true,
                actionTitle: "continue_streak".localized,
                actionData: nil
            )
        }
        
        return nil
    }
    
    func getAchievementRecommendation(summary: AnalyticsSummary) -> PersonalizedRecommendation? {
        let unlockRate = summary.progression.achievements.unlockRate
        
        if unlockRate < AnalyticsConfiguration.Achievement.lowUnlockRateThreshold {
            return PersonalizedRecommendation(
                type: .achievementGoal,
                title: "analytics_recommendation_achievements_title".localized,
                description: "analytics_recommendation_achievements_description".localized,
                priority: .medium,
                actionable: true,
                actionTitle: "view_achievements".localized,
                actionData: nil
            )
        }
        
        return nil
    }
    
    func getTimingRecommendation(summary: AnalyticsSummary) -> PersonalizedRecommendation? {
        let mostProductiveHour = summary.questPerformance.mostProductiveHour
        let currentHour = calendar.component(.hour, from: Date())
        
        // If it's close to the user's most productive hour, suggest creating a quest
        if abs(currentHour - mostProductiveHour) <= AnalyticsConfiguration.TimeAnalytics.timingRecommendationWindow {
            return PersonalizedRecommendation(
                type: .timing,
                title: "analytics_recommendation_timing_title".localized,
                description: "analytics_recommendation_timing_description".localized,
                priority: .medium,
                actionable: true,
                actionTitle: "create_quest_now".localized,
                actionData: nil
            )
        }
        
        return nil
    }
}
