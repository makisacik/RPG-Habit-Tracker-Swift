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
    @Published var activeQuestsCount: Int = 0
    @Published var completedQuestsCount: Int = 0
    @Published var achievementsCount: Int = 0
    @Published var recentActiveQuests: [Quest] = []
    @Published var recentAchievements: [AchievementDefinition] = []

    let userManager: UserManager
    let questDataService: QuestDataServiceProtocol
    private let achievementManager = AchievementManager.shared

    private var cancellables = Set<AnyCancellable>()

    init(userManager: UserManager, questDataService: QuestDataServiceProtocol) {
        self.userManager = userManager
        self.questDataService = questDataService
        observeUserUpdates()
        fetchUserData()
        fetchDashboardData()
    }

    func fetchUserData() {
        userManager.fetchUser { [weak self] user, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Failed to fetch user data: \(error)")
                } else {
                    self?.user = user
                }
            }
        }
    }

    func fetchDashboardData() {
        fetchQuestCounts()
        fetchRecentActiveQuests()
        fetchRecentAchievements()
    }

    private func fetchQuestCounts() {
        questDataService.fetchAllQuests { [weak self] quests, _ in
            DispatchQueue.main.async {
                    self?.activeQuestsCount = quests.filter { !$0.isCompleted }.count
                    self?.completedQuestsCount = quests.filter { $0.isCompleted }.count
            }
        }
    }

    private func fetchRecentActiveQuests() {
        questDataService.fetchAllQuests { [weak self] quests, _ in
            DispatchQueue.main.async {
                    self?.recentActiveQuests = Array(quests.filter { !$0.isCompleted }.prefix(5))
            }
        }
    }

    private func fetchRecentAchievements() {
        let unlockedAchievements = achievementManager.getUnlockedAchievements()
        self.achievementsCount = unlockedAchievements.count
        self.recentAchievements = Array(unlockedAchievements.suffix(3)) // Get the 3 most recent
    }

    private func observeUserUpdates() {
        NotificationCenter.default.publisher(for: .userDidUpdate)
            .sink { [weak self] _ in
                self?.fetchUserData()
            }
            .store(in: &cancellables)
    }
}
