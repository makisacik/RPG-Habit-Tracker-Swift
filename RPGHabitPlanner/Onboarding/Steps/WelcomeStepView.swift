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
                Image("AppIcon") // Replace with your actual app icon
                    .resizable()
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)

                VStack(spacing: 8) {
                    Text("RPG Habit Planner")
                        .font(.appFont(size: 32, weight: .bold))
                        .foregroundColor(theme.textColor)

                    Text("Transform your daily tasks into epic adventures")
                        .font(.appFont(size: 16))
                        .foregroundColor(theme.textColor.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
            }

            // Feature highlights
            VStack(spacing: 16) {
                FeatureRow(icon: "sword.fill", text: "Create quests and complete tasks", theme: theme)
                FeatureRow(icon: "trophy.fill", text: "Earn experience and level up", theme: theme)
                FeatureRow(icon: "star.fill", text: "Unlock achievements and rewards", theme: theme)
                FeatureRow(icon: "person.fill", text: "Customize your character", theme: theme)
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
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(theme.accentColor)
                .frame(width: 24)

            Text(text)
                .font(.appFont(size: 16))
                .foregroundColor(theme.textColor)

            Spacer()
        }
    }
}
