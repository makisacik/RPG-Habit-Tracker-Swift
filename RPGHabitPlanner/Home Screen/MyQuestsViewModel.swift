//
//  MyQuestsViewModel.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 18.08.2025.
//

import SwiftUI
import Foundation

final class MyQuestsViewModel: ObservableObject {
    @Published var allQuests: [Quest] = []
    @Published var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    @Published var isLoading = false
    @Published var hasInitialData = false  // Track if we've loaded data at least once
    @Published var alertMessage: String?
    @Published var questCompleted: Bool = false
    @Published var didLevelUp: Bool = false
    @Published var newLevel: Int16?
    @Published var lastCompletedQuestId: UUID?
    @Published var lastCompletedQuest: Quest?
    @Published var showFinishConfirmation: Bool = false
    @Published var questToFinish: Quest?
    @Published var showCompletionIsFinishedCheck: Bool = false
    @Published var questToCheckCompletion: Quest?

    let questDataService: QuestDataServiceProtocol
    private let userManager: UserManager
    private let calendar = Calendar.current
    private let streakManager = StreakManager.shared
    private let boosterManager = BoosterManager.shared
    private let rewardService = RewardService.shared

    init(questDataService: QuestDataServiceProtocol, userManager: UserManager) {
        self.questDataService = questDataService
        self.userManager = userManager
        fetchQuests()
        setupNotificationObservers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupNotificationObservers() {
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

        // Support "complete from detail" flow (NEW)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleQuestCompletedFromDetail),
            name: .questCompletedFromDetail,
            object: nil
        )
    }

    @objc private func handleQuestUpdated(_ notification: Notification) {
        print("🔄 MyQuestsViewModel: Received quest updated notification")
        DispatchQueue.main.async { [weak self] in
            self?.fetchQuests()
        }
    }

    @objc private func handleQuestDeleted(_ notification: Notification) {
        print("🗑️ MyQuestsViewModel: Received quest deleted notification")
        DispatchQueue.main.async { [weak self] in
            self?.fetchQuests()
        }
    }

    @objc private func handleQuestCreated(_ notification: Notification) {
        print("➕ MyQuestsViewModel: Received quest created notification")
        DispatchQueue.main.async { [weak self] in
            self?.fetchQuests()
        }
    }

    // NEW: mirror QuestsViewModel behavior for "complete from detail"
    @objc private func handleQuestCompletedFromDetail(_ notification: Notification) {
        print("🎯 MyQuestsViewModel: Received quest completed from detail notification")
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let quest = notification.object as? Quest,
                  let userInfo = notification.userInfo,
                  let questId = userInfo["questId"] as? UUID,
                  let leveledUp = userInfo["leveledUp"] as? Bool,
                  let newLevel = userInfo["newLevel"] as? Int16 else {
                return
            }

            self.lastCompletedQuestId = questId
            self.lastCompletedQuest = quest
            self.questCompleted = true
            self.didLevelUp = leveledUp
            self.newLevel = newLevel

            self.fetchQuests()
        }
    }

    var itemsForSelectedDate: [DayQuestItem] {
        return items(for: selectedDate)
    }

    func fetchQuests() {
        print("📅 MyQuestsViewModel: Starting fetchQuests()")
        isLoading = true
        questDataService.refreshAllQuests(on: Date()) { [weak self] _ in
            self?.questDataService.fetchAllQuests { [weak self] quests, _ in
                DispatchQueue.main.async {
                    print("📅 MyQuestsViewModel: Received \(quests.count) quests from fetchAllQuests")
                    self?.isLoading = false
                    self?.allQuests = quests
                    self?.hasInitialData = true  // Mark that we've loaded data at least once
                }
            }
        }
    }

    // New method to refresh quest data without showing loading state
    func refreshQuestData() {
        questDataService.refreshAllQuests(on: Date()) { [weak self] _ in
            self?.questDataService.fetchAllQuests { [weak self] quests, _ in
                DispatchQueue.main.async {
                    print("📅 MyQuestsViewModel: Refreshed quest data with \(quests.count) quests")
                    self?.allQuests = quests
                    self?.hasInitialData = true  // Mark that we've loaded data at least once
                    // Send notification to other views
                    NotificationCenter.default.post(name: .questUpdated, object: nil)
                }
            }
        }
    }

    func items(for date: Date) -> [DayQuestItem] {
        let day = calendar.startOfDay(for: date)

        let items: [DayQuestItem] = allQuests.compactMap { quest in
            guard !quest.isFinished else { return nil }

            let creationDate = calendar.startOfDay(for: quest.creationDate)
            let dueDate = calendar.startOfDay(for: quest.dueDate)
            guard day >= creationDate && day <= dueDate else { return nil }

            if quest.repeatType == .scheduled {
                let weekday = calendar.component(.weekday, from: day)
                guard quest.scheduledDays.contains(weekday) else { return nil }
            }

            let state: DayQuestState = quest.isCompleted(on: day) ? .done : .todo
            return DayQuestItem(id: quest.id, quest: quest, date: day, state: state)
        }

        return items.sorted { a, b in
            return a.quest.creationDate > b.quest.creationDate
        }
    }

    func toggle(item: DayQuestItem) {
        let newState: DayQuestState = item.state == .done ? .todo : .done

        let completionDate: Date
        switch item.quest.repeatType {
        case .oneTime:
            completionDate = item.quest.dueDate
        case .weekly:
            let comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: item.date)
            completionDate = calendar.date(from: comps) ?? item.date
        case .daily, .scheduled:
            completionDate = item.date
        }

        if newState == .done {
            // Provide haptic feedback immediately when user taps
            HapticFeedbackManager.shared.questCompleted()

            questDataService.markQuestCompleted(forId: item.quest.id, on: completionDate) { [weak self] error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.alertMessage = error.localizedDescription
                        // Provide error haptic feedback
                        HapticFeedbackManager.shared.errorOccurred()
                    } else {
                        self?.streakManager.recordActivity()

                        // Handle quest completion rewards
                        self?.rewardService.handleQuestCompletion(quest: item.quest) { rewardError in
                            if let rewardError = rewardError {
                                print("❌ Error handling quest completion rewards: \(rewardError)")
                            }
                        }

                        // Check if this quest should show completion is finished check
                        if item.quest.shouldShowFinishConfirmation(on: item.date) {
                            self?.questToCheckCompletion = item.quest
                            self?.showCompletionIsFinishedCheck = true
                        }

                    // Fetch quests to update the view and notify other views
                    self?.fetchQuests()
                    }
                }
            }
        } else {
            // Provide haptic feedback immediately when user taps
            HapticFeedbackManager.shared.questUncompleted()

            questDataService.unmarkQuestCompleted(forId: item.quest.id, on: completionDate) { [weak self] error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.alertMessage = error.localizedDescription
                        // Provide error haptic feedback
                        HapticFeedbackManager.shared.errorOccurred()
                    } else {
                        // Fetch quests to update the view and notify other views
                        self?.fetchQuests()
                    }
                }
            }
        }
    }

    func handleCompletionIsFinishedCheck(questId: UUID) {
        // Mark the quest as finished when user confirms from completion check
        markQuestAsFinished(questId: questId)
        // Reset the completion check state
        showCompletionIsFinishedCheck = false
        questToCheckCompletion = nil
    }

    func markQuestAsFinished(questId: UUID) {
        guard let quest = allQuests.first(where: { $0.id == questId }) else {
            alertMessage = "Quest not found"
            HapticFeedbackManager.shared.errorOccurred()
            return
        }

        questDataService.markQuestAsFinished(forId: questId) { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let error = error {
                    self.alertMessage = error.localizedDescription
                    HapticFeedbackManager.shared.errorOccurred()
                } else {
                    // Provide success haptic feedback for quest finished
                    HapticFeedbackManager.shared.questFinished()

                    // Calculate and award rewards using RewardSystem (includes premium multiplier)
                    let reward = RewardSystem.shared.calculateQuestReward(quest: quest)

                    print("🔄 MyQuestsViewModel: Calling updateUserExperience with \(reward.totalExperience) XP")
                    self.userManager.updateUserExperience(additionalExp: Int16(reward.totalExperience)) { leveledUp, newLevel, expError in
                        if let expError = expError {
                            print("❌ MyQuestsViewModel: Error updating experience: \(expError)")
                            self.alertMessage = expError.localizedDescription
                        } else {
                            print("✅ MyQuestsViewModel: Successfully updated user experience")
                            print("   Leveled Up: \(leveledUp), New Level: \(newLevel ?? 0)")
                            CurrencyManager.shared.addCoins(reward.totalCoins) { coinError in
                                if let coinError = coinError {
                                    print("❌ Error adding coins: \(coinError)")
                                }
                            }

                            // Add gems for quest completion
                            CurrencyManager.shared.addGems(reward.totalGems) { gemError in
                                if let gemError = gemError {
                                    print("❌ Error adding gems: \(gemError)")
                                }
                            }

                            self.streakManager.recordActivity()
                            self.checkAchievements()

                            // ✅ Expose completion/level-up to the View
                            self.lastCompletedQuestId = questId
                            self.lastCompletedQuest = quest
                            self.questCompleted = true
                            self.didLevelUp = leveledUp
                            self.newLevel = newLevel

                            // Fetch quests to update the view and notify other views
                            self.fetchQuests()
                        }
                    }
                }
            }
        }
    }

    func toggleTaskCompletion(questId: UUID, taskId: UUID, newValue: Bool) {
        // Provide haptic feedback immediately when user taps
        if newValue {
            HapticFeedbackManager.shared.taskCompleted()
        } else {
            HapticFeedbackManager.shared.taskUncompleted()
        }

        questDataService.updateTask(withId: taskId, isCompleted: newValue) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.alertMessage = error.localizedDescription
                    // Provide error haptic feedback
                    HapticFeedbackManager.shared.errorOccurred()
                } else {
                    // Record streak activity when completing a task
                    if newValue {
                        self?.streakManager.recordActivity()
                    }

                    // Handle task completion rewards if task is being completed
                    if newValue {
                        if let quest = self?.allQuests.first(where: { $0.id == questId }),
                           let task = quest.tasks.first(where: { $0.id == taskId }) {
                            self?.rewardService.handleTaskCompletion(task: task, quest: quest) { rewardError in
                                if let rewardError = rewardError {
                                    print("❌ Error handling task completion rewards: \(rewardError)")
                                }
                            }
                        }
                    }

                    // Fetch quests to update the view and notify other views
                    self?.fetchQuests()
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
