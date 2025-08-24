//
//  QuestsViewModel.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI
import Foundation

final class QuestsViewModel: ObservableObject {
    @Published var allQuests: [Quest] = []
    @Published var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    @Published var isLoading = false
    @Published var alertMessage: String?
    @Published var questCompleted: Bool = false
    @Published var didLevelUp: Bool = false
    @Published var newLevel: Int16?
    @Published var lastCompletedQuestId: UUID?
    @Published var lastCompletedQuest: Quest?
    @Published var showFinishConfirmation: Bool = false
    @Published var questToFinish: Quest?

    let questDataService: QuestDataServiceProtocol
    private let userManager: UserManager
    private let calendar = Calendar.current
    private let streakManager = StreakManager.shared
    private let boosterManager = BoosterManager.shared

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

        // Support "complete from detail" flow
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleQuestCompletedFromDetail),
            name: .questCompletedFromDetail,
            object: nil
        )
    }

    @objc private func handleQuestUpdated(_ notification: Notification) {
        print("🔄 QuestsViewModel: Received quest updated notification")
        DispatchQueue.main.async { [weak self] in
            self?.fetchQuests()
        }
    }

    @objc private func handleQuestDeleted(_ notification: Notification) {
        print("🗑️ QuestsViewModel: Received quest deleted notification")
        DispatchQueue.main.async { [weak self] in
            self?.fetchQuests()
        }
    }

    @objc private func handleQuestCreated(_ notification: Notification) {
        print("➕ QuestsViewModel: Received quest created notification")
        DispatchQueue.main.async { [weak self] in
            self?.fetchQuests()
        }
    }

    @objc private func handleQuestCompletedFromDetail(_ notification: Notification) {
        print("🎯 QuestsViewModel: Received quest completed from detail notification")
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
        print("📅 QuestsViewModel: Starting fetchQuests()")
        isLoading = true
        questDataService.refreshAllQuests(on: Date()) { [weak self] _ in
            self?.questDataService.fetchAllQuests { [weak self] quests, _ in
                DispatchQueue.main.async {
                    print("📅 QuestsViewModel: Received \(quests.count) quests from fetchAllQuests")
                    self?.isLoading = false
                    self?.allQuests = quests
                }
            }
        }
    }

    // New method to refresh quest data without showing loading state
    func refreshQuestData() {
        questDataService.refreshAllQuests(on: Date()) { [weak self] _ in
            self?.questDataService.fetchAllQuests { [weak self] quests, _ in
                DispatchQueue.main.async {
                    print("📅 QuestsViewModel: Refreshed quest data with \(quests.count) quests")
                    self?.allQuests = quests
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
            questDataService.markQuestCompleted(forId: item.quest.id, on: completionDate) { [weak self] error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.alertMessage = error.localizedDescription
                    } else {
                        self?.streakManager.recordActivity()

                        // Check if this quest should show finish confirmation
                        if item.quest.shouldShowFinishConfirmation(on: item.date) {
                            self?.questToFinish = item.quest
                            self?.showFinishConfirmation = true
                        }

                        // Fetch quests to update the view and notify other views
                        self?.fetchQuests()
                    }
                }
            }
        } else {
            questDataService.unmarkQuestCompleted(forId: item.quest.id, on: completionDate) { [weak self] error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.alertMessage = error.localizedDescription
                    } else {
                        // Fetch quests to update the view and notify other views
                        self?.fetchQuests()
                    }
                }
            }
        }
    }

    func markQuestAsFinished(questId: UUID) {
        guard let quest = allQuests.first(where: { $0.id == questId }) else {
            alertMessage = "Quest not found"
            return
        }

        questDataService.markQuestAsFinished(forId: questId) { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let error = error {
                    self.alertMessage = error.localizedDescription
                } else {
                    let baseExp: Int
                    let baseCoins: Int

                    #if DEBUG
                    baseExp = 50 * quest.difficulty
                    #else
                    baseExp = 10 * quest.difficulty
                    #endif

                    baseCoins = CurrencyManager.shared.calculateQuestReward(
                        difficulty: quest.difficulty,
                        isMainQuest: quest.isMainQuest,
                        taskCount: quest.tasks.count
                    )

                    let boosted = self.boosterManager.calculateBoostedRewards(
                        baseExperience: baseExp,
                        baseCoins: baseCoins
                    )

                    self.userManager.updateUserExperience(additionalExp: Int16(boosted.experience)) { leveledUp, newLevel, expError in
                        if let expError = expError {
                            self.alertMessage = expError.localizedDescription
                        } else {
                            CurrencyManager.shared.addCoins(boosted.coins) { coinError in
                                if let coinError = coinError {
                                    print("❌ Error adding coins: \(coinError)")
                                }
                            }

                            self.streakManager.recordActivity()
                            self.checkAchievements()

                            // Expose completion/level-up to the View
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
        questDataService.updateTask(withId: taskId, isCompleted: newValue) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.alertMessage = error.localizedDescription
                } else {
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
