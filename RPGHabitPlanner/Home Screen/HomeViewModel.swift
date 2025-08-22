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
        userManager.fetchUser { [weak self] user, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Failed to fetch user data: \(error)")
                } else {
                    self?.user = user

                    // Fetch character customization if user exists
                    if let user = user {
                        self?.fetchCharacterCustomization(for: user)
                    }
                }
            }
        }
    }

    private func fetchCharacterCustomization(for user: UserEntity) {
        if let customizationEntity = customizationService.fetchCustomization(for: user) {
            self.characterCustomization = customizationEntity.toCharacterCustomization()
        } else {
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
}
