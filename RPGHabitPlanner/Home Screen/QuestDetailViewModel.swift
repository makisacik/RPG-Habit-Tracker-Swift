//
//  QuestDetailViewModel.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 11.11.2024.
//

import SwiftUI
import Foundation

// MARK: - Quest Update Notifications
extension Notification.Name {
    static let questUpdated = Notification.Name("questUpdated")
    static let questDeleted = Notification.Name("questDeleted")
    static let questCreated = Notification.Name("questCreated")
    static let questCompletedFromDetail = Notification.Name("questCompletedFromDetail")
}

final class QuestDetailViewModel: ObservableObject {
    @Published var quest: Quest
    @Published var isLoading = false
    @Published var alertMessage: String?

    let questDataService: QuestDataServiceProtocol
    let date: Date
    private let calendar = Calendar.current
    private let streakManager = StreakManager.shared

    init(quest: Quest, date: Date, questDataService: QuestDataServiceProtocol) {
        self.quest = quest
        self.date = date
        self.questDataService = questDataService
    }

    // MARK: - Quest Management

    func refreshQuest() {
        isLoading = true
        questDataService.fetchAllQuests { [weak self] quests, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let updatedQuest = quests.first(where: { $0.id == self?.quest.id }) {
                    self?.quest = updatedQuest
                    // Notify other views that quest was updated
                    NotificationCenter.default.post(name: .questUpdated, object: updatedQuest)
                }
            }
        }
    }

    func updateQuestTags(_ newTags: [Tag]) {
        print("🏷️ QuestDetailViewModel: Updating quest tags to \(newTags.count) tags")

        // Optimistically update the local quest
        quest.tags = Set(newTags)

        // Update the server
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
            tasks: quest.tasks.map { $0.title },
            tags: newTags,
            showProgress: quest.showProgress,
            scheduledDays: quest.scheduledDays
        ) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ QuestDetailViewModel: Error updating quest tags: \(error)")
                    self?.alertMessage = "Failed to update quest tags: \(error.localizedDescription)"
                    // Revert the optimistic update on error
                    self?.refreshQuest()
                } else {
                    print("✅ QuestDetailViewModel: Successfully updated quest tags on server")
                    // Notify other views that quest was updated
                    NotificationCenter.default.post(name: .questUpdated, object: self?.quest)
                }
            }
        }
    }

    func toggleQuestCompletion() {
        let today = calendar.startOfDay(for: Date())
        let isCompleted = quest.isCompleted(on: date)

        switch quest.repeatType {
        case .daily:
            guard calendar.isDate(date, inSameDayAs: today) else {
                alertMessage = "Daily quests can only be toggled for today."
                return
            }
            let dayAnchor = calendar.startOfDay(for: date)
            if isCompleted {
                questDataService.unmarkQuestCompleted(forId: quest.id, on: dayAnchor) { [weak self] _ in
                    self?.refreshQuest()
                }
            } else {
                questDataService.markQuestCompleted(forId: quest.id, on: dayAnchor) { [weak self] _ in
                    // Record streak activity when completing a quest
                    self?.streakManager.recordActivity()
                    self?.refreshQuest()
                }
            }
        case .weekly:
            guard isSameWeek(date, today) else {
                alertMessage = "Weekly quests can only be toggled in the current week."
                return
            }
            let anchor = weekAnchor(for: date)
            if isCompleted {
                questDataService.unmarkQuestCompleted(forId: quest.id, on: anchor) { [weak self] _ in
                    self?.refreshQuest()
                }
            } else {
                questDataService.markQuestCompleted(forId: quest.id, on: anchor) { [weak self] _ in
                    // Record streak activity when completing a quest
                    self?.streakManager.recordActivity()
                    self?.refreshQuest()
                }
            }
        case .oneTime:
            guard date >= calendar.startOfDay(for: quest.creationDate) &&
                  date <= calendar.startOfDay(for: quest.dueDate) else {
                alertMessage = "This quest can only be completed between creation and due date."
                return
            }
            // For one-time quests, always store completion at the due date
            let dueDateAnchor = calendar.startOfDay(for: quest.dueDate)
            if isCompleted {
                questDataService.unmarkQuestCompleted(forId: quest.id, on: dueDateAnchor) { [weak self] _ in
                    self?.refreshQuest()
                }
            } else {
                questDataService.markQuestCompleted(forId: quest.id, on: dueDateAnchor) { [weak self] _ in
                    // Record streak activity when completing a quest
                    self?.streakManager.recordActivity()
                    self?.refreshQuest()
                }
            }
        case .scheduled:
            // For scheduled quests, check if it's a scheduled day
            let weekday = calendar.component(.weekday, from: date)
            let isScheduledDay = quest.scheduledDays.contains(weekday)
            guard isScheduledDay else {
                alertMessage = "This quest can only be completed on scheduled days."
                return
            }
            let dayAnchor = calendar.startOfDay(for: date)
            if isCompleted {
                questDataService.unmarkQuestCompleted(forId: quest.id, on: dayAnchor) { [weak self] _ in
                    self?.refreshQuest()
                }
            } else {
                questDataService.markQuestCompleted(forId: quest.id, on: dayAnchor) { [weak self] _ in
                    // Record streak activity when completing a quest
                    self?.streakManager.recordActivity()
                    self?.refreshQuest()
                }
            }
        }
    }

    func markQuestAsFinished() {
        print("🔄 QuestDetailViewModel: Marking quest \(quest.id) as finished")

        // Optimistically update the local quest
        quest.isFinished = true
        quest.isFinishedDate = Date()

        // Update the server
        questDataService.markQuestAsFinished(forId: quest.id) { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let error = error {
                    print("❌ QuestDetailViewModel: Error marking quest as finished: \(error)")
                    // Revert the optimistic update on error
                    self.refreshQuest()
                } else {
                    print("✅ QuestDetailViewModel: Successfully marked quest as finished on server")

                    // Calculate and award rewards (same logic as QuestTrackingViewModel)
                    let baseExp: Int
                    let baseCoins: Int

                    #if DEBUG
                    baseExp = 50 * self.quest.difficulty
                    #else
                    baseExp = 10 * self.quest.difficulty
                    #endif

                    // Calculate coin reward using CurrencyManager
                    baseCoins = CurrencyManager.shared.calculateQuestReward(
                        difficulty: self.quest.difficulty,
                        isMainQuest: self.quest.isMainQuest,
                        taskCount: self.quest.tasks.count
                    )

                    // Apply boosters
                    let boosterManager = BoosterManager.shared
                    let boostedRewards = boosterManager.calculateBoostedRewards(
                        baseExperience: baseExp,
                        baseCoins: baseCoins
                    )

                    // Award boosted experience
                    let userManager = UserManager(container: PersistenceController.shared.container)
                    userManager.updateUserExperience(additionalExp: Int16(boostedRewards.experience)) { leveledUp, newLevel, expError in
                        if let expError = expError {
                            print("❌ Error updating experience: \(expError)")
                        } else {
                            // Award boosted coins
                            CurrencyManager.shared.addCoins(boostedRewards.coins) { coinError in
                                if let coinError = coinError {
                                    print("❌ Error adding coins: \(coinError)")
                                }
                            }

                            // Record streak activity when finishing a quest
                            self.streakManager.recordActivity()

                            // Check achievements
                            AchievementManager.shared.checkAchievements(
                                questDataService: self.questDataService,
                                userManager: userManager
                            ) { _ in }

                            // Post notification with quest completion data for QuestTrackingView
                            let userInfo: [String: Any] = [
                                "questId": self.quest.id,
                                "leveledUp": leveledUp,
                                "newLevel": newLevel ?? 0
                            ]
                            NotificationCenter.default.post(
                                name: .questCompletedFromDetail,
                                object: self.quest,
                                userInfo: userInfo
                            )
                        }
                    }

                    // Notify other views that quest was updated
                    NotificationCenter.default.post(name: .questUpdated, object: self.quest)
                }
            }
        }
    }

    func toggleTaskCompletion(taskId: UUID, newValue: Bool) {
        print("🔄 QuestDetailViewModel: Toggling task \(taskId) completion to \(newValue)")

        // Optimistically update the local quest
        if let taskIndex = quest.tasks.firstIndex(where: { $0.id == taskId }) {
            quest.tasks[taskIndex].isCompleted = newValue
        }

        // Update the server
        questDataService.updateTask(withId: taskId, isCompleted: newValue) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ QuestDetailViewModel: Error updating task completion: \(error)")
                    // Revert the optimistic update on error
                    self?.refreshQuest()
                } else {
                    print("✅ QuestDetailViewModel: Successfully updated task completion on server")
                    // Notify other views that quest was updated
                    NotificationCenter.default.post(name: .questUpdated, object: self?.quest)
                }
            }
        }
    }

    func deleteQuest() {
        questDataService.deleteQuest(withId: quest.id) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ QuestDetailViewModel: Error deleting quest: \(error)")
                    self?.alertMessage = "Failed to delete quest: \(error.localizedDescription)"
                } else {
                    print("✅ QuestDetailViewModel: Successfully deleted quest")
                    // Notify other views that quest was deleted
                    NotificationCenter.default.post(name: .questDeleted, object: self?.quest)
                }
            }
        }
    }

    // MARK: - Helper Methods

    private func isSameWeek(_ a: Date, _ b: Date) -> Bool {
        calendar.isDate(a, equalTo: b, toGranularity: .weekOfYear)
    }

    private func weekAnchor(for day: Date) -> Date {
        let comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: day)
        let start = calendar.date(from: comps) ?? day
        return calendar.startOfDay(for: start)
    }

    // MARK: - Computed Properties

    var isCompleted: Bool {
        quest.isCompleted(on: date)
    }
}
