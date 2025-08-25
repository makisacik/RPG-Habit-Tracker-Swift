//
//  WelcomeStepView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 7.01.2025.
//

import SwiftUI

struct WelcomeStepView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    let theme: Theme

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // App logo and title
            VStack(spacing: 20) {
                Image("icon_sword_hd")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(theme.textColor)

                VStack(spacing: 8) {
                    Text(String(localized: "rpg_habit_planner"))
                        .font(.appFont(size: 32, weight: .black))
                        .foregroundColor(theme.textColor)
                        .multilineTextAlignment(.center)

                    Text(String(localized: "transform_daily_tasks_into_epic_adventures"))
                        .font(.appFont(size: 18))
                        .foregroundColor(theme.textColor.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
            }

            // Feature highlights
            VStack(spacing: 16) {
                FeatureRow(icon: "icon_sword", text: String(localized: "create_quests_and_complete_tasks"), theme: theme)
                FeatureRow(icon: "trophy.fill", text: String(localized: "earn_experience_and_level_up"), theme: theme)
                FeatureRow(icon: "star.fill", text: String(localized: "unlock_achievements_and_rewards"), theme: theme)
                FeatureRow(icon: "person.fill", text: String(localized: "customize_your_character"), theme: theme)
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    let theme: Theme

    var body: some View {
        HStack(spacing: 12) {
            if icon.hasPrefix("icon_") {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .foregroundColor(theme.accentColor)
                    .frame(width: 24)
            } else {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(theme.accentColor)
                    .frame(width: 24)
            }

            Text(text)
                .font(.appFont(size: 16))
                .foregroundColor(theme.textColor)

            Spacer()
        }
    }
}
