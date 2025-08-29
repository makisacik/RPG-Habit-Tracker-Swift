//
//  AnalyticsManager.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 27.07.2025.
//

import Foundation
import CoreData
import Combine

@MainActor
final class AnalyticsManager: ObservableObject {
    static let shared = AnalyticsManager()
    
    @Published var analyticsSummary: AnalyticsSummary?
    @Published var isLoading = false
    @Published var lastUpdated = Date()
    
    private let questDataService: QuestDataServiceProtocol
    private let userManager: UserManager
    let achievementManager: AchievementManager // Made accessible to extensions
    let streakManager: StreakManager // Made accessible to extensions
    let customizationService: CharacterCustomizationService // Made accessible to extensions
    
    private var cancellables = Set<AnyCancellable>()
    private var refreshDebounceTimer: Timer?
    private var isCalculating = false
    private var lastCalculationTime = Date.distantPast
    let calendar = Calendar.current // Made accessible to extensions
    
    private init() {
        self.questDataService = QuestCoreDataService()
        self.userManager = UserManager()
        self.achievementManager = AchievementManager.shared
        self.streakManager = StreakManager.shared
        self.customizationService = CharacterCustomizationService()
        
        setupObservers()
    }
    
    // MARK: - Public Methods
    
    func refreshAnalytics(completion: @escaping (AnalyticsSummary?) -> Void = { _ in }) {
        // Rate limiting: prevent rapid successive calls
        let now = Date()
        let timeSinceLastCalculation = now.timeIntervalSince(lastCalculationTime)
        
        if isCalculating || timeSinceLastCalculation < 1.0 {
            // If already calculating or called too recently, skip
            completion(analyticsSummary)
            return
        }
        
        // Only show loading if we don't have cached data
        let shouldShowLoading = analyticsSummary == nil
        if shouldShowLoading {
            isLoading = true
        }
        
        isCalculating = true
        lastCalculationTime = now
        
        Task {
            let summary = await calculateAnalyticsSummary()
            
            await MainActor.run {
                self.analyticsSummary = summary
                self.lastUpdated = Date()
                self.isLoading = false
                self.isCalculating = false
                completion(summary)
            }
        }
    }
    
    /// Load analytics data without showing loading state if cached data exists
    func loadAnalyticsIfNeeded() {
        // If we already have data, don't show loading
        if analyticsSummary != nil {
            return
        }
        
        // Only load if not already calculating
        if !isCalculating {
            refreshAnalytics()
        }
    }
    
    /// Force refresh analytics data (always shows loading)
    func forceRefreshAnalytics(completion: @escaping (AnalyticsSummary?) -> Void = { _ in }) {
        // Reset state to force loading
        analyticsSummary = nil
        refreshAnalytics(completion: completion)
    }

    private func debouncedRefreshAnalytics() {
        // Cancel any existing timer
        refreshDebounceTimer?.invalidate()

        // Set a new timer to refresh after a short delay
        refreshDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            self?.refreshAnalytics()
        }
    }
    
    func getRecommendations() -> [PersonalizedRecommendation] {
        guard let summary = analyticsSummary else { return [] }
        
        var recommendations: [PersonalizedRecommendation] = []
        
        // Quest creation recommendations
        if summary.questPerformance.totalQuests < AnalyticsConfiguration.QuestPerformance.minimumQuestsForAnalysis {
            recommendations.append(
                PersonalizedRecommendation(
                    type: .questCreation,
                    title: "analytics_recommendation_create_more_quests_title".localized,
                    description: "analytics_recommendation_create_more_quests_description".localized,
                    priority: .high,
                    actionable: true,
                    actionTitle: "create_quest".localized,
                    actionData: nil
                )
            )
        }
        
        // Difficulty adjustment recommendations
        if let difficultyRecommendation = getDifficultyRecommendation(summary: summary) {
            recommendations.append(difficultyRecommendation)
        }
        
        // Streak building recommendations
        if let streakRecommendation = getStreakRecommendation(summary: summary) {
            recommendations.append(streakRecommendation)
        }
        
        // Achievement recommendations
        if let achievementRecommendation = getAchievementRecommendation(summary: summary) {
            recommendations.append(achievementRecommendation)
        }
        
        // Timing recommendations
        if let timingRecommendation = getTimingRecommendation(summary: summary) {
            recommendations.append(timingRecommendation)
        }
        
        return recommendations.sorted { $0.priority.rawValue > $1.priority.rawValue }
    }
    
    // MARK: - Private Methods
    
    private func setupObservers() {
        // Listen for quest changes with debounced refresh to prevent flashing
        NotificationCenter.default.publisher(for: .questCreated)
            .sink { [weak self] _ in
                self?.debouncedRefreshAnalytics()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .questUpdated)
            .sink { [weak self] _ in
                self?.debouncedRefreshAnalytics()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .questDeleted)
            .sink { [weak self] _ in
                self?.debouncedRefreshAnalytics()
            }
            .store(in: &cancellables)
        
        // Listen for user updates (currency changes)
        NotificationCenter.default.publisher(for: .userDidUpdate)
            .sink { [weak self] _ in
                self?.debouncedRefreshAnalytics()
            }
            .store(in: &cancellables)
    }
    
    private func calculateAnalyticsSummary() async -> AnalyticsSummary {
        let questPerformance = await calculateQuestPerformance()
        let progression = await calculateProgressionAnalytics()
        let customization = await calculateCustomizationAnalytics()
        let engagement = await calculateEngagementAnalytics()
        let recommendations = getRecommendations()
        
        return AnalyticsSummary(
            questPerformance: questPerformance,
            progression: progression,
            customization: customization,
            engagement: engagement,
            recommendations: recommendations,
            lastUpdated: Date()
        )
    }
    
    private func calculateQuestPerformance() async -> QuestPerformanceData {
        return await withCheckedContinuation { continuation in
            questDataService.fetchAllQuests { [weak self] quests, error in
                guard let self = self, error == nil else {
                    continuation.resume(returning: self?.getDefaultQuestPerformance() ?? QuestPerformanceData(
                        totalQuests: 0,
                        finishedQuests: 0,
                        partiallyCompletedQuests: 0,
                        completionRate: 0.0,
                        partialCompletionRate: 0.0,
                        averageCompletionTime: 0,
                        mostProductiveHour: AnalyticsConfiguration.TimeAnalytics.defaultMostProductiveHour,
                        preferredDifficulty: AnalyticsConfiguration.QuestPerformance.defaultDifficulty,
                        streakData: self?.getDefaultStreakAnalytics() ?? StreakAnalytics(
                            currentStreak: 0,
                            longestStreak: 0,
                            averageStreakLength: 0.0,
                            streakBreakPatterns: [],
                            bestStreakDay: AnalyticsConfiguration.TimeAnalytics.defaultMostActiveDay
                        ),
                        weeklyTrends: [],
                        difficultySuccessRates: [:]
                    ))
                    return
                }
                
                let finishedQuests = quests.filter { $0.isFinished }
                let partiallyCompletedQuests = quests.filter { $0.isCompleted && !$0.isFinished }
                let completionRate = quests.isEmpty ? 0.0 : Double(finishedQuests.count) / Double(quests.count)
                let partialCompletionRate = quests.isEmpty ? 0.0 : Double(quests.filter { $0.isCompleted }.count) / Double(quests.count)
                
                let averageCompletionTime = self.calculateAverageCompletionTime(quests: finishedQuests)
                let mostProductiveHour = self.calculateMostProductiveHour(quests: finishedQuests)
                let preferredDifficulty = self.calculatePreferredDifficulty(quests: quests)
                let streakData = self.calculateStreakAnalytics()
                let weeklyTrends = self.calculateWeeklyTrends(quests: quests)
                let difficultySuccessRates = self.calculateDifficultySuccessRates(quests: quests)
                
                let performance = QuestPerformanceData(
                    totalQuests: quests.count,
                    finishedQuests: finishedQuests.count,
                    partiallyCompletedQuests: partiallyCompletedQuests.count,
                    completionRate: completionRate,
                    partialCompletionRate: partialCompletionRate,
                    averageCompletionTime: averageCompletionTime,
                    mostProductiveHour: mostProductiveHour,
                    preferredDifficulty: preferredDifficulty,
                    streakData: streakData,
                    weeklyTrends: weeklyTrends,
                    difficultySuccessRates: difficultySuccessRates
                )
                
                continuation.resume(returning: performance)
            }
        }
    }
    
    private func calculateProgressionAnalytics() async -> ProgressionAnalytics {
        return await withCheckedContinuation { continuation in
            userManager.fetchUser { [weak self] user, error in
                guard let user = user, error == nil else {
                    continuation.resume(returning: ProgressionAnalytics(
                                            currentLevel: AnalyticsConfiguration.Progression.defaultLevel,
                    experienceProgress: 0.0,
                    experienceToNextLevel: AnalyticsConfiguration.Progression.defaultExperienceToNextLevel,
                        totalExperience: 0,
                        levelUpRate: 0.0,
                        currencyEarned: CurrencyAnalytics(
                            totalCoinsEarned: 0,
                            totalGemsEarned: 0,
                            totalCoinsSpent: 0,
                            totalGemsSpent: 0,
                            currentCoins: 0,
                            currentGems: 0,
                            averageCoinsPerQuest: 0.0,
                            averageGemsPerQuest: 0.0,
                            earningRate: 0.0,
                            transactions: []
                        ),
                        achievements: AchievementAnalytics(
                            totalAchievements: 0,
                            unlockedAchievements: 0,
                            unlockRate: 0.0,
                            recentUnlocks: [],
                            nextAchievements: []
                        )
                    ))
                    return
                }
                
                let currentLevel = Int(user.level)
                let experienceProgress = self?.calculateExperienceProgress(user: user) ?? 0.0
                let experienceToNextLevel = self?.calculateExperienceToNextLevel(currentLevel: currentLevel) ?? AnalyticsConfiguration.Progression.defaultExperienceToNextLevel
                let levelingSystem = LevelingSystem.shared
                let totalExperience = levelingSystem.calculateTotalExperience(level: Int(user.level), experienceInLevel: Int(user.exp))
                let levelUpRate = self?.calculateLevelUpRate(user: user) ?? 0.0
                
                // Use async call for currency analytics
                Task {
                    let currencyEarned = await self?.calculateCurrencyAnalytics(user: user) ?? CurrencyAnalytics(
                        totalCoinsEarned: Int(user.coins),
                        totalGemsEarned: Int(user.gems),
                        totalCoinsSpent: 0,
                        totalGemsSpent: 0,
                        currentCoins: Int(user.coins),
                        currentGems: Int(user.gems),
                        averageCoinsPerQuest: 0.0,
                        averageGemsPerQuest: 0.0,
                        earningRate: 0.0,
                        transactions: []
                    )

                    let achievements = self?.calculateAchievementAnalytics() ?? AchievementAnalytics(
                        totalAchievements: 0,
                        unlockedAchievements: 0,
                        unlockRate: 0.0,
                        recentUnlocks: [],
                        nextAchievements: []
                    )

                    let progression = ProgressionAnalytics(
                        currentLevel: currentLevel,
                        experienceProgress: experienceProgress,
                        experienceToNextLevel: experienceToNextLevel,
                        totalExperience: totalExperience,
                        levelUpRate: levelUpRate,
                        currencyEarned: currencyEarned,
                        achievements: achievements
                    )

                    continuation.resume(returning: progression)
                }
            }
        }
    }
    
    private func calculateCustomizationAnalytics() async -> CustomizationAnalytics {
        return await withCheckedContinuation { continuation in
            userManager.fetchUser { [weak self] user, error in
                guard let user = user, error == nil else {
                    continuation.resume(returning: CustomizationAnalytics(
                        mostUsedPreset: nil,
                        customizationFrequency: 0,
                        preferredColors: [],
                        preferredAccessories: [],
                        lastCustomizationDate: nil
                    ))
                    return
                }
                
                // Use the new calculation method
                let customization = self?.calculateCustomizationAnalytics(for: user) ?? CustomizationAnalytics(
                    mostUsedPreset: nil,
                    customizationFrequency: 0,
                    preferredColors: [],
                    preferredAccessories: [],
                    lastCustomizationDate: nil
                )
                
                continuation.resume(returning: customization)
            }
        }
    }
    
    private func calculateEngagementAnalytics() async -> EngagementAnalytics {
        return await withCheckedContinuation { continuation in
            questDataService.fetchAllQuests { [weak self] quests, error in
                guard let self = self, error == nil else {
                    continuation.resume(returning: EngagementAnalytics(
                                            sessionFrequency: AnalyticsConfiguration.TimeAnalytics.defaultSessionFrequency,
                    averageSessionDuration: AnalyticsConfiguration.TimeAnalytics.defaultSessionDuration,
                    mostActiveDay: self?.calendar.component(.weekday, from: Date()) ?? AnalyticsConfiguration.TimeAnalytics.defaultMostActiveDay,
                    mostActiveHour: AnalyticsConfiguration.TimeAnalytics.defaultMostProductiveHour,
                        featureUsage: [:],
                        appOpenFrequency: AnalyticsConfiguration.TimeAnalytics.defaultAppOpenFrequency
                    ))
                    return
                }
                
                // Calculate most active hour from quest and task activity
                let mostActiveHour = self.calculateMostProductiveHour(quests: quests)
                
                // Calculate most active day from quest creation and completion dates
                let mostActiveDay = self.calculateMostActiveDay(quests: quests)
                
                // Calculate session frequency based on completion records
                let sessionFrequency = self.calculateSessionFrequency()
                
                // Calculate app open frequency based on quest creation frequency
                let appOpenFrequency = self.calculateAppOpenFrequency(quests: quests)
                
                let engagement = EngagementAnalytics(
                    sessionFrequency: sessionFrequency,
                    averageSessionDuration: AnalyticsConfiguration.TimeAnalytics.defaultSessionDuration,
                    mostActiveDay: mostActiveDay,
                    mostActiveHour: mostActiveHour,
                    featureUsage: [:],
                    appOpenFrequency: appOpenFrequency
                )
                
                continuation.resume(returning: engagement)
            }
        }
    }
    
    
    // MARK: - Default Data Methods
    
    private func getDefaultQuestPerformance() -> QuestPerformanceData {
        return QuestPerformanceData(
            totalQuests: 0,
            finishedQuests: 0,
            partiallyCompletedQuests: 0,
            completionRate: 0.0,
            partialCompletionRate: 0.0,
            averageCompletionTime: 0,
            mostProductiveHour: AnalyticsConfiguration.TimeAnalytics.defaultMostProductiveHour,
            preferredDifficulty: AnalyticsConfiguration.QuestPerformance.defaultDifficulty,
            streakData: getDefaultStreakAnalytics(),
            weeklyTrends: [],
            difficultySuccessRates: [:]
        )
    }
    
    private func getDefaultStreakAnalytics() -> StreakAnalytics {
        return StreakAnalytics(
            currentStreak: 0,
            longestStreak: 0,
            averageStreakLength: 0.0,
            streakBreakPatterns: [],
            bestStreakDay: AnalyticsConfiguration.TimeAnalytics.defaultMostActiveDay
        )
    }
}

// MARK: - RecommendationPriority Raw Values

extension RecommendationPriority {
    var rawValue: Int {
        switch self {
        case .high: return 3
        case .medium: return 2
        case .low: return 1
        }
    }
}
