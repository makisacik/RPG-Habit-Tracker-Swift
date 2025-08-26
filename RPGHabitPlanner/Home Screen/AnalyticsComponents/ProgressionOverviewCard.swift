//
//  ProgressionOverviewCard.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 27.07.2025.
//

import SwiftUI

struct ProgressionOverviewCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let progression: ProgressionAnalytics
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "arrow.up.circle.fill")
                    .foregroundColor(theme.accentColor)
                    .font(.title2)
                
                Text(String(localized: "analytics_progression_overview"))
                    .font(.headline)
                    .foregroundColor(theme.textColor)
                
                Spacer()
                
                Text("Level \(progression.currentLevel)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.accentColor)
            }
            
            // Level Progress
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(String(localized: "analytics_level_progress"))
                        .font(.subheadline)
                        .foregroundColor(theme.textColor)
                    
                    Spacer()
                    
                    Text("\(Int(progression.experienceProgress * 100))%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.accentColor)
                }
                
                ProgressView(value: progression.experienceProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: theme.accentColor))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                
                HStack {
                    Text("\(progression.totalExperience) XP")
                        .font(.caption)
                        .foregroundColor(theme.textColor.opacity(0.7))
                    
                    Spacer()
                    
                    Text("\(progression.experienceToNextLevel) XP to next level")
                        .font(.caption)
                        .foregroundColor(theme.textColor.opacity(0.7))
                }
            }
            
            // Stats Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatItem(
                    title: String(localized: "analytics_level_up_rate"),
                    value: String(format: "%.1f", progression.levelUpRate),
                    icon: "chart.line.uptrend.xyaxis",
                    color: theme.successColor
                )
                
                StatItem(
                    title: String(localized: "analytics_total_coins"),
                    value: "\(progression.currencyEarned.totalCoinsEarned)",
                    icon: "dollarsign.circle.fill",
                    color: theme.warningColor
                )
                
                StatItem(
                    title: String(localized: "analytics_total_gems"),
                    value: "\(progression.currencyEarned.totalGemsEarned)",
                    icon: "diamond.fill",
                    color: theme.infoColor
                )
            }
            
            // Currency Analytics
            VStack(alignment: .leading, spacing: 12) {
                Text(String(localized: "analytics_currency_analytics"))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.textColor)
                
                VStack(spacing: 8) {
                    InsightRow(
                        icon: "chart.bar.fill",
                        title: String(localized: "analytics_avg_coins_per_quest"),
                        value: String(format: "%.1f", progression.currencyEarned.averageCoinsPerQuest),
                        color: theme.warningColor
                    )
                    
                    InsightRow(
                        icon: "chart.bar.fill",
                        title: String(localized: "analytics_avg_gems_per_quest"),
                        value: String(format: "%.1f", progression.currencyEarned.averageGemsPerQuest),
                        color: theme.infoColor
                    )
                    
                    InsightRow(
                        icon: "chart.line.uptrend.xyaxis",
                        title: String(localized: "analytics_earning_rate"),
                        value: String(format: "%.0f", progression.currencyEarned.earningRate) + "/week",
                        color: theme.successColor
                    )
                }
            }
            
            // Achievements Section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(String(localized: "analytics_achievements"))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.textColor)
                    
                    Spacer()
                    
                    Text("\(progression.achievements.unlockedAchievements)/\(progression.achievements.totalAchievements)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.accentColor)
                }
                
                // Achievement Progress Bar
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(String(localized: "analytics_achievement_progress"))
                            .font(.caption)
                            .foregroundColor(theme.textColor.opacity(0.7))
                        
                        Spacer()
                        
                        Text("\(Int(progression.achievements.unlockRate * 100))%")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(theme.accentColor)
                    }
                    
                    ProgressView(value: progression.achievements.unlockRate)
                        .progressViewStyle(LinearProgressViewStyle(tint: theme.accentColor))
                        .scaleEffect(x: 1, y: 1.5, anchor: .center)
                }
                
                // Recent Achievements
                if !progression.achievements.recentUnlocks.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(String(localized: "analytics_recent_achievements"))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(theme.textColor)
                        
                        ForEach(progression.achievements.recentUnlocks.prefix(3), id: \.id) { achievement in
                            AchievementRow(achievement: achievement, theme: theme)
                        }
                    }
                }
                
                // Next Achievements
                if !progression.achievements.nextAchievements.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(String(localized: "analytics_next_achievements"))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(theme.textColor)
                        
                        ForEach(progression.achievements.nextAchievements.prefix(3), id: \.id) { achievement in
                            AchievementRow(achievement: achievement, theme: theme, isLocked: true)
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

struct AchievementRow: View {
    let achievement: AchievementDefinition
    let theme: Theme
    let isLocked: Bool
    
    init(achievement: AchievementDefinition, theme: Theme, isLocked: Bool = false) {
        self.achievement = achievement
        self.theme = theme
        self.isLocked = isLocked
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isLocked ? "lock.fill" : "trophy.fill")
                .font(.caption)
                .foregroundColor(isLocked ? theme.textColor.opacity(0.5) : theme.warningColor)
                .frame(width: 12)
            
            Text(achievement.title)
                .font(.caption)
                .foregroundColor(isLocked ? theme.textColor.opacity(0.5) : theme.textColor)
                .lineLimit(1)
            
            Spacer()
            
            if !isLocked {
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(theme.successColor)
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Preview

struct ProgressionOverviewCard_Previews: PreviewProvider {
    static var previews: some View {
        ProgressionOverviewCard(progression: ProgressionAnalytics(
            currentLevel: 15,
            experienceProgress: 0.75,
            experienceToNextLevel: 2500,
            totalExperience: 12500,
            levelUpRate: 1.2,
            currencyEarned: CurrencyAnalytics(
                totalCoinsEarned: 1250,
                totalGemsEarned: 45,
                averageCoinsPerQuest: 12.5,
                averageGemsPerQuest: 0.8,
                earningRate: 75.0
            ),
            achievements: AchievementAnalytics(
                totalAchievements: 25,
                unlockedAchievements: 18,
                unlockRate: 0.72,
                                          recentUnlocks: [
                              AchievementDefinition(id: "1", title: "First Steps", description: "Complete your first quest", iconName: "star.fill", category: .quests, requirement: .questCount(1)),
                              AchievementDefinition(id: "2", title: "Streak Master", description: "Maintain a 7-day streak", iconName: "flame.fill", category: .quests, requirement: .consecutiveDays(7))
                                          ],
                          nextAchievements: [
                              AchievementDefinition(id: "3", title: "Quest Master", description: "Complete 50 quests", iconName: "crown.fill", category: .quests, requirement: .questCount(50)),
                              AchievementDefinition(id: "4", title: "Level Up", description: "Reach level 20", iconName: "arrow.up.circle.fill", category: .leveling, requirement: .level(20))
                          ]
            )
        ))
        .environmentObject(ThemeManager.shared)
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}
