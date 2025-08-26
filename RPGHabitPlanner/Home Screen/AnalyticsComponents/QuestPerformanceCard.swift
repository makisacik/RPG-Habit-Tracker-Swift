//
//  QuestPerformanceCard.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 27.07.2025.
//

import SwiftUI

struct QuestPerformanceCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let performance: QuestPerformanceData
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        return VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(theme.accentColor)
                    .font(.title2)
                
                Text(String(localized: "analytics_quest_performance"))
                    .font(.headline)
                    .foregroundColor(theme.textColor)
                
                Spacer()
                
                Text(String(localized: "analytics_performance_score"))
                    .font(.caption)
                    .foregroundColor(theme.textColor.opacity(0.7))
            }
            
            // Main Stats Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatItem(
                    title: String(localized: "analytics_total_quests"),
                    value: "\(performance.totalQuests)",
                    icon: "list.bullet",
                    color: theme.infoColor
                )
                
                StatItem(
                    title: String(localized: "analytics_finished_quests"),
                    value: "\(performance.finishedQuests)",
                    icon: "checkmark.circle.fill",
                    color: theme.successColor
                )
                
                StatItem(
                    title: String(localized: "analytics_completion_rate"),
                    value: "\(Int(performance.completionRate * 100))%",
                    icon: "percent",
                    color: theme.accentColor
                )
            }
            
            // Additional Stats
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatItem(
                    title: String(localized: "analytics_partially_completed_quests"),
                    value: "\(performance.partiallyCompletedQuests)",
                    icon: "clock.arrow.circlepath",
                    color: theme.warningColor
                )
                
                StatItem(
                    title: String(localized: "analytics_partial_completion_rate"),
                    value: "\(Int(performance.partialCompletionRate * 100))%",
                    icon: "chart.line.uptrend.xyaxis",
                    color: theme.infoColor
                )
            }
            
            // Completion Rate Progress Bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(String(localized: "analytics_completion_progress"))
                        .font(.subheadline)
                        .foregroundColor(theme.textColor)
                    
                    Spacer()
                    
                    Text("\(Int(performance.completionRate * 100))%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.accentColor)
                }
                
                ProgressView(value: performance.completionRate)
                    .progressViewStyle(LinearProgressViewStyle(tint: theme.accentColor))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
            
            // Performance Insights
            VStack(alignment: .leading, spacing: 12) {
                Text(String(localized: "analytics_performance_insights"))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.textColor)
                
                VStack(spacing: 8) {
                    InsightRow(
                        icon: "clock.fill",
                        title: String(localized: "analytics_avg_completion_time"),
                        value: formatTimeInterval(performance.averageCompletionTime),
                        color: theme.infoColor
                    )
                    
                    InsightRow(
                        icon: "sun.max.fill",
                        title: String(localized: "analytics_most_productive_hour"),
                        value: formatHour(performance.mostProductiveHour),
                        color: theme.warningColor
                    )
                    
                    InsightRow(
                        icon: "star.fill",
                        title: String(localized: "analytics_preferred_difficulty"),
                        value: "\(performance.preferredDifficulty)/5",
                        color: theme.accentColor
                    )
                }
            }
            
            // Difficulty Success Rates
            if !performance.difficultySuccessRates.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "analytics_difficulty_success_rates"))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.textColor)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        ForEach(1...5, id: \.self) { difficulty in
                            DifficultySuccessRateView(
                                difficulty: difficulty,
                                successRate: performance.difficultySuccessRates[difficulty] ?? 0.0,
                                theme: theme
                            )
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(theme.cardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: theme.shadowColor, radius: 4, x: 0, y: 2)
    }
}

// MARK: - Helper Methods

extension QuestPerformanceCard {
    private func formatTimeInterval(_ timeInterval: TimeInterval) -> String {
        if timeInterval == 0 {
            return String(localized: "analytics_no_data")
        }
        
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) % 3600 / 60
        
        if hours > 0 {
            return String(localized: "analytics_time_hours_minutes")
                .replacingOccurrences(of: "{hours}", with: "\(hours)")
                .replacingOccurrences(of: "{minutes}", with: "\(minutes)")
        } else {
            return String(localized: "analytics_time_minutes")
                .replacingOccurrences(of: "{minutes}", with: "\(minutes)")
        }
    }
    
    private func formatHour(_ hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        
        let date = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) ?? Date()
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Views

struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 8)
    }
}

struct InsightRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(color)
                .frame(width: 16)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
    }
}

struct DifficultySuccessRateView: View {
    let difficulty: Int
    let successRate: Double
    let theme: Theme
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(difficulty)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(theme.textColor)
            
            ZStack {
                Circle()
                    .stroke(theme.borderColor, lineWidth: 2)
                    .frame(width: 32, height: 32)
                
                Circle()
                    .trim(from: 0, to: successRate)
                    .stroke(successRateColor, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .frame(width: 32, height: 32)
                    .rotationEffect(.degrees(-90))
                
                Text("\(Int(successRate * 100))%")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(theme.textColor)
            }
        }
    }
    
    private var successRateColor: Color {
        if successRate >= 0.8 {
            return theme.successColor
        } else if successRate >= 0.6 {
            return theme.warningColor
        } else {
            return theme.errorColor
        }
    }
}

// MARK: - Preview

struct QuestPerformanceCard_Previews: PreviewProvider {
    static var previews: some View {
        QuestPerformanceCard(performance: QuestPerformanceData(
            totalQuests: 25,
            finishedQuests: 18,
            partiallyCompletedQuests: 5,
            completionRate: 0.72,
            partialCompletionRate: 0.92,
            averageCompletionTime: 3600, // 1 hour
            mostProductiveHour: 14,
            preferredDifficulty: 3,
            streakData: StreakAnalytics(
                currentStreak: 5,
                longestStreak: 12,
                averageStreakLength: 8.5,
                streakBreakPatterns: [],
                bestStreakDay: 2
            ),
            weeklyTrends: [],
            difficultySuccessRates: [
                1: 0.9,
                2: 0.85,
                3: 0.72,
                4: 0.6,
                5: 0.4
            ]
        ))
        .environmentObject(ThemeManager.shared)
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}
