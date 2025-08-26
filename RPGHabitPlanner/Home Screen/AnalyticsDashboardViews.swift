//
//  AnalyticsDashboardViews.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 27.07.2025.
//

import SwiftUI

// MARK: - Analytics Dashboard Loading and Empty States

struct AnalyticsLoadingView: View {
    let theme: Theme
    let analyticsManager: AnalyticsManager
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: theme.accentColor))
            
            Text(String(localized: "analytics_loading"))
                .font(.headline)
                .foregroundColor(theme.textColor)
            
            Text(String(localized: "analytics_loading_description"))
                .font(.subheadline)
                .foregroundColor(theme.textColor.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

struct AnalyticsEmptyStateView: View {
    let theme: Theme
    let analyticsManager: AnalyticsManager
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 60))
                .foregroundColor(theme.accentColor.opacity(0.5))
            
            Text(String(localized: "analytics_empty_title"))
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(theme.textColor)
            
            Text(String(localized: "analytics_empty_description"))
                .font(.body)
                .foregroundColor(theme.textColor.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {
                analyticsManager.refreshAnalytics()
            }) {
                Text(String(localized: "analytics_refresh"))
                    .font(.headline)
                    .foregroundColor(theme.buttonTextColor)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(theme.accentColor)
                    .cornerRadius(8)
            }
        }
    }
}
