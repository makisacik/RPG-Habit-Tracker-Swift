//
//  AnalyticsDashboardPlaceholders.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 27.07.2025.
//

import SwiftUI

// MARK: - Analytics Dashboard Placeholder Methods

struct AnalyticsDashboardPlaceholders {
    // MARK: - Performance Tab Placeholders
    
    static func questPerformanceChart(summary: AnalyticsSummary, theme: Theme) -> some View {
        Text("analytics_quest_performance_chart".localized)
            .foregroundColor(theme.textColor)
            .frame(maxWidth: .infinity, maxHeight: 200)
            .background(theme.cardBackgroundColor)
            .cornerRadius(12)
    }
    
    static func difficultyAnalysisCard(summary: AnalyticsSummary, theme: Theme) -> some View {
        Text("analytics_difficulty_analysis".localized)
            .foregroundColor(theme.textColor)
            .frame(maxWidth: .infinity, maxHeight: 150)
            .background(theme.cardBackgroundColor)
            .cornerRadius(12)
    }
    
    static func completionTrendsCard(summary: AnalyticsSummary, theme: Theme) -> some View {
        Text("analytics_completion_trends".localized)
            .foregroundColor(theme.textColor)
            .frame(maxWidth: .infinity, maxHeight: 150)
            .background(theme.cardBackgroundColor)
            .cornerRadius(12)
    }
    
    static func productivityHeatmapCard(summary: AnalyticsSummary, theme: Theme) -> some View {
        Text("analytics_productivity_heatmap".localized)
            .foregroundColor(theme.textColor)
            .frame(maxWidth: .infinity, maxHeight: 200)
            .background(theme.cardBackgroundColor)
            .cornerRadius(12)
    }
    
    // MARK: - Patterns Tab Placeholders
    
    static func activityPatternsCard(summary: AnalyticsSummary, theme: Theme) -> some View {
        Text("analytics_activity_patterns".localized)
            .foregroundColor(theme.textColor)
            .frame(maxWidth: .infinity, maxHeight: 150)
            .background(theme.cardBackgroundColor)
            .cornerRadius(12)
    }
    
    static func timeAnalysisCard(summary: AnalyticsSummary, theme: Theme) -> some View {
        Text("analytics_time_analysis".localized)
            .foregroundColor(theme.textColor)
            .frame(maxWidth: .infinity, maxHeight: 150)
            .background(theme.cardBackgroundColor)
            .cornerRadius(12)
    }
    
    
    static func customizationPatternsCard(summary: AnalyticsSummary, theme: Theme) -> some View {
        Text("analytics_customization_patterns".localized)
            .foregroundColor(theme.textColor)
            .frame(maxWidth: .infinity, maxHeight: 150)
            .background(theme.cardBackgroundColor)
            .cornerRadius(12)
    }
    
    // MARK: - Recommendations Tab Placeholders
    
    static func priorityRecommendationsCard(summary: AnalyticsSummary, theme: Theme) -> some View {
        Text("analytics_priority_recommendations".localized)
            .foregroundColor(theme.textColor)
            .frame(maxWidth: .infinity, maxHeight: 150)
            .background(theme.cardBackgroundColor)
            .cornerRadius(12)
    }
    
    static func improvementSuggestionsCard(summary: AnalyticsSummary, theme: Theme) -> some View {
        Text("analytics_improvement_suggestions".localized)
            .foregroundColor(theme.textColor)
            .frame(maxWidth: .infinity, maxHeight: 150)
            .background(theme.cardBackgroundColor)
            .cornerRadius(12)
    }
    
    static func goalSettingCard(summary: AnalyticsSummary, theme: Theme) -> some View {
        Text("analytics_goal_setting".localized)
            .foregroundColor(theme.textColor)
            .frame(maxWidth: .infinity, maxHeight: 150)
            .background(theme.cardBackgroundColor)
            .cornerRadius(12)
    }
}
