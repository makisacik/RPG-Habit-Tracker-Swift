//
//  PremiumIndicatorView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 28.10.2024.
//

import SwiftUI

struct PremiumIndicatorView: View {
    @EnvironmentObject var premiumManager: PremiumManager
    @EnvironmentObject var themeManager: ThemeManager

    let theme: Theme

    init() {
        self.theme = ThemeManager.shared.activeTheme
    }

    var body: some View {
        if premiumManager.isPremium {
            HStack(spacing: 4) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 12))
                    .foregroundColor(theme.accentColor)

                Text("Premium")
                    .font(.appFont(size: 12, weight: .bold))
                    .foregroundColor(theme.accentColor)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(theme.accentColor.opacity(0.1))
            )
        }
    }
}

struct PremiumBadgeView: View {
    @EnvironmentObject var premiumManager: PremiumManager
    @EnvironmentObject var themeManager: ThemeManager

    let theme: Theme

    init() {
        self.theme = ThemeManager.shared.activeTheme
    }

    var body: some View {
        if premiumManager.isPremium {
            Image(systemName: "crown.fill")
                .font(.system(size: 16))
                .foregroundColor(theme.accentColor)
        }
    }
}

struct PremiumLockView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var premiumManager: PremiumManager

    let theme: Theme
    let currentQuestCount: Int

    init(currentQuestCount: Int) {
        self.currentQuestCount = currentQuestCount
        self.theme = ThemeManager.shared.activeTheme
    }

    var body: some View {
        if premiumManager.shouldShowPaywall(currentQuestCount: currentQuestCount) {
            VStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 32))
                    .foregroundColor(theme.textColor.opacity(0.5))

                Text("Quest Limit Reached")
                    .font(.appFont(size: 18, weight: .bold))
                    .foregroundColor(theme.textColor)

                Text("You've reached the quest limit. Upgrade to Premium for unlimited quests!")
                    .font(.appFont(size: 14, weight: .regular))
                    .foregroundColor(theme.textColor.opacity(0.7))
                    .multilineTextAlignment(.center)

                Button("Upgrade to Premium") {
                    // This will be handled by the parent view
                }
                .font(.appFont(size: 16, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [theme.accentColor, theme.accentColor.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(theme.cardBackgroundColor)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
        }
    }
}

struct QuestLimitIndicatorView: View {
    @EnvironmentObject var premiumManager: PremiumManager
    @EnvironmentObject var themeManager: ThemeManager

    let currentQuestCount: Int
    let theme: Theme

    init(currentQuestCount: Int) {
        self.currentQuestCount = currentQuestCount
        self.theme = ThemeManager.shared.activeTheme
    }

    var body: some View {
        if !premiumManager.isPremium {
            HStack(spacing: 8) {
                Image(systemName: "list.bullet.clipboard")
                    .font(.system(size: 14))
                    .foregroundColor(theme.textColor.opacity(0.7))

                Text("Quest Limit")
                    .font(.appFont(size: 14, weight: .medium))
                    .foregroundColor(theme.textColor.opacity(0.7))

                if currentQuestCount >= PremiumManager.freeQuestLimit {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.orange)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(theme.backgroundColor.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(theme.textColor.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        PremiumIndicatorView()
        PremiumBadgeView()
        PremiumLockView(currentQuestCount: 10)
        QuestLimitIndicatorView(currentQuestCount: 8)
    }
    .environmentObject(ThemeManager.shared)
    .environmentObject(PremiumManager.shared)
    .padding()
}
