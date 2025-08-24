//
//  CalendarViewModel.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 11.11.2024.
//

import SwiftUI
import Foundation

enum DayQuestState { case done, todo, inactive }

struct DayQuestItem: Identifiable {
    let id: UUID
    let quest: Quest
    let date: Date
    let state: DayQuestState
}

final class CalendarViewModel: ObservableObject {
    @Published var allQuests: [Quest] = []
    @Published var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    @Published var isLoading = false
    @Published var alertMessage: String?
    @Published var refreshTrigger: Bool = false
    @Published var showFinishConfirmation: Bool = false
    @Published var questToFinish: Quest?

    let questDataService: QuestDataServiceProtocol
    private let userManager: UserManager
    private let calendar = Calendar.current
    private let streakManager = StreakManager.shared
    private let boosterManager = BoosterManager.shared

    // Tag filtering support
    lazy var tagFilterViewModel: TagFilterViewModel = {
        TagFilterViewModel { [weak self] tagIds, matchMode in
            self?.handleTagFilterChange(tagIds: tagIds, matchMode: matchMode)
        }
    }()

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
    }

    @objc private func handleQuestUpdated(_ notification: Notification) {
        print("🔄 CalendarViewModel: Received quest updated notification")
        DispatchQueue.main.async { [weak self] in
            self?.fetchQuests()
            // Force UI refresh
            self?.refreshTrigger.toggle()
        }
    }

    @objc private func handleQuestDeleted(_ notification: Notification) {
        print("🗑️ CalendarViewModel: Received quest deleted notification")
        DispatchQueue.main.async { [weak self] in
            self?.fetchQuests()
            // Force UI refresh
            self?.refreshTrigger.toggle()
        }
    }

    @objc private func handleQuestCreated(_ notification: Notification) {
        print("➕ CalendarViewModel: Received quest created notification")
        DispatchQueue.main.async { [weak self] in
            self?.fetchQuests()
            // Force UI refresh
            self?.refreshTrigger.toggle()
        }
    }

    var itemsForSelectedDate: [DayQuestItem] {
        // Force recomputation when refreshTrigger changes
        _ = refreshTrigger
        return items(for: selectedDate)
    }

    func fetchQuests() {
        print("📅 CalendarViewModel: Starting fetchQuests()")
        isLoading = true

        // First refresh all quest states to ensure they're up to date
        questDataService.refreshAllQuests(on: Date()) { [weak self] error in
            if let error = error {
                print("❌ CalendarViewModel: Error refreshing quests: \(error)")
            }

            // Then fetch the updated quest data
            self?.questDataService.fetchAllQuests { [weak self] quests, _ in
                DispatchQueue.main.async {
                    print("📅 CalendarViewModel: Received \(quests.count) quests from fetchAllQuests")
                    self?.isLoading = false
                    self?.allQuests = quests
                }
            }
        }
    }

    func items(for date: Date) -> [DayQuestItem] {
        let day = calendar.startOfDay(for: date)
        let filteredQuests = applyTagFiltering(to: allQuests)

        let items: [DayQuestItem] = filteredQuests.compactMap { quest in
            // Don't show finished quests in the calendar
            guard !quest.isFinished else { return nil }

            // First check if the date is within the quest's valid date range
            let creationDate = calendar.startOfDay(for: quest.creationDate)
            let dueDate = calendar.startOfDay(for: quest.dueDate)

            // Date must be between creation date and due date (inclusive)
            guard day >= creationDate && day <= dueDate else { return nil }

            // For scheduled quests, check if it's a scheduled day (allow both active and completed quests)
            if quest.repeatType == .scheduled {
                let weekday = calendar.component(.weekday, from: day)
                let isScheduledDay = quest.scheduledDays.contains(weekday)
                guard isScheduledDay else { return nil }
            }

            let state: DayQuestState
            if quest.isCompleted(on: day) {
                state = .done
            } else {
                state = .todo
            }

            return DayQuestItem(id: quest.id, quest: quest, date: day, state: state)
        }

        // Sort items: active quests first, then completed quests
        return items.sorted { (item1: DayQuestItem, item2: DayQuestItem) in
            if item1.state == DayQuestState.todo && item2.state == DayQuestState.done {
                return true // item1 (todo) comes before item2 (done)
            } else if item1.state == DayQuestState.done && item2.state == DayQuestState.todo {
                return false // item2 (todo) comes before item1 (done)
            } else {
                // If both have the same state, sort by creation date (newer first)
                return item1.quest.creationDate > item2.quest.creationDate
            }
        }
    }

    // MARK: - Tag Filtering

    private func handleTagFilterChange(tagIds: [UUID], matchMode: TagMatchMode) {
        // This method is called when tag filter changes
        // The filtering is applied in the items(for:) method
        print("🏷️ Calendar tag filter changed: \(tagIds.count) tags, mode: \(matchMode)")
    }

    func applyTagFiltering(to quests: [Quest]) -> [Quest] {
        let selectedTagIds = tagFilterViewModel.selectedTags.map { $0.id }

        // If no tags are selected, return all quests
        guard !selectedTagIds.isEmpty else {
            return quests
        }

        return quests.filter { quest in
            let questTagIds = quest.tags.map { $0.id }

            switch tagFilterViewModel.matchMode {
            case .any:
                // Quest has ANY of the selected tags
                return !Set(questTagIds).isDisjoint(with: Set(selectedTagIds))
            case .all:
                // Quest has ALL of the selected tags
                return Set(selectedTagIds).isSubset(of: Set(questTagIds))
            }
        }
    }

    func toggle(item: DayQuestItem) {
        let newState: DayQuestState = item.state == .done ? .todo : .done

        // Determine the correct completion date based on quest type
        let completionDate: Date
        switch item.quest.repeatType {
        case .oneTime:
            // For one-time quests, always use the due date for completion tracking
            completionDate = item.quest.dueDate
        case .weekly:
            // For weekly quests, use the week anchor (start of the week)
            let calendar = Calendar.current
            let comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: item.date)
            completionDate = calendar.date(from: comps) ?? item.date
        case .daily:
            // For daily quests, use the specific date
            completionDate = item.date
        case .scheduled:
            // For scheduled quests, use the specific date
            completionDate = item.date
        }

        if newState == .done {
            // Mark as completed
            questDataService.markQuestCompleted(forId: item.quest.id, on: completionDate) { [weak self] error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.alertMessage = error.localizedDescription
                    } else {
                        // Record streak activity when completing a quest
                        self?.streakManager.recordActivity()

                        // Check if this quest should show finish confirmation
                        if item.quest.shouldShowFinishConfirmation(on: item.date) {
                            self?.questToFinish = item.quest
                            self?.showFinishConfirmation = true
                        }

                        self?.fetchQuests()
                    }
                }
            }
        } else {
            // Mark as incomplete
            questDataService.unmarkQuestCompleted(forId: item.quest.id, on: completionDate) { [weak self] error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.alertMessage = error.localizedDescription
                    } else {
                        self?.fetchQuests()
                    }
                }
            }
        }
    }

    func markQuestAsFinished(questId: UUID) {
        // Find the quest to get its details for reward calculation
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
                    // Calculate base rewards
                    let baseExp: Int
                    let baseCoins: Int

                    #if DEBUG
                    baseExp = 50 * quest.difficulty
                    #else
                    baseExp = 10 * quest.difficulty
                    #endif

                    // Calculate coin reward using CurrencyManager
                    baseCoins = CurrencyManager.shared.calculateQuestReward(
                        difficulty: quest.difficulty,
                        isMainQuest: quest.isMainQuest,
                        taskCount: quest.tasks.count
                    )

                    // Apply boosters
                    let boostedRewards = self.boosterManager.calculateBoostedRewards(
                        baseExperience: baseExp,
                        baseCoins: baseCoins
                    )

                    // Award boosted experience
                    self.userManager.updateUserExperience(additionalExp: Int16(boostedRewards.experience)) { _, _, expError in
                        if let expError = expError {
                            self.alertMessage = expError.localizedDescription
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
                            self.checkAchievements()

                            self.fetchQuests()
                        }
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

    func toggleTaskCompletion(questId: UUID, taskId: UUID, newValue: Bool) {
        questDataService.updateTask(
            withId: taskId,
            isCompleted: newValue
        ) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.alertMessage = error.localizedDescription
                } else {
                    self?.fetchQuests()
                }
            }
        }
    }
}
