//
//  HomeViewSupportingViews.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI

// MARK: - Supporting Views

struct HomeStatCard: View {
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
        .padding(.vertical, 12)
        .frame(height: 110)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.primaryColor)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
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
                                        Text("\(completedTasks)/\(quest.tasks.count) \("tasks".localized)")
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
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
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
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(theme.accentColor)
                .frame(width: 20, height: 20)

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
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(theme.secondaryColor)
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
        .padding(.vertical, 8)
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
        .padding(.vertical, 8)
        .frame(height: 80)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.primaryColor)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

struct CustomTabBar: View {
    @Binding var selected: HomeTab
    let theme: Theme
    let onPlusTapped: () -> Void
    @EnvironmentObject var localizationManager: LocalizationManager

    var body: some View {
        HStack(spacing: 0) {
            // Home Tab
            TabItem(tab: .home, selected: $selected, theme: theme)
            
            // Tracking Tab
            TabItem(tab: .tracking, selected: $selected, theme: theme)
            
            // Plus Button (centered)
            Button(action: {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                onPlusTapped()
            }) {
                ZStack {
                    Circle()
                        .fill(theme.accentColor)
                        .frame(width: 56, height: 56)
                        .shadow(color: theme.shadowColor, radius: 4, x: 0, y: 2)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .offset(y: -20) // Lift it slightly above the tab bar
            
            // Character Tab
            TabItem(tab: .character, selected: $selected, theme: theme)
            
            // Log Tab
            TabItem(tab: .log, selected: $selected, theme: theme)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .padding(.bottom, 8) // Add extra bottom padding for safe area
        .background(
            Rectangle()
                .fill(theme.cardBackgroundColor)
                .shadow(color: theme.shadowColor, radius: 8, y: -2)
        )
        .ignoresSafeArea(.container, edges: .bottom) // Extend into safe area
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Tab Bar")
    }
}

enum HomeTab: Hashable {
    case home
    case tracking
    case character
    case log

    func title(using localizationManager: LocalizationManager) -> String {
        switch self {
        case .home:      return localizationManager.localizedString(for: "home")
        case .tracking:  return localizationManager.localizedString(for: "quests")
        case .character: return localizationManager.localizedString(for: "character")
        case .log:       return localizationManager.localizedString(for: "log")
        }
    }

    var systemImage: String {
        switch self {
        case .home:      return "house.fill"
        case .tracking:  return "list.bullet.clipboard.fill"
        case .character: return "person.crop.circle.fill"
        case .log:       return "chart.bar.xaxis"
        }
    }
}

// MARK: - Tab Item Component

struct TabItem: View {
    let tab: HomeTab
    @Binding var selected: HomeTab
    let theme: Theme
    @EnvironmentObject var localizationManager: LocalizationManager

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                selected = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.systemImage)
                    .font(.system(size: 18, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                    .frame(width: 24, height: 24)
                Text(tab.title(using: localizationManager))
                    .font(.caption2)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(selected == tab ? theme.accentColor : theme.textColor.opacity(0.7))
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.title(using: localizationManager))
        .accessibilityAddTraits(selected == tab ? .isSelected : [])
    }
}
