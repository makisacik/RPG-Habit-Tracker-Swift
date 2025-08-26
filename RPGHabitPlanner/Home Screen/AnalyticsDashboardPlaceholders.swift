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
        Text("Quest Performance Chart")
            .foregroundColor(theme.textColor)
            .frame(maxWidth: .infinity, maxHeight: 200)
            .background(theme.cardBackgroundColor)
            .cornerRadius(12)
    }
    
    static func difficultyAnalysisCard(summary: AnalyticsSummary, theme: Theme) -> some View {
        Text("Difficulty Analysis")
            .foregroundColor(theme.textColor)
            .frame(maxWidth: .infinity, maxHeight: 150)
            .background(theme.cardBackgroundColor)
            .cornerRadius(12)
    }
    
    static func completionTrendsCard(summary: AnalyticsSummary, theme: Theme) -> some View {
        Text("Completion Trends")
            .foregroundColor(theme.textColor)
            .frame(maxWidth: .infinity, maxHeight: 150)
            .background(theme.cardBackgroundColor)
            .cornerRadius(12)
    }
    
    static func productivityHeatmapCard(summary: AnalyticsSummary, theme: Theme) -> some View {
        Text("Productivity Heatmap")
            .foregroundColor(theme.textColor)
            .frame(maxWidth: .infinity, maxHeight: 200)
            .background(theme.cardBackgroundColor)
            .cornerRadius(12)
    }
    
    // MARK: - Patterns Tab Placeholders
    
    static func activityPatternsCard(summary: AnalyticsSummary, theme: Theme) -> some View {
        Text("Activity Patterns")
            .foregroundColor(theme.textColor)
            .frame(maxWidth: .infinity, maxHeight: 150)
            .background(theme.cardBackgroundColor)
            .cornerRadius(12)
    }
    
    static func timeAnalysisCard(summary: AnalyticsSummary, theme: Theme) -> some View {
        Text("Time Analysis")
            .foregroundColor(theme.textColor)
            .frame(maxWidth: .infinity, maxHeight: 150)
            .background(theme.cardBackgroundColor)
            .cornerRadius(12)
    }
    
    
    static func customizationPatternsCard(summary: AnalyticsSummary, theme: Theme) -> some View {
        Text("Customization Patterns")
            .foregroundColor(theme.textColor)
            .frame(maxWidth: .infinity, maxHeight: 150)
            .background(theme.cardBackgroundColor)
            .cornerRadius(12)
    }
    
    // MARK: - Recommendations Tab Placeholders
    
    static func priorityRecommendationsCard(summary: AnalyticsSummary, theme: Theme) -> some View {
        Text("Priority Recommendations")
            .foregroundColor(theme.textColor)
            .frame(maxWidth: .infinity, maxHeight: 150)
            .background(theme.cardBackgroundColor)
            .cornerRadius(12)
    }
    
    static func improvementSuggestionsCard(summary: AnalyticsSummary, theme: Theme) -> some View {
        Text("Improvement Suggestions")
            .foregroundColor(theme.textColor)
            .frame(maxWidth: .infinity, maxHeight: 150)
            .background(theme.cardBackgroundColor)
            .cornerRadius(12)
    }
    
    static func goalSettingCard(summary: AnalyticsSummary, theme: Theme) -> some View {
        Text("Goal Setting")
            .foregroundColor(theme.textColor)
            .frame(maxWidth: .infinity, maxHeight: 150)
            .background(theme.cardBackgroundColor)
            .cornerRadius(12)
    }
}
