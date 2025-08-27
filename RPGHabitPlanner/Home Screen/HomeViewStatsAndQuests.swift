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
            HomeStatCard(
                icon: "list.bullet.clipboard",
                title: "active".localized,
                value: "",
                color: .blue,
                theme: theme
            ) {
                    selectedTab = .tracking
            }

            HomeStatCard(
                icon: "checkmark.seal.fill",
                title: "completed".localized,
                value: "",
                color: .green,
                theme: theme
            ) {
                    isCompletedQuestsPresented.wrappedValue = true
            }

            HomeStatCard(
                icon: "trophy.fill",
                title: "achievements".localized,
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
                Text("active_quests".localized)
                    .font(.appFont(size: 20, weight: .bold))
                    .foregroundColor(theme.textColor)

                Spacer()

                Button("view_all".localized) {
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

                    Text("no_active_quests".localized)
                        .font(.appFont(size: 16))
                        .foregroundColor(theme.textColor.opacity(0.7))

                    NavigationLink(destination: QuestCreationView(
                        viewModel: QuestCreationViewModel(questDataService: questDataService)
                    )) {
                        Text("create_quest".localized)
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
    
    var analyticsSection: some View {
        let theme = themeManager.activeTheme
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("analytics".localized)
                    .font(.appFont(size: 20, weight: .bold))
                    .foregroundColor(theme.textColor)
                
                Spacer()
                
                NavigationLink(destination: AnalyticsView()) {
                    Text("view_all".localized)
                        .font(.appFont(size: 14, weight: .medium))
                        .foregroundColor(.blue)
                }
            }
            
            // Analytics Preview Card
            AnalyticsPreviewCard()
                .environmentObject(themeManager)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.primaryColor)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}
