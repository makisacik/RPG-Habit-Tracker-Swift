//
//  AnalyticsDashboardView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 27.07.2025.
//

import SwiftUI
import Charts

struct AnalyticsDashboardView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @StateObject private var analyticsManager = AnalyticsManager.shared
    @State private var selectedTimePeriod: AnalyticsPeriod = .month
    @State private var selectedTab: AnalyticsTab = .overview
    @State private var showFilters = false
    @State private var showDetailedView = false
    
    enum AnalyticsTab: String, CaseIterable {
        case overview = "overview"
        case performance = "performance"
        case patterns = "patterns"
        case recommendations = "recommendations"
        
        var displayName: String {
            switch self {
            case .overview:
                return String(localized: "analytics_tab_overview")
            case .performance:
                return String(localized: "analytics_tab_performance")
            case .patterns:
                return String(localized: "analytics_tab_patterns")
            case .recommendations:
                return String(localized: "analytics_tab_recommendations")
            }
        }
        
        var icon: String {
            switch self {
            case .overview:
                return "chart.bar.fill"
            case .performance:
                return "target"
            case .patterns:
                return "chart.line.uptrend.xyaxis"
            case .recommendations:
                return "lightbulb.fill"
            }
        }
    }
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        NavigationView {
            ZStack {
                theme.backgroundColor.ignoresSafeArea()
                
                if analyticsManager.isLoading {
                    AnalyticsLoadingView(theme: theme, analyticsManager: analyticsManager)
                } else if let summary = analyticsManager.analyticsSummary {
                    dashboardContent(summary: summary, theme: theme)
                } else {
                    AnalyticsEmptyStateView(theme: theme, analyticsManager: analyticsManager)
                }
            }
            .navigationTitle(String(localized: "analytics_dashboard"))
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
            .sheet(isPresented: $showDetailedView) {
                AnalyticsDetailedView(selectedTab: selectedTab)
                    .environmentObject(themeManager)
            }
        }
        .onAppear {
            analyticsManager.refreshAnalytics()
        }
    }
    
    // MARK: - Dashboard Content
    
    private func dashboardContent(summary: AnalyticsSummary, theme: Theme) -> some View {
        VStack(spacing: 0) {
            // Tab Selector
            tabSelector(theme: theme)
            
            // Content based on selected tab
            TabView(selection: $selectedTab) {
                overviewTab(summary: summary, theme: theme)
                    .tag(AnalyticsTab.overview)
                
                performanceTab(summary: summary, theme: theme)
                    .tag(AnalyticsTab.performance)
                
                patternsTab(summary: summary, theme: theme)
                    .tag(AnalyticsTab.patterns)
                
                recommendationsTab(summary: summary, theme: theme)
                    .tag(AnalyticsTab.recommendations)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
    }
    
    // MARK: - Tab Selector
    
    private func tabSelector(theme: Theme) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(AnalyticsTab.allCases, id: \.self) { tab in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedTab = tab
                        }
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 20))
                                .foregroundColor(selectedTab == tab ? theme.accentColor : theme.textColor.opacity(0.6))
                            
                            Text(tab.displayName)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(selectedTab == tab ? theme.accentColor : theme.textColor.opacity(0.6))
                        }
                        .frame(width: 80, height: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedTab == tab ? theme.accentColor.opacity(0.1) : Color.clear)
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 8)
        .background(theme.cardBackgroundColor)
    }
    
    // MARK: - Overview Tab
    
    private func overviewTab(summary: AnalyticsSummary, theme: Theme) -> some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Quick Stats Grid
                quickStatsGrid(summary: summary, theme: theme)
                
                // Performance Overview
                performanceOverviewCard(summary: summary, theme: theme)
                
                // Streak Status
                streakStatusCard(summary: summary, theme: theme)
                
                // Recent Activity
                recentActivityCard(summary: summary, theme: theme)
                
                // Quick Actions
                quickActionsCard(theme: theme)
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
        }
    }
    
    // MARK: - Performance Tab
    
    private func performanceTab(summary: AnalyticsSummary, theme: Theme) -> some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Quest Performance Chart
                AnalyticsDashboardPlaceholders.questPerformanceChart(summary: summary, theme: theme)
                
                // Difficulty Analysis
                AnalyticsDashboardPlaceholders.difficultyAnalysisCard(summary: summary, theme: theme)
                
                // Completion Trends
                AnalyticsDashboardPlaceholders.completionTrendsCard(summary: summary, theme: theme)
                
                // Productivity Heatmap
                AnalyticsDashboardPlaceholders.productivityHeatmapCard(summary: summary, theme: theme)
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
        }
    }
    
    // MARK: - Patterns Tab
    
    private func patternsTab(summary: AnalyticsSummary, theme: Theme) -> some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Activity Patterns
                AnalyticsDashboardPlaceholders.activityPatternsCard(summary: summary, theme: theme)
                
                // Time Analysis
                AnalyticsDashboardPlaceholders.timeAnalysisCard(summary: summary, theme: theme)
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
        }
    }
    
    // MARK: - Recommendations Tab
    
    private func recommendationsTab(summary: AnalyticsSummary, theme: Theme) -> some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Priority Recommendations
                AnalyticsDashboardPlaceholders.priorityRecommendationsCard(summary: summary, theme: theme)
                
                // Improvement Suggestions
                AnalyticsDashboardPlaceholders.improvementSuggestionsCard(summary: summary, theme: theme)
                
                // Goal Setting
                AnalyticsDashboardPlaceholders.goalSettingCard(summary: summary, theme: theme)
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
        }
    }
    
    // MARK: - Quick Stats Grid
    
    private func quickStatsGrid(summary: AnalyticsSummary, theme: Theme) -> some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            QuickStatCard(
                title: String(localized: "analytics_total_quests"),
                value: "\(summary.questPerformance.totalQuests)",
                icon: "list.bullet",
                color: theme.accentColor,
                theme: theme
            )
            
            QuickStatCard(
                title: String(localized: "analytics_completion_rate"),
                value: String(format: "%.1f%%", summary.questPerformance.completionRate * 100),
                icon: "checkmark.seal.fill",
                color: theme.successColor,
                theme: theme
            )
            
            QuickStatCard(
                title: String(localized: "analytics_current_streak"),
                value: "\(summary.questPerformance.streakData.currentStreak)",
                icon: "flame.fill",
                color: theme.warningColor,
                theme: theme
            )
        }
    }
    
    // MARK: - Performance Overview Card
    
    private func performanceOverviewCard(summary: AnalyticsSummary, theme: Theme) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "target")
                    .foregroundColor(theme.textColor)
                    .font(.title2)
                
                Text(String(localized: "analytics_performance_overview"))
                    .font(.headline)
                    .foregroundColor(theme.textColor)
                
                Spacer()
                
                Button("View Details") {
                    selectedTab = .performance
                    showDetailedView = true
                }
                .font(.caption)
                .foregroundColor(theme.accentColor)
            }
            
            // Performance Chart
            Chart {
                ForEach(summary.questPerformance.weeklyTrends, id: \.weekStartDate) { trend in
                    LineMark(
                        x: .value("Week", trend.weekStartDate),
                        y: .value("Completion Rate", trend.completionRate * 100)
                    )
                    .foregroundStyle(theme.accentColor)
                    
                    AreaMark(
                        x: .value("Week", trend.weekStartDate),
                        y: .value("Completion Rate", trend.completionRate * 100)
                    )
                    .foregroundStyle(theme.accentColor.opacity(0.1))
                }
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel {
                        Text("\(value.as(Double.self)?.formatted(.number.precision(.fractionLength(0))) ?? "")%")
                            .font(.caption)
                            .foregroundColor(theme.textColor.opacity(0.7))
                    }
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(date, format: .dateTime.month(.abbreviated).day())
                                .font(.caption)
                                .foregroundColor(theme.textColor.opacity(0.7))
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(theme.cardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: theme.shadowColor, radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Streak Status Card
    
    private func streakStatusCard(summary: AnalyticsSummary, theme: Theme) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(theme.warningColor)
                    .font(.title2)
                
                Text(String(localized: "analytics_streak_status"))
                    .font(.headline)
                    .foregroundColor(theme.textColor)
                
                Spacer()
                
                Text("🔥 \(summary.questPerformance.streakData.currentStreak)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(theme.warningColor)
            }
            
            // Streak Progress
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(String(localized: "analytics_longest_streak"))
                        .font(.subheadline)
                        .foregroundColor(theme.textColor.opacity(0.7))
                    
                    Spacer()
                    
                    Text("\(summary.questPerformance.streakData.longestStreak)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.textColor)
                }
                
                ProgressView(value: Double(min(summary.questPerformance.streakData.currentStreak, summary.questPerformance.streakData.longestStreak)), total: Double(max(1, summary.questPerformance.streakData.longestStreak)))
                    .progressViewStyle(LinearProgressViewStyle(tint: theme.warningColor))
            }
        }
        .padding(16)
        .background(theme.cardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: theme.shadowColor, radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Recent Activity Card
    
    private func recentActivityCard(summary: AnalyticsSummary, theme: Theme) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(theme.textColor)
                    .font(.title2)
                
                Text(String(localized: "analytics_recent_activity"))
                    .font(.headline)
                    .foregroundColor(theme.textColor)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                ActivityRow(
                    icon: "checkmark.circle.fill",
                    title: String(localized: "analytics_last_quest_completed"),
                    subtitle: "2 hours ago",
                    color: theme.successColor,
                    theme: theme
                )
                
                ActivityRow(
                    icon: "plus.circle.fill",
                    title: String(localized: "analytics_new_quest_created"),
                    subtitle: "Yesterday",
                    color: theme.accentColor,
                    theme: theme
                )
            }
        }
        .padding(16)
        .background(theme.cardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: theme.shadowColor, radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Quick Actions Card
    
    private func quickActionsCard(theme: Theme) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(String(localized: "analytics_quick_actions"))
                .font(.headline)
                .foregroundColor(theme.textColor)
            
            HStack(spacing: 12) {
                QuickActionButton(
                    title: String(localized: "create_quest"),
                    icon: "plus.circle.fill",
                    color: theme.accentColor,
                    theme: theme
                ) {
                    // Navigate to quest creation
                }
                
                QuickActionButton(
                    title: String(localized: "view_achievements"),
                    icon: "trophy.fill",
                    color: theme.warningColor,
                    theme: theme
                ) {
                    // Navigate to achievements
                }
                
                QuickActionButton(
                    title: String(localized: "customize_character"),
                    icon: "person.crop.circle.fill",
                    color: theme.infoColor,
                    theme: theme
                ) {
                    // Navigate to character customization
                }
            }
        }
        .padding(16)
        .background(theme.cardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: theme.shadowColor, radius: 4, x: 0, y: 2)
    }
}


// MARK: - Preview

struct AnalyticsDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsDashboardView()
            .environmentObject(ThemeManager.shared)
            .environmentObject(LocalizationManager.shared)
    }
}
