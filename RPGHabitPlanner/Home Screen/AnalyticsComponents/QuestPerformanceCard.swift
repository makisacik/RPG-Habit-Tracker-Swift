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
                    .foregroundColor(theme.textColor)
                    .font(.title2)
                
                Text("analytics_quest_performance".localized)
                    .font(.appFont(size: 16, weight: .medium))
                    .foregroundColor(theme.textColor)
                
                Spacer()
                
                Text("analytics_performance_score".localized)
                    .font(.appFont(size: 12))
                    .foregroundColor(theme.textColor.opacity(0.7))
            }
            
            // First Row - 2 Stats
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatItem(
                    title: "analytics_total_quests".localized,
                    value: "\(performance.totalQuests)",
                    icon: "list.bullet",
                    color: theme.infoColor
                )
                
                StatItem(
                    title: "analytics_finished_quests".localized,
                    value: "\(performance.finishedQuests)",
                    icon: "checkmark.seal.fill",
                    color: .green
                )
            }
            
            // Second Row - 2 Stats
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatItem(
                    title: "analytics_completion_rate".localized,
                    value: "\(Int(performance.completionRate * 100))%",
                    icon: "percent",
                    color: theme.accentColor
                )
                
                // StatItem(
                //     title: "analytics_partially_completed_quests".localized,
                //     value: "\(performance.partiallyCompletedQuests)",
                //     icon: "clock.arrow.circlepath",
                //     color: theme.warningColor
                // )
                
                StatItem(
                    title: "analytics_partial_finished".localized,
                    value: "\(Int(performance.partialCompletionRate * 100))%",
                    icon: "chart.line.uptrend.xyaxis",
                    color: theme.infoColor
                )
            }
            
            // Completion Rate Progress Bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("analytics_completion_progress".localized)
                        .font(.appFont(size: 14))
                        .foregroundColor(theme.textColor)
                    
                    Spacer()
                    
                    Text("\(Int(performance.completionRate * 100))%")
                        .font(.appFont(size: 14, weight: .medium))
                        .foregroundColor(theme.textColor)
                }
                
                ProgressView(value: performance.completionRate)
                    .progressViewStyle(LinearProgressViewStyle(tint: theme.accentColor))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
            
            
            // Difficulty Success Rates
            if !performance.difficultySuccessRates.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("analytics_difficulty_success_rates".localized)
                        .font(.appFont(size: 14, weight: .medium))
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


// MARK: - Supporting Views

struct StatItem: View {
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.appFont(size: 20, weight: .medium))
                .foregroundColor(theme.textColor)
            
            Text(title)
                .font(.appFont(size: 12))
                .foregroundColor(theme.textColor.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 8)
    }
}


struct DifficultySuccessRateView: View {
    let difficulty: Int
    let successRate: Double
    let theme: Theme
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(difficulty)")
                .font(.appFont(size: 12, weight: .medium))
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
                    .font(.appFont(size: 10, weight: .medium))
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
