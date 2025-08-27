//
//  RewardService.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import Foundation

class RewardService {
    static let shared = RewardService()
    
    private let rewardSystem = RewardSystem.shared
    private let toastManager = RewardToastManager.shared
    private let userManager: UserManager
    private let completionTracker = CompletionTracker.shared
    
    private init() {
        self.userManager = UserManager()
    }
    
    // MARK: - Quest Completion
    
    func handleQuestCompletion(quest: Quest, completion: @escaping (Error?) -> Void) {
        // Check for abuse - prevent rapid toggling
        guard completionTracker.canCompleteQuest(quest.id) else {
            print("⚠️ Quest completion blocked due to cooldown: \(quest.title)")
            completion(NSError(domain: "RewardService", code: 429, userInfo: [NSLocalizedDescriptionKey: "quest_completion_cooldown".localized]))
            return
        }

        // Record the completion to prevent abuse
        completionTracker.recordQuestCompletion(quest.id)
        
        // Calculate rewards
        let reward = rewardSystem.calculateQuestReward(quest: quest)
        
        // Award experience
        userManager.updateUserExperience(additionalExp: Int16(reward.totalExperience)) { [weak self] _, _, error in
            if let error = error {
                completion(error)
                return
            }
            
            // Award coins
            self?.userManager.updateUserCoins(additionalCoins: Int32(reward.totalCoins)) { coinError in
                if let coinError = coinError {
                    completion(coinError)
                    return
                }
                
                // Show toast notification
                DispatchQueue.main.async {
                    self?.toastManager.showQuestReward(quest: quest, reward: reward)
                }
                
                completion(nil)
            }
        }
    }
    
    // MARK: - Task Completion
    
    func handleTaskCompletion(task: QuestTask, quest: Quest, completion: @escaping (Error?) -> Void) {
        // Check for abuse - prevent rapid toggling
        guard completionTracker.canCompleteTask(task.id, questId: quest.id) else {
            print("⚠️ Task completion blocked due to cooldown: \(task.title)")
            completion(NSError(domain: "RewardService", code: 429, userInfo: [NSLocalizedDescriptionKey: "task_completion_cooldown".localized]))
            return
        }
        
        // Record the completion to prevent abuse
        completionTracker.recordTaskCompletion(task.id, questId: quest.id)
        
        // Calculate rewards
        let reward = rewardSystem.calculateTaskReward(task: task, quest: quest)
        
        // Award experience
        userManager.updateUserExperience(additionalExp: Int16(reward.totalExperience)) { [weak self] _, _, error in
            if let error = error {
                completion(error)
                return
            }
            
            // Award coins
            self?.userManager.updateUserCoins(additionalCoins: Int32(reward.totalCoins)) { coinError in
                if let coinError = coinError {
                    completion(coinError)
                    return
                }
                
                // Show toast notification
                DispatchQueue.main.async {
                    self?.toastManager.showTaskReward(task: task, quest: quest, reward: reward)
                }
                
                completion(nil)
            }
        }
    }
    
    // MARK: - Preview Methods (for testing)
    
    func showPreviewQuestReward() {
        let sampleQuest = Quest(
            title: "sample_quest_title".localized,
            isMainQuest: true,
            info: "sample_quest_description".localized,
            difficulty: 3,
            creationDate: Date(),
            dueDate: Date().addingTimeInterval(86400),
            isActive: true,
            progress: 0
        )
        
        let reward = rewardSystem.calculateQuestReward(quest: sampleQuest)
        toastManager.showQuestReward(quest: sampleQuest, reward: reward)
    }
    
    func showPreviewTaskReward() {
        let sampleQuest = Quest(
            title: "sample_quest_title".localized,
            isMainQuest: false,
                          info: "sample_quest_description".localized,
            difficulty: 2,
            creationDate: Date(),
            dueDate: Date().addingTimeInterval(86400),
            isActive: true,
            progress: 0
        )
        
        let sampleTask = QuestTask(
            id: UUID(),
            title: "sample_task_title".localized,
            isCompleted: true,
            order: 0
        )
        
        let reward = rewardSystem.calculateTaskReward(task: sampleTask, quest: sampleQuest)
        toastManager.showTaskReward(task: sampleTask, quest: sampleQuest, reward: reward)
    }
    
    // MARK: - Cleanup
    
    func cleanupOldRecords() {
        completionTracker.cleanupOldRecords()
    }
}
