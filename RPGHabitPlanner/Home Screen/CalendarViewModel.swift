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
    @Published var showFinishConfirmation: Bool = false
    @Published var questToFinish: Quest?
    @Published var showCompletionIsFinishedCheck: Bool = false
    @Published var questToCheckCompletion: Quest?
    
    // 🔁 Bump this whenever the underlying data that drives the calendar changes
    @Published var calendarDataVersion: Int = 0
    
    // Reward system properties
    @Published var questCompleted: Bool = false
    @Published var didLevelUp: Bool = false
    @Published var newLevel: Int16?
    @Published var lastCompletedQuestId: UUID?
    @Published var lastCompletedQuest: Quest?
    
    let questDataService: QuestDataServiceProtocol
    private let userManager: UserManager
    private let calendar = Calendar.current
    private let streakManager = StreakManager.shared
    private let boosterManager = BoosterManager.shared
    private let rewardService = RewardService.shared
    
    // Tag filtering support
    lazy var tagFilterViewModel: TagFilterViewModel = {
        TagFilterViewModel { [weak self] tagIds, matchMode in
            self?.handleTagFilterChange(tagIds: tagIds, matchMode: matchMode)
            // Filtering affects items per day → bump version to redraw dots
            self?.bumpCalendarVersion()
        }
    }()
    
    init(questDataService: QuestDataServiceProtocol, userManager: UserManager) {
        self.questDataService = questDataService
        self.userManager = userManager
        fetchQuests()
        setupNotificationObservers()
    }
    
    deinit { NotificationCenter.default.removeObserver(self) }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleQuestUpdated), name: .questUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleQuestDeleted), name: .questDeleted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleQuestCreated), name: .questCreated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleQuestCompletedFromDetail), name: .questCompletedFromDetail, object: nil)
    }
    
    @objc private func handleQuestUpdated(_ notification: Notification) {
        print("🔄 CalendarViewModel: Received quest updated notification")
        DispatchQueue.main.async { [weak self] in self?.silentUpdateQuests() }
    }

    @objc private func handleQuestDeleted(_ notification: Notification) {
        print("🗑️ CalendarViewModel: Received quest deleted notification")
        DispatchQueue.main.async { [weak self] in self?.silentUpdateQuests() }
    }

    @objc private func handleQuestCreated(_ notification: Notification) {
        print("➕ CalendarViewModel: Received quest created notification")
        DispatchQueue.main.async { [weak self] in self?.silentUpdateQuests() }
    }
    
    @objc private func handleQuestCompletedFromDetail(_ notification: Notification) {
        print("🎯 CalendarViewModel: Received quest completed from detail notification")
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let quest = notification.object as? Quest,
                  let userInfo = notification.userInfo,
                  let questId = userInfo["questId"] as? UUID,
                  let leveledUp = userInfo["leveledUp"] as? Bool,
                  let newLevel = userInfo["newLevel"] as? Int16 else { return }
            
            self.lastCompletedQuestId = questId
            self.lastCompletedQuest = quest
            self.questCompleted = true
            self.didLevelUp = leveledUp
            self.newLevel = newLevel
            
            self.silentUpdateQuests()
        }
    }
    
    var itemsForSelectedDate: [DayQuestItem] { items(for: selectedDate) }
    
    var shouldShowLoadingState: Bool { isLoading && allQuests.isEmpty }
    
    func fetchQuests() {
        print("📅 CalendarViewModel: Starting fetchQuests()")
        isLoading = true
        
        questDataService.refreshAllQuests(on: Date()) { [weak self] _ in
            self?.questDataService.fetchAllQuests { [weak self] quests, _ in
                DispatchQueue.main.async {
                    print("📅 CalendarViewModel: Received \(quests.count) quests from fetchAllQuests")
                    self?.isLoading = false
                    self?.allQuests = quests
                    self?.bumpCalendarVersion() // 🔁 ensure UI refreshes
                }
            }
        }
    }
    
    func refreshQuestData() {
        questDataService.refreshAllQuests(on: Date()) { [weak self] _ in
            self?.questDataService.fetchAllQuests { [weak self] quests, _ in
                DispatchQueue.main.async {
                    print("📅 CalendarViewModel: Refreshed quest data with \(quests.count) quests")
                    self?.allQuests = quests
                    NotificationCenter.default.post(name: .questUpdated, object: nil)
                    self?.bumpCalendarVersion() // 🔁
                }
            }
        }
    }
    
    func silentUpdateQuests() {
        questDataService.refreshAllQuests(on: Date()) { [weak self] _ in
            self?.questDataService.fetchAllQuests { [weak self] quests, _ in
                DispatchQueue.main.async {
                    print("📅 CalendarViewModel: Silently updated quest data with \(quests.count) quests")
                    self?.allQuests = quests
                    self?.bumpCalendarVersion() // 🔁
                }
            }
        }
    }
    
    private func bumpCalendarVersion() {
        // Using wrapping add to avoid overflow crashes in long sessions
        calendarDataVersion &+= 1
    }
    
    func items(for date: Date) -> [DayQuestItem] {
        let day = calendar.startOfDay(for: date)
        let filteredQuests = applyTagFiltering(to: allQuests)
        
        let items: [DayQuestItem] = filteredQuests.compactMap { quest in
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
        
        return items.sorted { a, b in a.quest.creationDate > b.quest.creationDate }
    }
    
    // MARK: - Tag Filtering
    private func handleTagFilterChange(tagIds: [UUID], matchMode: TagMatchMode) {
        print("🏷️ Calendar tag filter changed: \(tagIds.count) tags, mode: \(matchMode)")
    }
    
    func applyTagFiltering(to quests: [Quest]) -> [Quest] {
        let selectedTagIds = tagFilterViewModel.selectedTags.map { $0.id }
        guard !selectedTagIds.isEmpty else { return quests }
        
        return quests.filter { quest in
            let questTagIds = quest.tags.map { $0.id }
            switch tagFilterViewModel.matchMode {
            case .any: return !Set(questTagIds).isDisjoint(with: Set(selectedTagIds))
            case .all: return Set(selectedTagIds).isSubset(of: Set(questTagIds))
            }
        }
    }
    
    // MARK: - Toggling
    func toggle(item: DayQuestItem) {
        let newState: DayQuestState = item.state == .done ? .todo : .done
        
        let completionDate: Date
        switch item.quest.repeatType {
        case .oneTime:
            completionDate = item.quest.dueDate
        case .weekly:
            let comps = Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: item.date)
            completionDate = Calendar.current.date(from: comps) ?? item.date
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
                        self?.rewardService.handleQuestCompletion(quest: item.quest) { err in
                            if let err = err { print("❌ Reward error: \(err)") }
                        }
                        if item.quest.shouldShowFinishConfirmation(on: item.date) {
                            self?.questToCheckCompletion = item.quest
                            self?.showCompletionIsFinishedCheck = true
                        }
                        self?.silentUpdateQuests() // will bump version
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
                        self?.silentUpdateQuests() // will bump version
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
                    let baseExp: Int
                    let baseCoins: Int
                    #if DEBUG
                    baseExp = 50 * quest.difficulty
                    #else
                    baseExp = 10 * quest.difficulty
                    #endif
                    
                    let coins = CurrencyManager.shared.calculateQuestReward(
                        difficulty: quest.difficulty,
                        isMainQuest: quest.isMainQuest,
                        taskCount: quest.tasks.count
                    )
                    
                    let boosted = self.boosterManager.calculateBoostedRewards(
                        baseExperience: baseExp,
                        baseCoins: coins
                    )
                    
                    self.userManager.updateUserExperience(additionalExp: Int16(boosted.experience)) { leveledUp, newLevel, expError in
                        if let expError = expError {
                            self.alertMessage = expError.localizedDescription
                        } else {
                            CurrencyManager.shared.addCoins(boosted.coins) { coinError in
                                if let coinError = coinError { print("❌ Error adding coins: \(coinError)") }
                            }
                            self.streakManager.recordActivity()
                            self.checkAchievements()
                            
                            self.lastCompletedQuestId = questId
                            self.lastCompletedQuest = quest
                            self.questCompleted = true
                            self.didLevelUp = leveledUp
                            self.newLevel = newLevel
                            
                            self.silentUpdateQuests() // will bump version
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
                    if newValue,
                       let quest = self?.allQuests.first(where: { $0.id == questId }),
                       let task = quest.tasks.first(where: { $0.id == taskId }) {
                        self?.rewardService.handleTaskCompletion(task: task, quest: quest) { err in
                            if let err = err { print("❌ Task reward error: \(err)") }
                        }
                    }
                    self?.silentUpdateQuests() // will bump version
                }
            }
        }
    }
}
