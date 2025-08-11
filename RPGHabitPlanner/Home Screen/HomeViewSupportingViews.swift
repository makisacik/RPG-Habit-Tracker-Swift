//
//  HomeViewSupportingViews.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI

// MARK: - Supporting Views

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    let theme: Theme
    let action: (() -> Void)?

    init(icon: String, title: String, value: String, color: Color, theme: Theme, action: (() -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.value = value
        self.color = color
        self.theme = theme
        self.action = action
    }

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)

            Text(value)
                .font(.appFont(size: 24, weight: .bold))
                .foregroundColor(theme.textColor)

            Text(title)
                .font(.appFont(size: 12))
                .foregroundColor(theme.textColor.opacity(0.7))
        }
        .frame(height: 90)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.primaryColor)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .padding(.vertical, 8)
        .onTapGesture {
            action?()
        }
    }
}

struct QuestPreviewCard: View {
    let quest: Quest
    let theme: Theme

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(quest.title)
                    .font(.appFont(size: 16, weight: .medium))
                    .foregroundColor(theme.textColor)
                    .lineLimit(1)

                let completedTasks = quest.tasks.filter { $0.isCompleted }.count
                Text("\(completedTasks)/\(quest.tasks.count) \(String.tasks.localized)")
                    .font(.appFont(size: 12))
                    .foregroundColor(theme.textColor.opacity(0.7))
            }

            Spacer()

            // Progress indicator
            ZStack {
                Circle()
                    .stroke(theme.backgroundColor.opacity(0.3), lineWidth: 3)
                    .frame(width: 24, height: 24)

                let completedTasks = quest.tasks.filter { $0.isCompleted }.count
                let progress = quest.tasks.isEmpty ? 0 : Double(completedTasks) / Double(quest.tasks.count)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.green, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 24, height: 24)
                    .rotationEffect(.degrees(-90))
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(theme.primaryColor.opacity(0.5))
        )
    }
}

struct AchievementPreviewCard: View {
    let achievement: AchievementDefinition
    let theme: Theme

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: achievement.iconName)
                .font(.system(size: 20))
                .foregroundColor(.orange)

            VStack(alignment: .leading, spacing: 2) {
                Text(achievement.title)
                    .font(.appFont(size: 14, weight: .medium))
                    .foregroundColor(theme.textColor)
                    .lineLimit(1)

                Text(achievement.description)
                    .font(.appFont(size: 12))
                    .foregroundColor(theme.textColor.opacity(0.7))
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(theme.primaryColor.opacity(0.5))
        )
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let theme: Theme
    let action: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)

            Text(title)
                .font(.appFont(size: 14, weight: .medium))
                .foregroundColor(theme.textColor)

            Text(subtitle)
                .font(.appFont(size: 12))
                .foregroundColor(theme.textColor.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(height: 80)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.primaryColor)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .onTapGesture {
            action()
        }
    }
}

struct NavigationQuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let theme: Theme

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)

            Text(title)
                .font(.appFont(size: 14, weight: .medium))
                .foregroundColor(theme.textColor)

            Text(subtitle)
                .font(.appFont(size: 12))
                .foregroundColor(theme.textColor.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(height: 80)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.primaryColor)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

enum HomeTab: Hashable {
    case home
    case tracking
    case character
    case achievements
    case focusTimer
    case calendar
}
