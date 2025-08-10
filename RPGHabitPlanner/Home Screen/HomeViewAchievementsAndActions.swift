//
//  HomeViewAchievementsAndActions.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI

// MARK: - HomeView Achievements and Actions Sections Extension

extension HomeView {
    var recentAchievementsSection: some View {
        let theme = themeManager.activeTheme
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Achievements")
                    .font(.appFont(size: 20, weight: .bold))
                    .foregroundColor(theme.textColor)

                Spacer()

                Button("View All") {
                    showAchievements = true
                }
                .font(.appFont(size: 14, weight: .medium))
                .foregroundColor(.blue)
            }

            if !viewModel.recentAchievements.isEmpty {
                VStack(spacing: 8) {
                    ForEach(viewModel.recentAchievements.prefix(2), id: \.id) { achievement in
                        AchievementPreviewCard(achievement: achievement, theme: theme)
                            .onTapGesture { showAchievements = true }
                    }
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "trophy")
                        .font(.system(size: 32))
                        .foregroundColor(theme.textColor.opacity(0.5))

                    Text("No achievements yet")
                        .font(.appFont(size: 16))
                        .foregroundColor(theme.textColor.opacity(0.7))

                    Text("Complete quests to earn achievements!")
                        .font(.appFont(size: 14))
                        .foregroundColor(theme.textColor.opacity(0.5))
                        .multilineTextAlignment(.center)
                }
                .frame(height: 100)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.primaryColor.opacity(0.5))
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.primaryColor)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    func quickActionsSection(isCompletedQuestsPresented: Binding<Bool>) -> some View {
        let theme = themeManager.activeTheme
        
        return VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.appFont(size: 20, weight: .bold))
                .foregroundColor(theme.textColor)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                NavigationLink(destination: QuestCreationView(
                    viewModel: QuestCreationViewModel(questDataService: questDataService)
                )) {
                    NavigationQuickActionCard(
                        icon: "plus.circle.fill",
                        title: "New Quest",
                        subtitle: "Create a new adventure",
                        color: .green,
                        theme: theme
                    )
                }
                
                NavigationLink(destination: QuickQuestsView(
                    viewModel: QuickQuestsViewModel(questDataService: questDataService)
                )) {
                    NavigationQuickActionCard(
                        icon: "bolt.fill",
                        title: "Quick Quests",
                        subtitle: "Add premade quests",
                        color: .orange,
                        theme: theme
                    )
                }
                
                QuickActionCard(
                    icon: "person.crop.circle.fill",
                    title: "Character",
                    subtitle: "View your stats",
                    color: .blue,
                    theme: theme
                ) {
                    selectedTab = .character
                }
                
                QuickActionCard(
                    icon: "checkmark.seal.fill",
                    title: "Completed",
                    subtitle: "View completed quests",
                    color: .orange,
                    theme: theme
                ) {
                    isCompletedQuestsPresented.wrappedValue = true
                }
                
                QuickActionCard(
                    icon: "trophy.fill",
                    title: "Achievements",
                    subtitle: "View your trophies",
                    color: .purple,
                    theme: theme
                ) {
                    showAchievements = true   // ← was: selectedTab = .achievements
                }
                
                QuickActionCard(
                    icon: "timer",
                    title: "Focus Timer",
                    subtitle: "Battle distractions",
                    color: .red,
                    theme: theme
                ) {
                    selectedTab = .focusTimer
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.primaryColor)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}
