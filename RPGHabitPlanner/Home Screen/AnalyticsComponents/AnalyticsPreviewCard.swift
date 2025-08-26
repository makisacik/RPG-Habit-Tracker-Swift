//
//  AnalyticsPreviewCard.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 27.07.2025.
//

import SwiftUI

struct AnalyticsPreviewCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var analyticsManager = AnalyticsManager.shared
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        VStack(spacing: 12) {
            if analyticsManager.isLoading {
                loadingView(theme: theme)
            } else if let summary = analyticsManager.analyticsSummary {
                analyticsPreviewContent(summary: summary, theme: theme)
            } else {
                emptyStateView(theme: theme)
            }
        }
    }
    
    private func loadingView(theme: Theme) -> some View {
        HStack(spacing: 12) {
            ProgressView()
                .scaleEffect(0.8)
                .progressViewStyle(CircularProgressViewStyle(tint: theme.accentColor))
            
            Text(String(localized: "analytics_loading"))
                .font(.caption)
                .foregroundColor(theme.textColor.opacity(0.7))
        }
        .frame(height: 60)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.cardBackgroundColor)
        )
    }
    
    private func analyticsPreviewContent(summary: AnalyticsSummary, theme: Theme) -> some View {
        VStack(spacing: 12) {
            // Quick Stats Row
            HStack(spacing: 16) {
                QuickStatItem(
                    title: String(localized: "analytics_completion_rate"),
                    value: "\(Int(summary.questPerformance.completionRate * 100))%",
                    icon: "percent",
                    color: theme.successColor
                )
                
                QuickStatItem(
                    title: String(localized: "analytics_current_streak"),
                    value: "\(summary.questPerformance.streakData.currentStreak)",
                    icon: "flame.fill",
                    color: theme.warningColor
                )
                
                QuickStatItem(
                    title: String(localized: "analytics_level"),
                    value: "\(summary.progression.currentLevel)",
                    icon: "star.fill",
                    color: theme.accentColor
                )
            }
            
            // Top Recommendation
            if let topRecommendation = summary.recommendations.first {
                recommendationPreview(recommendation: topRecommendation, theme: theme)
            }
        }
    }
    
    private func emptyStateView(theme: Theme) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 24))
                .foregroundColor(theme.textColor.opacity(0.5))
            
            Text(String(localized: "analytics_empty_title"))
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(theme.textColor.opacity(0.7))
            
            Text(String(localized: "analytics_empty_description"))
                .font(.caption2)
                .foregroundColor(theme.textColor.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .frame(height: 80)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.cardBackgroundColor)
        )
    }
    
    private func recommendationPreview(recommendation: PersonalizedRecommendation, theme: Theme) -> some View {
        HStack(spacing: 8) {
            Image(systemName: recommendationIcon(for: recommendation.type))
                .font(.caption)
                .foregroundColor(priorityColor(for: recommendation.priority, theme: theme))
                .frame(width: 12)
            
            Text(recommendation.title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(theme.textColor)
                .lineLimit(2)
            
            Spacer()
            
            if recommendation.priority == .high {
                Text(String(localized: "analytics_priority_high"))
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(theme.warningColor)
                    .cornerRadius(4)
            }
        }
        .padding(8)
        .background(priorityColor(for: recommendation.priority, theme: theme).opacity(0.1))
        .cornerRadius(8)
    }
    
    private func recommendationIcon(for type: RecommendationType) -> String {
        switch type {
        case .questCreation:
            return "plus.circle.fill"
        case .difficultyAdjustment:
            return "slider.horizontal.3"
        case .streakBuilding:
            return "flame.fill"
        case .achievementGoal:
            return "trophy.fill"
        case .customization:
            return "paintbrush.fill"
        case .timing:
            return "clock.fill"
        case .engagement:
            return "chart.line.uptrend.xyaxis"
        }
    }
    
    private func priorityColor(for priority: RecommendationPriority, theme: Theme) -> Color {
        switch priority {
        case .high:
            return theme.warningColor
        case .medium:
            return theme.accentColor
        case .low:
            return theme.infoColor
        }
    }
}

// MARK: - Supporting Views

struct QuickStatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            
            Text(value)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

struct AnalyticsPreviewCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            AnalyticsPreviewCard()
                .environmentObject(ThemeManager.shared)
                .padding()
        }
        .background(Color.gray.opacity(0.1))
    }
}
