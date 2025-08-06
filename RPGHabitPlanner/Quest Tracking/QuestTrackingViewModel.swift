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
        
        questDataService.updateQuestCompletion(forId: id, to: true) { [weak self] error in
            DispatchQueue.main.async {
                guard let self else { return }
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else {
                    #if DEBUG
                    self.userManager.updateUserExperience(additionalExp: Int16(50 * self.quests[index].difficulty)) { leveledUp, newLevel, expError in
                        if let expError = expError {
                            self.errorMessage = expError.localizedDescription
                        } else {
                            self.questCompleted = true
                            self.didLevelUp = leveledUp
                            self.newLevel = newLevel
                            
                            // Check for achievements after quest completion
                            self.checkAchievements()
                        }
                    }
                    #else
                    self.userManager.updateUserExperience(additionalExp: Int16(10 * self.quests[index].difficulty)) { leveledUp, newLevel, expError in
                        if let expError = expError {
                            self.errorMessage = expError.localizedDescription
                        } else {
                            self.questCompleted = true
                            self.didLevelUp = leveledUp
                            self.newLevel = newLevel
                            
                            // Check for achievements after quest completion
                            self.checkAchievements()
                        }
                    }
                    #endif
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
            repeatIntervalWeeks: quest.repeatIntervalWeeks,
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
        quest.progress = max(0, min(100, quest.progress + change))
        quests[index] = quest

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
            repeatIntervalWeeks: quest.repeatIntervalWeeks,
            tasks: quest.tasks.map { $0.title }
        ) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
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
    
    func toggleTaskCompletion(questId: UUID, taskId: UUID, currentValue: Bool) {
        questDataService.updateTask(
            withId: taskId,
            isCompleted: !currentValue
        ) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    if let questIndex = self?.quests.firstIndex(where: { $0.id == questId }),
                       let taskIndex = self?.quests[questIndex].tasks.firstIndex(where: { $0.id == taskId }) {
                        self?.quests[questIndex].tasks[taskIndex].isCompleted.toggle()
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
