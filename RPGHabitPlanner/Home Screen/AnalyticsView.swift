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
        .navigationTitle("analytics".localized)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
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
        .onAppear {
            analyticsManager.loadAnalyticsIfNeeded()
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
                
                
                // Recommendations Section
                RecommendationsSection(recommendations: summary.recommendations)
                    .environmentObject(themeManager)
                
                // Last updated footer
                lastUpdatedFooter(theme: theme)
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
        }
        .refreshable {
            analyticsManager.forceRefreshAnalytics()
        }
    }
    
    private func timePeriodHeader(theme: Theme) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("analytics_time_period".localized)
                    .font(.appFont(size: 16, weight: .medium))
                    .foregroundColor(theme.textColor)
                
                Spacer()
                
                Menu {
                    ForEach(AnalyticsPeriod.allCases, id: \.self) { period in
                        Button(action: {
                            selectedTimePeriod = period
                            analyticsManager.forceRefreshAnalytics()
                        }) {
                            HStack {
                                Text(periodDisplayName(period))
                                    .font(.appFont(size: 14))
                                    .foregroundColor(theme.textColor)
                                if selectedTimePeriod == period {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(theme.textColor)
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(periodDisplayName(selectedTimePeriod))
                            .font(.appFont(size: 14, weight: .medium))
                            .foregroundColor(theme.textColor)
                        Image(systemName: "chevron.down")
                            .foregroundColor(theme.textColor)
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
            
            Text("analytics_loading".localized)
                .font(.appFont(size: 18, weight: .medium))
                .foregroundColor(theme.textColor)
            
            Text("analytics_loading_description".localized)
                .font(.appFont(size: 14))
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
            
            Text("analytics_empty_title".localized)
                .font(.appFont(size: 20, weight: .medium))
                .foregroundColor(theme.textColor)
            
            Text("analytics_empty_description".localized)
                .font(.appFont(size: 14))
                .foregroundColor(theme.textColor.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {
                analyticsManager.forceRefreshAnalytics()
            }) {
                Text("analytics_refresh".localized)
                    .font(.appFont(size: 16, weight: .medium))
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
            
            Text("analytics_last_updated".localized)
                .font(.appFont(size: 12))
                .foregroundColor(theme.textColor.opacity(0.6))
            
            Text(analyticsManager.lastUpdated, style: .relative)
                .font(.appFont(size: 12))
                .foregroundColor(theme.textColor.opacity(0.6))
            
            Spacer()
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Helper Methods
    
    private func periodDisplayName(_ period: AnalyticsPeriod) -> String {
        switch period {
        case .week:
            return "analytics_period_week".localized
        case .month:
            return "analytics_period_month".localized
        case .quarter:
            return "analytics_period_quarter".localized
        case .year:
            return "analytics_period_year".localized
        case .allTime:
            return "analytics_period_all_time".localized
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
