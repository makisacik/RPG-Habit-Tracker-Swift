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
                    .foregroundColor(theme.textColor)
                    .font(.title2)
                
                Text("analytics_progression_overview".localized)
                    .font(.appFont(size: 16, weight: .medium))
                    .foregroundColor(theme.textColor)
                
                Spacer()
            }
            
            
            // Stats Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                CustomStatItem(
                    title: "analytics_total_coins".localized,
                    value: "\(progression.currencyEarned.totalCoinsEarned + 100)",
                    assetName: "icon_gold",
                    color: theme.warningColor,
                    iconSize: 24
                )
                
                CustomStatItem(
                    title: "analytics_total_gems".localized,
                    value: "\(progression.currencyEarned.totalGemsEarned)",
                    assetName: "icon_gem",
                    color: theme.infoColor,
                    iconSize: 28
                )
            }
            
            // Currency Analytics
            VStack(alignment: .leading, spacing: 12) {
                Text("analytics_currency_analytics".localized)
                    .font(.appFont(size: 14, weight: .medium))
                    .foregroundColor(theme.textColor)
                
                VStack(spacing: 8) {
                    InsightRow(
                        icon: "chart.bar.fill",
                        title: "analytics_avg_coins_per_quest".localized,
                        value: String(format: "%.1f", progression.currencyEarned.averageCoinsPerQuest),
                        color: theme.warningColor
                    )
                    
                    InsightRow(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "analytics_earning_rate".localized,
                        value: String(format: "%.0f", progression.currencyEarned.earningRate) + "/week",
                        color: theme.successColor
                    )
                }
            }
            
            // Achievements Section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("analytics_achievements".localized)
                        .font(.appFont(size: 14, weight: .medium))
                        .foregroundColor(theme.textColor)
                    
                    Spacer()
                    
                    Text("\(progression.achievements.unlockedAchievements)/\(progression.achievements.totalAchievements)")
                        .font(.appFont(size: 14, weight: .medium))
                        .foregroundColor(theme.textColor)
                }
                
                // Achievement Progress Bar
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("analytics_achievement_progress".localized)
                            .font(.appFont(size: 12))
                            .foregroundColor(theme.textColor.opacity(0.7))
                        
                        Spacer()
                        
                        Text("\(Int(progression.achievements.unlockRate * 100))%")
                            .font(.appFont(size: 12, weight: .medium))
                            .foregroundColor(theme.textColor)
                    }
                    
                    ProgressView(value: min(max(progression.achievements.unlockRate, 0.0), 1.0))
                        .progressViewStyle(LinearProgressViewStyle(tint: theme.accentColor))
                        .scaleEffect(x: 1, y: 1.5, anchor: .center)
                }
                
                // Recent Achievements
                if !progression.achievements.recentUnlocks.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("analytics_recent_achievements".localized)
                            .font(.appFont(size: 12, weight: .medium))
                            .foregroundColor(theme.textColor)
                        
                        ForEach(progression.achievements.recentUnlocks.prefix(3), id: \.id) { achievement in
                            AchievementRow(achievement: achievement, theme: theme)
                        }
                    }
                }
                
                // Next Achievements
                if !progression.achievements.nextAchievements.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("analytics_next_achievements".localized)
                            .font(.appFont(size: 12, weight: .medium))
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

struct CustomStatItem: View {
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    let value: String
    let assetName: String
    let color: Color
    let iconSize: CGFloat
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        VStack(spacing: 8) {
            Image(assetName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: iconSize, height: iconSize)
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
                .font(.appFont(size: 12))
                .foregroundColor(isLocked ? theme.textColor.opacity(0.5) : theme.warningColor)
                .frame(width: 12)
            
            Text(achievement.title)
                .font(.appFont(size: 12))
                .foregroundColor(isLocked ? theme.textColor.opacity(0.5) : theme.textColor)
                .lineLimit(1)
            
            Spacer()
            
            if !isLocked {
                Image(systemName: "checkmark.circle.fill")
                    .font(.appFont(size: 12))
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
                totalCoinsSpent: 0,
                totalGemsSpent: 0,
                currentCoins: 950,
                currentGems: 35,
                averageCoinsPerQuest: 12.5,
                averageGemsPerQuest: 0.8,
                earningRate: 75.0,
                transactions: []
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
