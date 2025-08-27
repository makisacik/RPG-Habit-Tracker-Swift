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
                Text("recent_achievements".localized)
                    .font(.appFont(size: 20, weight: .bold))
                    .foregroundColor(theme.textColor)

                Spacer()

                Button("view_all".localized) {
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

                    Text("no_achievements_yet".localized)
                        .font(.appFont(size: 16))
                        .foregroundColor(theme.textColor.opacity(0.7))

                    Text("complete_quests_to_earn_achievements".localized)
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
                            Text("quick_actions".localized)
                .font(.appFont(size: 20, weight: .bold))
                .foregroundColor(theme.textColor)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                Button(action: {
                    handleCreateQuestTap()
                }) {
                    NavigationQuickActionCard(
                        icon: "plus.circle.fill",
                        title: "new_quest".localized,
                        subtitle: "create_new_adventure".localized,
                        color: .green,
                        theme: theme
                    )
                }

                NavigationLink(destination: QuickQuestsView(
                    viewModel: QuickQuestsViewModel(questDataService: questDataService)
                )) {
                    NavigationQuickActionCard(
                        icon: "bolt.fill",
                        title: "quick_quests".localized,
                        subtitle: "add_premade_quests".localized,
                        color: .orange,
                        theme: theme
                    )
                }

                QuickActionCard(
                    icon: "person.crop.circle.fill",
                    title: "character".localized,
                    subtitle: "view_your_stats".localized,
                    color: .blue,
                    theme: theme
                ) {
                    selectedTab = .character
                }

                QuickActionCard(
                    icon: "checkmark.seal.fill",
                    title: "finished".localized,
                    subtitle: "view_completed_quests".localized,
                    color: .orange,
                    theme: theme
                ) {
                    isCompletedQuestsPresented.wrappedValue = true
                }

                QuickActionCard(
                    icon: "trophy.fill",
                    title: "achievements".localized,
                    subtitle: "view_your_trophies".localized,
                    color: .purple,
                    theme: theme
                ) {
                    showAchievements = true   // ← was: selectedTab = .achievements
                }

                QuickActionCard(
                    icon: "cart.fill",
                    title: "shop".localized,
                    subtitle: "buy_items_with_coins".localized,
                    color: .yellow,
                    theme: theme
                ) {
                    selectedTab = .shop
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
