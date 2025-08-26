//
//  AnalyticsView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 27.07.2025.
//

import SwiftUI

struct AnalyticsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @StateObject private var analyticsManager = AnalyticsManager.shared
    @State private var selectedTimePeriod: AnalyticsPeriod = .month
    @State private var showFilters = false
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        NavigationView {
            ZStack {
                theme.backgroundColor.ignoresSafeArea()
                
                if analyticsManager.isLoading {
                    loadingView(theme: theme)
                } else if let summary = analyticsManager.analyticsSummary {
                    analyticsContent(summary: summary, theme: theme)
                } else {
                    emptyStateView(theme: theme)
                }
            }
            .navigationTitle(String(localized: "analytics"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        analyticsManager.refreshAnalytics()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(theme.accentColor)
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showFilters.toggle()
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(theme.accentColor)
                    }
                }
            }
            .sheet(isPresented: $showFilters) {
                AnalyticsFiltersView(selectedPeriod: $selectedTimePeriod)
                    .environmentObject(themeManager)
            }
        }
        .onAppear {
            if analyticsManager.analyticsSummary == nil {
                analyticsManager.refreshAnalytics()
            }
        }
    }
    
    // MARK: - Content Views
    
    private func analyticsContent(summary: AnalyticsSummary, theme: Theme) -> some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Header with time period selector
                timePeriodHeader(theme: theme)
                
                // Quest Performance Card
                QuestPerformanceCard(performance: summary.questPerformance)
                    .environmentObject(themeManager)
                
                // Progression Overview Card
                ProgressionOverviewCard(progression: summary.progression)
                    .environmentObject(themeManager)
                
                // Engagement Metrics Card
                EngagementMetricsCard(engagement: summary.engagement)
                    .environmentObject(themeManager)
                
                // Recommendations Section
                RecommendationsSection(recommendations: summary.recommendations)
                    .environmentObject(themeManager)
                
                // Last updated footer
                lastUpdatedFooter(theme: theme)
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
        }
    }
    
    private func timePeriodHeader(theme: Theme) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text(String(localized: "analytics_time_period"))
                    .font(.headline)
                    .foregroundColor(theme.textColor)
                
                Spacer()
                
                Menu {
                    ForEach(AnalyticsPeriod.allCases, id: \.self) { period in
                        Button(action: {
                            selectedTimePeriod = period
                            analyticsManager.refreshAnalytics()
                        }) {
                            HStack {
                                Text(periodDisplayName(period))
                                if selectedTimePeriod == period {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(periodDisplayName(selectedTimePeriod))
                            .foregroundColor(theme.accentColor)
                        Image(systemName: "chevron.down")
                            .foregroundColor(theme.accentColor)
                            .font(.caption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(theme.cardBackgroundColor)
                    .cornerRadius(8)
                }
            }
            
            Divider()
                .background(theme.borderColor)
        }
    }
    
    private func loadingView(theme: Theme) -> some View {
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
    
    private func emptyStateView(theme: Theme) -> some View {
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
    
    private func lastUpdatedFooter(theme: Theme) -> some View {
        HStack {
            Spacer()
            
            Text(String(localized: "analytics_last_updated"))
                .font(.caption)
                .foregroundColor(theme.textColor.opacity(0.6))
            
            Text(analyticsManager.lastUpdated, style: .relative)
                .font(.caption)
                .foregroundColor(theme.textColor.opacity(0.6))
            
            Spacer()
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Helper Methods
    
    private func periodDisplayName(_ period: AnalyticsPeriod) -> String {
        switch period {
        case .week:
            return String(localized: "analytics_period_week")
        case .month:
            return String(localized: "analytics_period_month")
        case .quarter:
            return String(localized: "analytics_period_quarter")
        case .year:
            return String(localized: "analytics_period_year")
        case .allTime:
            return String(localized: "analytics_period_all_time")
        }
    }
}

// MARK: - Analytics Period Extensions

extension AnalyticsPeriod: CaseIterable {
    static var allCases: [AnalyticsPeriod] {
        return [.week, .month, .quarter, .year, .allTime]
    }
}

// MARK: - Preview

struct AnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsView()
            .environmentObject(ThemeManager.shared)
            .environmentObject(LocalizationManager.shared)
    }
}
