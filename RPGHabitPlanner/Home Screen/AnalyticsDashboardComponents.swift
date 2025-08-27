//
//  AnalyticsDashboardComponents.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 27.07.2025.
//

import SwiftUI

// MARK: - Analytics Dashboard Supporting Components

struct QuickStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let theme: Theme
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(theme.textColor)
            
            Text(title)
                .font(.caption)
                .foregroundColor(theme.textColor.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(theme.cardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: theme.shadowColor, radius: 2, x: 0, y: 1)
    }
}

struct ActivityRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let theme: Theme
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(color)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(theme.textColor)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(theme.textColor.opacity(0.7))
            }
            
            Spacer()
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let theme: Theme
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(theme.textColor)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(color.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

// MARK: - Placeholder for Detailed View

struct AnalyticsDetailedView: View {
    let selectedTab: AnalyticsDashboardView.AnalyticsTab
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        NavigationView {
            VStack {
                Text(String(format: "analytics_detailed_view_title".localized, selectedTab.displayName))
                    .font(.title)
                    .foregroundColor(theme.textColor)
                
                Text(String(format: "analytics_detailed_view_description".localized, selectedTab.displayName))
                    .foregroundColor(theme.textColor.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(theme.backgroundColor)
            .navigationTitle(selectedTab.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("done".localized) {
                        dismiss()
                    }
                    .foregroundColor(theme.accentColor)
                }
            }
        }
    }
}
