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
    @Published var selectedTab: QuestTab = .all
    @Published var didLevelUp: Bool = false
    @Published var questCompleted: Bool = false
    @Published var newLevel: Int16?
    @Published var lastRefreshDay: Date = Calendar.current.startOfDay(for: Date())

    let questDataService: QuestDataServiceProtocol
    private let userManager: UserManager
    
    init(questDataService: QuestDataServiceProtocol, userManager: UserManager) {
        self.questDataService = questDataService
        self.userManager = userManager
    }
    
    func fetchQuests() {
        questDataService.fetchNonCompletedQuests { [weak self] quests, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.quests = quests.reversed()
                }
            }
        }
    }

    func markQuestAsCompleted(id: UUID) {
        guard let index = quests.firstIndex(where: { $0.id == id }) else { return }
        withAnimation {
            quests[index].isCompleted = true
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
    
    var allQuests: [Quest] {
        quests
    }

    var mainQuests: [Quest] {
        quests.filter { $0.isMainQuest }
    }
    
    var sideQuests: [Quest] {
        quests.filter { !$0.isMainQuest }
    }
    
    func toggleTaskCompletion(questId: UUID, taskId: UUID, newValue: Bool) {
        print("🔄 Updating task completion - Quest ID: \(questId), Task ID: \(taskId), New Value: \(newValue)")

        questDataService.updateTask(
            withId: taskId,
            isCompleted: newValue
        ) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error updating task: \(error)")
                    self?.errorMessage = error.localizedDescription
                } else {
                    print("✅ Task update successful, updating local array")
                    if let questIndex = self?.quests.firstIndex(where: { $0.id == questId }),
                       let taskIndex = self?.quests[questIndex].tasks.firstIndex(where: { $0.id == taskId }) {
                        self?.quests[questIndex].tasks[taskIndex].isCompleted = newValue
                        print("✅ Local array updated - Task is now: \(self?.quests[questIndex].tasks[taskIndex].isCompleted ?? false)")
                    } else {
                        print("❌ Could not find quest or task in local array")
                    }
                }
            }
        }
    }
    
    private func checkAchievements() {
        AchievementManager.shared.checkAchievements(
            questDataService: questDataService,
            userManager: userManager
        ) { newlyUnlocked in
            if !newlyUnlocked.isEmpty {
                print("🎉 New achievements unlocked: \(newlyUnlocked.map { $0.title })")
                // You can add notification or celebration logic here
            }
        }
    }
}
