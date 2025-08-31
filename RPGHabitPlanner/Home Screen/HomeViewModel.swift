//
//  HomeViewModel.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 11.11.2024.
//

import SwiftUI
import CoreData
import Combine

class HomeViewModel: ObservableObject {
    @Published var user: UserEntity?
    @Published var characterCustomization: CharacterCustomization?
    @Published var activeQuestsCount: Int = 0
    @Published var completedQuestsCount: Int = 0
    @Published var achievementsCount: Int = 0
    @Published var recentActiveQuests: [Quest] = []
    @Published var recentAchievements: [AchievementDefinition] = []

    // MARK: - Damage Tracking Properties
    @Published var showDamageSummary = false
    @Published var damageSummaryData: DamageSummaryData?
    @Published var isCheckingDamage = false
    
    // Damage protection properties
    private var lastDamageCheckDate: Date?
    private let damageCheckCooldown: TimeInterval = 86400 // 24 hours cooldown (once per day)
    private let maxDamagePerSession: Int = QuestDamageConstants.maxDamagePerSession // Maximum damage per session

    let userManager: UserManager
    let questDataService: QuestDataServiceProtocol
    private let achievementManager = AchievementManager.shared
    private let customizationService = CharacterCustomizationService()
    let streakManager = StreakManager.shared

    private var cancellables = Set<AnyCancellable>()

    init(userManager: UserManager, questDataService: QuestDataServiceProtocol) {
        self.userManager = userManager
        self.questDataService = questDataService
        observeUserUpdates()
        setupQuestNotificationObservers()
        fetchUserData()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupQuestNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleQuestUpdated),
            name: .questUpdated,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleQuestDeleted),
            name: .questDeleted,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleQuestCreated),
            name: .questCreated,
            object: nil
        )
    }

    @objc private func handleQuestUpdated(_ notification: Notification) {
        print("🔄 HomeViewModel: Received quest updated notification")
        DispatchQueue.main.async { [weak self] in
            self?.fetchDashboardData()
            self?.fetchUserData() // 👈 Also refresh user data to update exp bars
        }
    }

    @objc private func handleQuestDeleted(_ notification: Notification) {
        print("🗑️ HomeViewModel: Received quest deleted notification")
        DispatchQueue.main.async { [weak self] in
            self?.fetchDashboardData()
        }
    }

    @objc private func handleQuestCreated(_ notification: Notification) {
        print("➕ HomeViewModel: Received quest created notification")
        DispatchQueue.main.async { [weak self] in
            self?.fetchDashboardData()
        }
    }

    func fetchUserData() {
        print("🔄 HomeViewModel: Starting fetchUserData()")
        userManager.fetchUser { [weak self] user, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ HomeViewModel: Failed to fetch user data: \(error)")
                } else {
                    print("✅ HomeViewModel: Successfully fetched user data")
                    if let user = user {
                        print("   User Level: \(user.level), User XP: \(user.exp)")
                    }
                    self?.user = user

                    // Fetch character customization if user exists
                    if let user = user {
                        self?.fetchCharacterCustomization(for: user)
                    }
                    
                    // Refresh currency display
                    CurrencyManager.shared.refreshCurrency()
                }
            }
        }
    }

    private func fetchCharacterCustomization(for user: UserEntity) {
        print("🏠 HomeViewModel: Starting fetchCharacterCustomization for user: \(user.nickname ?? "Unknown")")
        
        if let customizationEntity = customizationService.fetchCustomization(for: user) {
            print("✅ HomeViewModel: Found existing character customization in Core Data")
            self.characterCustomization = customizationEntity.toCharacterCustomization()
            print("🔧 HomeViewModel: Loaded customization with outfit: \(characterCustomization?.outfit?.rawValue ?? "nil")")
        } else {
            print("⚠️ HomeViewModel: No character customization found in Core Data, attempting migration")
            // Try to migrate from UserDefaults if no Core Data customization exists
            let customizationManager = CharacterCustomizationManager()
            if let migratedEntity = customizationService.migrateFromUserDefaults(for: user, manager: customizationManager) {
                self.characterCustomization = migratedEntity.toCharacterCustomization()
                print("✅ HomeViewModel: Successfully migrated character customization from UserDefaults to Core Data")
                print("🔧 HomeViewModel: Migrated customization with outfit: \(characterCustomization?.outfit?.rawValue ?? "nil")")
            } else {
                print("⚠️ HomeViewModel: No UserDefaults data found, creating default customization")
                // Create default customization if none exists
                let defaultCustomization = CharacterCustomization()
                self.characterCustomization = defaultCustomization

                // Save the default customization
                if let _ = customizationService.createCustomization(for: user, customization: defaultCustomization) {
                    print("✅ HomeViewModel: Created default character customization")
                } else {
                    print("❌ HomeViewModel: Failed to create default character customization")
                }
            }
        }
    }

    /// Refreshes character customization data for the current user
    func refreshCharacterCustomization() {
        guard let user = user else {
            print("⚠️ HomeViewModel: No user available for character customization refresh")
            return
        }

        fetchCharacterCustomization(for: user)
    }

    func fetchDashboardData() {
        print("🏠 HomeViewModel: Starting fetchDashboardData()")

        // First refresh all quest states to ensure they're up to date
        questDataService.refreshAllQuests(on: Date()) { [weak self] error in
            if let error = error {
                print("❌ HomeViewModel: Error refreshing quests: \(error)")
            } else {
                print("✅ HomeViewModel: Successfully refreshed all quest states")
            }

            // Then fetch the updated quest data
            self?.questDataService.fetchAllQuests { [weak self] quests, fetchError in
                DispatchQueue.main.async {
                    guard let self = self else { return }

                    if let fetchError = fetchError {
                        print("❌ HomeViewModel: Error fetching quests: \(fetchError)")
                    } else {
                        print("✅ HomeViewModel: Successfully fetched \(quests.count) quests")
                    }

                    print("🏠 HomeViewModel: Received \(quests.count) quests from fetchAllQuests")

                    // Update quest counts
                    let activeQuests = quests.filter { quest in
                        let isActive = quest.isActive(on: Date())
                        print("🔍 Quest '\(quest.title)': isActive(on: Date()) = \(isActive), isCompleted = \(quest.isCompleted), isFinished = \(quest.isFinished), repeatType = \(quest.repeatType)")
                        return isActive
                    }
                    self.activeQuestsCount = activeQuests.count
                    self.completedQuestsCount = quests.filter { quest in
                        quest.isFinished
                    }.count

                    // Update recent active quests
                    self.recentActiveQuests = Array(activeQuests.prefix(5))

                    print("🏠 HomeViewModel: Updated counts - Active: \(self.activeQuestsCount), Completed: \(self.completedQuestsCount), Recent: \(self.recentActiveQuests.count)")
                }
            }
        }

        fetchRecentAchievements()
    }

    private func fetchRecentAchievements() {
        let unlockedAchievements = achievementManager.getUnlockedAchievements()
        self.achievementsCount = unlockedAchievements.count
        self.recentAchievements = Array(unlockedAchievements.suffix(3))
    }

    private func observeUserUpdates() {
        NotificationCenter.default.publisher(for: .userDidUpdate)
            .sink { [weak self] _ in
                print("📢 HomeViewModel: Received userDidUpdate notification")
                self?.fetchUserData()
            }
            .store(in: &cancellables)

        // Observe streak updates
        NotificationCenter.default.publisher(for: .streakUpdated)
            .sink { [weak self] _ in
                // Streak data is automatically updated via @Published properties
                // No additional action needed here
            }
            .store(in: &cancellables)
    }

    // MARK: - Damage Tracking Methods

    /// Check for damage on app launch and show summary if damage was taken
    func checkForDamageOnAppLaunch() {
        guard !isCheckingDamage else { return }
        
        // Check cooldown to prevent excessive damage
        if let lastCheck = lastDamageCheckDate {
            let calendar = Calendar.current
            let isSameDay = calendar.isDate(lastCheck, inSameDayAs: Date())
            
            if isSameDay {
                print("⏰ HomeViewModel: Damage already checked today, skipping...")
                return
            }
            
            // Also check 24-hour cooldown as backup
            if Date().timeIntervalSince(lastCheck) < damageCheckCooldown {
                print("⏰ HomeViewModel: Damage check on cooldown, skipping...")
                return
            }
        }

        isCheckingDamage = true
        print("🔄 HomeViewModel: Checking for damage on app launch...")

        let damageTrackingManager = QuestDamageTrackingManager.shared

        damageTrackingManager.calculateAndApplyQuestDamageDetailed { [weak self] totalDamage, detailedDamage, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isCheckingDamage = false
                
                // Update last check date
                self.lastDamageCheckDate = Date()

                if let error = error {
                    print("❌ HomeViewModel: Error calculating damage: \(error)")
                    return
                }

                // Apply damage cap to prevent excessive damage
                let cappedDamage = min(totalDamage, self.maxDamagePerSession)
                
                if cappedDamage > 0 {
                    print("⚠️ HomeViewModel: Applied \(cappedDamage) damage for missed quests (capped from \(totalDamage))")

                    // Create damage summary data with detailed breakdown
                    let summaryData = DamageSummaryData(
                        totalDamage: cappedDamage,
                        damageDate: Date(),
                        questsAffected: detailedDamage.count,
                        message: cappedDamage < totalDamage ?
                            "You took \(cappedDamage) damage (capped from \(totalDamage)) from missed quests!" :
                            "You took \(cappedDamage) damage from missed quests!",
                        detailedDamage: detailedDamage
                    )

                    self.damageSummaryData = summaryData
                    self.showDamageSummary = true
                } else {
                    print("✅ HomeViewModel: No damage calculated - all quests are up to date")
                }
            }
        }
    }

    /// Manually check for damage (for testing purposes)
    func manuallyCheckDamage() {
        guard !isCheckingDamage else { return }

        isCheckingDamage = true
        print("🔄 HomeViewModel: Manually checking for damage...")

        let damageTrackingManager = QuestDamageTrackingManager.shared

        damageTrackingManager.calculateAndApplyQuestDamageDetailed { [weak self] totalDamage, detailedDamage, error in
            DispatchQueue.main.async {
                self?.isCheckingDamage = false

                if let error = error {
                    print("❌ Error checking damage: \(error)")
                    return
                }

                if totalDamage > 0 {
                    print("💥 Damage taken: \(totalDamage)")

                    // Create damage summary data
                    let damageData = DamageSummaryData(
                        totalDamage: totalDamage,
                        damageDate: Date(),
                        questsAffected: detailedDamage.count,
                        message: "You took \(totalDamage) damage from missed quests!",
                        detailedDamage: detailedDamage
                    )

                    self?.damageSummaryData = damageData
                    self?.showDamageSummary = true
                } else {
                    print("✅ No damage taken - all quests are up to date!")

                    // Show a success message for testing
                    let damageData = DamageSummaryData(
                        totalDamage: 0,
                        damageDate: Date(),
                        questsAffected: 0,
                        message: "Great job! All your quests are completed on time.",
                        detailedDamage: []
                    )

                    self?.damageSummaryData = damageData
                    self?.showDamageSummary = true
                }
            }
        }
    }

    /// Create a test quest for damage demonstration
    func createTestQuestForDamage() {
        let calendar = Calendar.current
        let testDueDate = calendar.date(byAdding: .day, value: -3, to: Date())! // 3 days ago

        let testQuest = Quest(
            id: UUID(),
            title: "Test Daily Quest",
            isMainQuest: false,
            info: "This is a test quest to demonstrate damage calculation",
            difficulty: 1,
            creationDate: Date(),
            dueDate: testDueDate,
            isActive: true,
            progress: 0,
            isCompleted: false,
            completionDate: nil,
            isFinished: false,
            isFinishedDate: nil,
            tasks: [],
            repeatType: .daily,
            completions: [], // No completions
            tags: [],
            showProgress: false,
            scheduledDays: []
        )

        // Save the test quest
        questDataService.saveQuest(testQuest, withTasks: []) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Failed to create test quest: \(error)")
                } else {
                    print("✅ Test quest created successfully")
                    // Now check for damage
                    self?.manuallyCheckDamage()
                }
            }
        }
    }

    /// Get the count of quests that would be affected by damage calculation
    private func getAffectedQuestsCount() -> Int {
        // This is a simplified implementation
        // In a real scenario, you'd query the damage tracking service
        return activeQuestsCount
    }

    /// Dismiss the damage summary
    func dismissDamageSummary() {
        showDamageSummary = false
        damageSummaryData = nil
    }
}
