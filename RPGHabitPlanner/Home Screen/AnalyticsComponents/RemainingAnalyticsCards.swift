//
//  RemainingAnalyticsCards.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 27.07.2025.
//

import SwiftUI

// MARK: - Streak Insights Card

struct StreakInsightsCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let streakData: StreakAnalytics
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(theme.textColor)
                    .font(.title2)
                
                Text(String(localized: "analytics_streak_insights"))
                    .font(.headline)
                    .foregroundColor(theme.textColor)
                
                Spacer()
                
                Text("🔥 \(streakData.currentStreak)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.warningColor)
            }
            
            // Streak Stats Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatItem(
                    title: String(localized: "analytics_current_streak"),
                    value: "\(streakData.currentStreak)",
                    icon: "flame.fill",
                    color: theme.warningColor
                )
                
                StatItem(
                    title: String(localized: "analytics_longest_streak"),
                    value: "\(streakData.longestStreak)",
                    icon: "trophy.fill",
                    color: theme.accentColor
                )
                
                StatItem(
                    title: String(localized: "analytics_avg_streak"),
                    value: String(format: "%.1f", streakData.averageStreakLength),
                    icon: "chart.bar.fill",
                    color: theme.infoColor
                )
            }
            
            // Streak Insights
            VStack(alignment: .leading, spacing: 12) {
                Text(String(localized: "analytics_streak_insights_details"))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.textColor)
                
                VStack(spacing: 8) {
                    InsightRow(
                        icon: "calendar",
                        title: String(localized: "analytics_best_streak_day"),
                        value: dayOfWeekName(streakData.bestStreakDay),
                        color: theme.successColor
                    )
                    
                    if !streakData.streakBreakPatterns.isEmpty {
                        InsightRow(
                            icon: "exclamationmark.triangle.fill",
                            title: String(localized: "analytics_common_break_day"),
                            value: dayOfWeekName(streakData.streakBreakPatterns.first?.dayOfWeek ?? 1),
                            color: theme.errorColor
                        )
                    }
                }
            }
            
            // Streak Motivation
            if streakData.currentStreak > 0 {
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "analytics_streak_motivation"))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.textColor)
                    
                    Text(streakMotivationText)
                        .font(.caption)
                        .foregroundColor(theme.textColor.opacity(0.8))
                        .padding(12)
                        .background(theme.accentColor.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
        .padding(16)
        .background(theme.cardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: theme.shadowColor, radius: 4, x: 0, y: 2)
    }
    
    private var streakMotivationText: String {
        if streakData.currentStreak >= streakData.longestStreak {
            return String(localized: "analytics_streak_motivation_record")
        } else if streakData.currentStreak >= streakData.longestStreak / 2 {
            return String(localized: "analytics_streak_motivation_halfway")
        } else {
            return String(localized: "analytics_streak_motivation_keep_going")
        }
    }
    
    private func dayOfWeekName(_ day: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter.weekdaySymbols[day - 1]
    }
}

// MARK: - Engagement Metrics Card

struct EngagementMetricsCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let engagement: EngagementAnalytics
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(theme.textColor)
                    .font(.title2)
                
                Text(String(localized: "analytics_engagement_metrics"))
                    .font(.headline)
                    .foregroundColor(theme.textColor)
                
                Spacer()
                
                Text(String(localized: "analytics_engagement_score"))
                    .font(.caption)
                    .foregroundColor(theme.textColor.opacity(0.7))
            }
            
            // Engagement Stats Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatItem(
                    title: String(localized: "analytics_sessions_per_week"),
                    value: String(format: "%.1f", engagement.sessionFrequency),
                    icon: "calendar.badge.clock",
                    color: theme.infoColor
                )
                
                StatItem(
                    title: String(localized: "analytics_avg_session"),
                    value: formatTimeInterval(engagement.averageSessionDuration),
                    icon: "clock.fill",
                    color: theme.warningColor
                )
                
                StatItem(
                    title: String(localized: "analytics_app_opens"),
                    value: String(format: "%.1f", engagement.appOpenFrequency),
                    icon: "app.badge.fill",
                    color: theme.successColor
                )
            }
            
            // Activity Patterns
            VStack(alignment: .leading, spacing: 12) {
                Text(String(localized: "analytics_activity_patterns"))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.textColor)
                
                VStack(spacing: 8) {
                    InsightRow(
                        icon: "calendar",
                        title: String(localized: "analytics_most_active_day"),
                        value: dayOfWeekName(engagement.mostActiveDay),
                        color: theme.successColor
                    )
                    
                    InsightRow(
                        icon: "clock",
                        title: String(localized: "analytics_most_active_hour"),
                        value: formatHour(engagement.mostActiveHour),
                        color: theme.warningColor
                    )
                }
            }
            
            // Feature Usage (if available)
            if !engagement.featureUsage.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "analytics_feature_usage"))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.textColor)
                    
                    ForEach(Array(engagement.featureUsage.prefix(3)), id: \.key) { feature in
                        FeatureUsageRow(
                            featureName: feature.key,
                            usageCount: feature.value,
                            theme: theme
                        )
                    }
                }
            }
        }
        .padding(16)
        .background(theme.cardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: theme.shadowColor, radius: 4, x: 0, y: 2)
    }
    
    private func formatTimeInterval(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        return "\(minutes)m"
    }
    
    private func formatHour(_ hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        
        let date = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) ?? Date()
        return formatter.string(from: date)
    }
    
    private func dayOfWeekName(_ day: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter.weekdaySymbols[day - 1]
    }
}

// MARK: - Customization Preferences Card

struct CustomizationPreferencesCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let customization: CustomizationAnalytics
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "person.crop.circle.fill")
                    .foregroundColor(theme.textColor)
                    .font(.title2)
                
                Text(String(localized: "analytics_customization_preferences"))
                    .font(.headline)
                    .foregroundColor(theme.textColor)
                
                Spacer()
                
                Text(String(localized: "analytics_customization_score"))
                    .font(.caption)
                    .foregroundColor(theme.textColor.opacity(0.7))
            }
            
            // Customization Stats
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatItem(
                    title: String(localized: "analytics_customization_frequency"),
                    value: "\(customization.customizationFrequency)",
                    icon: "paintbrush.fill",
                    color: theme.infoColor
                )
                
                StatItem(
                    title: String(localized: "analytics_last_customization"),
                    value: formatLastCustomizationDate(customization.lastCustomizationDate),
                    icon: "calendar",
                    color: theme.warningColor
                )
            }
            
            // Preferences
            VStack(alignment: .leading, spacing: 12) {
                Text(String(localized: "analytics_preferences"))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.textColor)
                
                if let mostUsedPreset = customization.mostUsedPreset {
                    InsightRow(
                        icon: "star.fill",
                        title: String(localized: "analytics_most_used_preset"),
                        value: mostUsedPreset,
                        color: theme.accentColor
                    )
                }
                
                if !customization.preferredColors.isEmpty {
                    InsightRow(
                        icon: "paintpalette.fill",
                        title: String(localized: "analytics_preferred_colors"),
                        value: customization.preferredColors.joined(separator: ", "),
                        color: theme.infoColor
                    )
                }
                
                if !customization.preferredAccessories.isEmpty {
                    InsightRow(
                        icon: "crown.fill",
                        title: String(localized: "analytics_preferred_accessories"),
                        value: customization.preferredAccessories.joined(separator: ", "),
                        color: theme.warningColor
                    )
                }
            }
            
            // Customization Tips
            VStack(alignment: .leading, spacing: 8) {
                Text(String(localized: "analytics_customization_tips"))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.textColor)
                
                Text(customizationTipText)
                    .font(.caption)
                    .foregroundColor(theme.textColor.opacity(0.8))
                    .padding(12)
                    .background(theme.accentColor.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding(16)
        .background(theme.cardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: theme.shadowColor, radius: 4, x: 0, y: 2)
    }
    
    private func formatLastCustomizationDate(_ date: Date?) -> String {
        guard let date = date else {
            return String(localized: "analytics_never")
        }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private var customizationTipText: String {
        if customization.customizationFrequency == 0 {
            return String(localized: "analytics_customization_tip_new")
        } else if customization.customizationFrequency < AnalyticsConfiguration.Customization.occasionalCustomizationThreshold {
            return String(localized: "analytics_customization_tip_occasional")
        } else {
            return String(localized: "analytics_customization_tip_active")
        }
    }
}

// MARK: - Recommendations Section

struct RecommendationsSection: View {
    @EnvironmentObject var themeManager: ThemeManager
    let recommendations: [PersonalizedRecommendation]
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(theme.textColor)
                    .font(.title2)
                
                Text(String(localized: "analytics_recommendations"))
                    .font(.headline)
                    .foregroundColor(theme.textColor)
                
                Spacer()
                
                Text("\(recommendations.count)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.accentColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(theme.accentColor.opacity(0.2))
                    .cornerRadius(8)
            }
            
            if recommendations.isEmpty {
                emptyRecommendationsView(theme: theme)
            } else {
                recommendationsList(theme: theme)
            }
        }
        .padding(16)
        .background(theme.cardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: theme.shadowColor, radius: 4, x: 0, y: 2)
    }
    
    private func emptyRecommendationsView(theme: Theme) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(theme.successColor.opacity(0.7))
            
            Text(String(localized: "analytics_no_recommendations_title"))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(theme.textColor)
            
            Text(String(localized: "analytics_no_recommendations_description"))
                .font(.caption)
                .foregroundColor(theme.textColor.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 20)
    }
    
    private func recommendationsList(theme: Theme) -> some View {
        VStack(spacing: 12) {
            ForEach(Array(recommendations.enumerated()), id: \.offset) { index, recommendation in
                RecommendationRow(
                    recommendation: recommendation,
                    theme: theme,
                    isFirst: index == 0
                )
            }
        }
    }
}

// MARK: - Supporting Views

struct FeatureUsageRow: View {
    let featureName: String
    let usageCount: Int
    let theme: Theme
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "chart.bar.fill")
                .font(.caption)
                .foregroundColor(theme.infoColor)
                .frame(width: 12)
            
            Text(featureName)
                .font(.caption)
                .foregroundColor(theme.textColor)
                .lineLimit(1)
            
            Spacer()
            
            Text("\(usageCount)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(theme.accentColor)
        }
        .padding(.vertical, 2)
    }
}

struct RecommendationRow: View {
    let recommendation: PersonalizedRecommendation
    let theme: Theme
    let isFirst: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: recommendationIcon)
                    .font(.subheadline)
                    .foregroundColor(priorityColor)
                    .frame(width: 16)
                
                Text(recommendation.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.textColor)
                
                Spacer()
                
                if isFirst {
                    Text(String(localized: "analytics_priority_high"))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(theme.warningColor)
                        .cornerRadius(4)
                }
            }
            
            Text(recommendation.description)
                .font(.caption)
                .foregroundColor(theme.textColor.opacity(0.8))
                .lineLimit(3)
            
            if recommendation.actionable, let actionTitle = recommendation.actionTitle {
                Button(action: {
                    handleRecommendationAction(recommendation)
                }) {
                    Text(actionTitle)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.buttonTextColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(theme.accentColor)
                        .cornerRadius(6)
                }
            }
        }
        .padding(12)
        .background(priorityColor.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var recommendationIcon: String {
        switch recommendation.type {
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
    
    private var priorityColor: Color {
        switch recommendation.priority {
        case .high:
            return theme.warningColor
        case .medium:
            return theme.accentColor
        case .low:
            return theme.infoColor
        }
    }
    
    private func handleRecommendationAction(_ recommendation: PersonalizedRecommendation) {
        // Handle recommendation actions
        // This can be implemented to navigate to specific screens or perform actions
        print("Handling recommendation action: \(recommendation.title)")
    }
}

// MARK: - Analytics Filters View

struct AnalyticsFiltersView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var selectedPeriod: AnalyticsPeriod
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text(String(localized: "analytics_filters_title"))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(theme.textColor)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(String(localized: "analytics_time_period"))
                        .font(.headline)
                        .foregroundColor(theme.textColor)
                    
                    ForEach(AnalyticsPeriod.allCases, id: \.self) { period in
                        Button(action: {
                            selectedPeriod = period
                        }) {
                            HStack {
                                Text(periodDisplayName(period))
                                    .foregroundColor(theme.textColor)
                                
                                Spacer()
                                
                                if selectedPeriod == period {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(theme.accentColor)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(20)
            .background(theme.backgroundColor)
            .navigationTitle(String(localized: "analytics_filters"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "done")) {
                        dismiss()
                    }
                    .foregroundColor(theme.accentColor)
                }
            }
        }
    }
    
    private func periodDisplayName(_ period: AnalyticsPeriod) -> String {
        switch period {
        case .week:
            return String(localized: "analytics_period_week")
        case .month:
            return String(localized: "analytics_period_month")
        case .quarter:
            return String(localized: "analytics_period_quarter")
        case .year:
            return String(localized: "analytics_period_year")
        case .allTime:
            return String(localized: "analytics_period_all_time")
        }
    }
}

// MARK: - Preview

struct RemainingAnalyticsCards_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            StreakInsightsCard(streakData: StreakAnalytics(
                currentStreak: 5,
                longestStreak: 12,
                averageStreakLength: 8.5,
                streakBreakPatterns: [],
                bestStreakDay: 2
            ))
            
            EngagementMetricsCard(engagement: EngagementAnalytics(
                sessionFrequency: 5.0,
                averageSessionDuration: 300,
                mostActiveDay: 2,
                mostActiveHour: 14,
                featureUsage: ["Quests": 25, "Calendar": 15, "Character": 8],
                appOpenFrequency: 7.0
            ))
            
            CustomizationPreferencesCard(customization: CustomizationAnalytics(
                mostUsedPreset: "Warrior",
                customizationFrequency: 3,
                preferredColors: ["Red", "Blue"],
                preferredAccessories: ["Crown", "Sword"],
                lastCustomizationDate: Date()
            ))
            
            RecommendationsSection(recommendations: [
                PersonalizedRecommendation(
                    type: .questCreation,
                    title: "Create More Quests",
                    description: "You've been doing great! Try creating more quests to increase your productivity.",
                    priority: .high,
                    actionable: true,
                    actionTitle: "Create Quest",
                    actionData: nil
                )
            ])
        }
        .environmentObject(ThemeManager.shared)
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}
