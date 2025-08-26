//
//  AnalyticsManager.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 27.07.2025.
//

import Foundation
import CoreData
import Combine

final class AnalyticsManager: ObservableObject {
    static let shared = AnalyticsManager()
    
    @Published var analyticsSummary: AnalyticsSummary?
    @Published var isLoading = false
    @Published var lastUpdated = Date()
    
    private let questDataService: QuestDataServiceProtocol
    private let userManager: UserManager
    let achievementManager: AchievementManager // Made accessible to extensions
    let streakManager: StreakManager // Made accessible to extensions
    private let customizationService: CharacterCustomizationService
    
    private var cancellables = Set<AnyCancellable>()
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
        isLoading = true
        
        Task {
            let summary = await calculateAnalyticsSummary()
            
            DispatchQueue.main.async { [weak self] in
                self?.analyticsSummary = summary
                self?.lastUpdated = Date()
                self?.isLoading = false
                completion(summary)
            }
        }
    }
    
    func getRecommendations() -> [PersonalizedRecommendation] {
        guard let summary = analyticsSummary else { return [] }
        
        var recommendations: [PersonalizedRecommendation] = []
        
        // Quest creation recommendations
        if summary.questPerformance.totalQuests < 5 {
            recommendations.append(
                PersonalizedRecommendation(
                    type: .questCreation,
                    title: String(localized: "analytics_recommendation_create_more_quests_title"),
                    description: String(localized: "analytics_recommendation_create_more_quests_description"),
                    priority: .high,
                    actionable: true,
                    actionTitle: String(localized: "create_quest"),
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
        // Listen for quest changes
        NotificationCenter.default.publisher(for: .questCreated)
            .sink { [weak self] _ in
                self?.refreshAnalytics()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .questUpdated)
            .sink { [weak self] _ in
                self?.refreshAnalytics()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .questDeleted)
            .sink { [weak self] _ in
                self?.refreshAnalytics()
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
                        mostProductiveHour: 12,
                        preferredDifficulty: 2,
                        streakData: self?.getDefaultStreakAnalytics() ?? StreakAnalytics(
                            currentStreak: 0,
                            longestStreak: 0,
                            averageStreakLength: 0.0,
                            streakBreakPatterns: [],
                            bestStreakDay: 1
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
                        currentLevel: 1,
                        experienceProgress: 0.0,
                        experienceToNextLevel: 100,
                        totalExperience: 0,
                        levelUpRate: 0.0,
                        currencyEarned: CurrencyAnalytics(
                            totalCoinsEarned: 0,
                            totalGemsEarned: 0,
                            averageCoinsPerQuest: 0.0,
                            averageGemsPerQuest: 0.0,
                            earningRate: 0.0
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
                let experienceToNextLevel = self?.calculateExperienceToNextLevel(currentLevel: currentLevel) ?? 100
                let totalExperience = Int(user.exp)
                let levelUpRate = self?.calculateLevelUpRate(user: user) ?? 0.0
                
                let currencyEarned = self?.calculateCurrencyAnalytics(user: user) ?? CurrencyAnalytics(
                    totalCoinsEarned: Int(user.coins),
                    totalGemsEarned: Int(user.gems),
                    averageCoinsPerQuest: 0.0,
                    averageGemsPerQuest: 0.0,
                    earningRate: 0.0
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
                
                // For now, return basic customization data
                // This can be enhanced when customization tracking is implemented
                let customization = CustomizationAnalytics(
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
        // For now, return basic engagement data
        // This can be enhanced when session tracking is implemented
        return EngagementAnalytics(
            sessionFrequency: 5.0, // Default: 5 sessions per week
            averageSessionDuration: 300, // Default: 5 minutes
            mostActiveDay: calendar.component(.weekday, from: Date()),
            mostActiveHour: 12,
            featureUsage: [:],
            appOpenFrequency: 7.0 // Default: daily
        )
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
            mostProductiveHour: 12,
            preferredDifficulty: 2,
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
            bestStreakDay: 1
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
