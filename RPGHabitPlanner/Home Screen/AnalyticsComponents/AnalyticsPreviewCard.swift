//
//  AnalyticsPreviewCard.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 27.07.2025.
//

import SwiftUI

struct AnalyticsPreviewCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var analyticsManager = AnalyticsManager.shared

    var body: some View {
        let theme = themeManager.activeTheme

        VStack(spacing: 12) {
            if analyticsManager.isLoading {
                loadingView(theme: theme)
            } else if let summary = analyticsManager.analyticsSummary {
                analyticsPreviewContent(summary: summary, theme: theme)
            } else {
                emptyStateView(theme: theme)
            }
        }
    }

    private func loadingView(theme: Theme) -> some View {
        HStack(spacing: 12) {
            ProgressView()
                .scaleEffect(0.8)
                .progressViewStyle(CircularProgressViewStyle(tint: theme.accentColor))

            Text(String(localized: "analytics_loading"))
                .font(.caption)
                .foregroundColor(theme.textColor.opacity(0.7))
        }
        .frame(height: 60)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.cardBackgroundColor)
        )
    }

    private func analyticsPreviewContent(summary: AnalyticsSummary, theme: Theme) -> some View {
        VStack(spacing: 12) {
            // Quick Stats Row
            HStack(spacing: 16) {
                QuickStatItem(
                    title: String(localized: "total"),
                    value: "\(summary.questPerformance.totalQuests)",
                    icon: "list.bullet.clipboard",
                    color: theme.infoColor
                )

                QuickStatItem(
                    title: String(localized: "finished"),
                    value: "\(summary.questPerformance.finishedQuests)",
                    icon: "checkmark.seal.fill",
                    color: theme.successColor
                )
            }
        }
    }

    private func emptyStateView(theme: Theme) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 24))
                .foregroundColor(theme.textColor.opacity(0.5))

            Text(String(localized: "analytics_empty_title"))
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(theme.textColor.opacity(0.7))

            Text(String(localized: "analytics_empty_description"))
                .font(.caption2)
                .foregroundColor(theme.textColor.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .frame(height: 80)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.cardBackgroundColor)
        )
    }
}

// MARK: - Supporting Views

struct QuickStatItem: View {
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        let theme = themeManager.activeTheme

        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(theme.textColor)

            Text(title)
                .font(.caption)
                .foregroundColor(theme.textColor.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
    }
}

// MARK: - Preview

struct AnalyticsPreviewCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            AnalyticsPreviewCard()
                .environmentObject(ThemeManager.shared)
                .padding()
        }
        .background(Color.gray.opacity(0.1))
    }
}
