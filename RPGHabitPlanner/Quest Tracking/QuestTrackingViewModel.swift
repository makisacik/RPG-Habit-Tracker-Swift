//
//  QuestTrackingViewModel.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import SwiftUI
import Combine

final class QuestTrackingViewModel: ObservableObject {
    @Published var quests: [Quest] = []
    @Published var errorMessage: String?
    @Published var didLevelUp: Bool = false
    @Published var questCompleted: Bool = false
    @Published var newLevel: Int16?
    @Published var lastRefreshDay: Date = Calendar.current.startOfDay(for: Date())
    @Published var selectedDayFilter: DayFilter = .active

    let questDataService: QuestDataServiceProtocol
    private let userManager: UserManager
    private let calendar = Calendar.current
    
    init(questDataService: QuestDataServiceProtocol, userManager: UserManager) {
        self.questDataService = questDataService
        self.userManager = userManager
    }
    
    func fetchQuests() {
        questDataService.fetchAllQuests { [weak self] quests, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.quests = quests
                }
            }
        }
    }
    
    func refreshRecurringQuests() {
        questDataService.refreshAllQuests(on: Date()) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.fetchQuests()
                }
            }
        }
    }

    func markQuestAsCompleted(id: UUID) {
        guard let index = quests.firstIndex(where: { $0.id == id }) else { return }
        withAnimation {
            quests[index].isCompleted = true
            quests[index].isActive = false
        }
        
        questDataService.markQuestCompleted(forId: id, on: Date()) { [weak self] error in
            DispatchQueue.main.async {
                guard let self else { return }
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else {
                    let expAmount: Int16
                    #if DEBUG
                    expAmount = Int16(50 * self.quests[index].difficulty)
                    #else
                    expAmount = Int16(10 * self.quests[index].difficulty)
                    #endif
                    self.userManager.updateUserExperience(additionalExp: expAmount) { leveledUp, newLevel, expError in
                        if let expError = expError {
                            self.errorMessage = expError.localizedDescription
                        } else {
                            self.questCompleted = true
                            self.didLevelUp = leveledUp
                            self.newLevel = newLevel
                            self.checkAchievements()
                        }
                    }
                }
            }
        }
    }

    func updateQuest(_ quest: Quest) {
        questDataService.updateQuest(
            withId: quest.id,
            title: quest.title,
            isMainQuest: quest.isMainQuest,
            info: quest.info,
            difficulty: quest.difficulty,
            dueDate: quest.dueDate,
            isActive: quest.isActive,
            progress: quest.progress,
            repeatType: quest.repeatType,
            tasks: quest.tasks.map { $0.title }
        ) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.fetchQuests()
                }
            }
        }
    }

    func updateQuestProgress(id: UUID, by change: Int) {
        guard let index = quests.firstIndex(where: { $0.id == id }) else { return }
        var quest = quests[index]
        let newProgress = max(0, min(100, quest.progress + change))
        quest.progress = newProgress
        quests[index] = quest

        questDataService.updateQuestProgress(withId: quest.id, progress: newProgress) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    var activeTodayQuests: [Quest] {
        let now = Date()
        return quests.filter { $0.isActive(on: now) }
    }

    var inactiveTodayQuests: [Quest] {
        let now = Date()
        return quests.filter { !$0.isActive(on: now) }
    }
    
    func toggleTaskCompletion(questId: UUID, taskId: UUID, newValue: Bool) {
        questDataService.updateTask(
            withId: taskId,
            isCompleted: newValue
        ) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    if let questIndex = self?.quests.firstIndex(where: { $0.id == questId }),
                       let taskIndex = self?.quests[questIndex].tasks.firstIndex(where: { $0.id == taskId }) {
                        self?.quests[questIndex].tasks[taskIndex].isCompleted = newValue
                    }
                }
            }
        }
    }
    
    private func checkAchievements() {
        AchievementManager.shared.checkAchievements(
            questDataService: questDataService,
            userManager: userManager
        ) { _ in }
    }
}
