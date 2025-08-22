//
//  HomeViewStatsAndQuests.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI

// MARK: - HomeView Stats and Quests Sections Extension

extension HomeView {
    func quickStatsSection(isCompletedQuestsPresented: Binding<Bool>) -> some View {
        let theme = themeManager.activeTheme

        return LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            StatCard(
                icon: "list.bullet.clipboard",
                title: String.active.localized,
                value: "\(viewModel.activeQuestsCount)",
                color: .blue,
                theme: theme
            ) {
                    selectedTab = .tracking
            }

            StatCard(
                icon: "checkmark.seal.fill",
                title: String.completed.localized,
                value: "\(viewModel.completedQuestsCount)",
                color: .green,
                theme: theme
            ) {
                    isCompletedQuestsPresented.wrappedValue = true
            }

            StatCard(
                icon: "trophy.fill",
                title: String.achievements.localized,
                value: "\(viewModel.achievementsCount)",
                color: .orange,
                theme: theme
            ) {
                showAchievements = true
            }
        }
    }

    var activeQuestsSection: some View {
        let theme = themeManager.activeTheme

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(String.activeQuests.localized)
                    .font(.appFont(size: 20, weight: .bold))
                    .foregroundColor(theme.textColor)

                Spacer()

                Button(String.viewAll.localized) {
                    selectedTab = .tracking
                }
                .font(.appFont(size: 14, weight: .medium))
                .foregroundColor(.blue)
            }

            if !viewModel.recentActiveQuests.isEmpty {
                VStack(spacing: 8) {
                    ForEach(viewModel.recentActiveQuests.prefix(3), id: \.id) { quest in
                        QuestPreviewCard(quest: quest, theme: theme)
                    }
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "list.bullet.clipboard")
                        .font(.system(size: 32))
                        .foregroundColor(theme.textColor.opacity(0.5))

                    Text(String.noActiveQuests.localized)
                        .font(.appFont(size: 16))
                        .foregroundColor(theme.textColor.opacity(0.7))

                    NavigationLink(destination: QuestCreationView(
                        viewModel: QuestCreationViewModel(questDataService: questDataService)
                    )) {
                        Text(String.createQuest.localized)
                            .font(.appFont(size: 14, weight: .medium))
                            .foregroundColor(.blue)
                    }
                    .font(.appFont(size: 14, weight: .medium))
                    .foregroundColor(.blue)
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
}
