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
        print("🔄 QuestTrackingViewModel: Received quest updated notification")
        DispatchQueue.main.async { [weak self] in
            self?.fetchQuests()
        }
    }

    @objc private func handleQuestDeleted(_ notification: Notification) {
        print("🗑️ QuestTrackingViewModel: Received quest deleted notification")
        DispatchQueue.main.async { [weak self] in
            self?.fetchQuests()
        }
    }

    @objc private func handleQuestCreated(_ notification: Notification) {
        print("➕ QuestTrackingViewModel: Received quest created notification")
        DispatchQueue.main.async { [weak self] in
            self?.fetchQuests()
        }
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
            quests[index].isFinished = true
            quests[index].isFinishedDate = Date()
            quests[index].isActive = false
        }

        questDataService.markQuestAsFinished(forId: id) { [weak self] error in
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
            tasks: quest.tasks.map { $0.title },
            tags: Array(quest.tags)
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

    // MARK: - Tag Filtering

    private func handleTagFilterChange(tagIds: [UUID], matchMode: TagMatchMode) {
        // This method is called when tag filter changes
        // The filtering is applied in the computed property questsForSelectedFilter
        print("🏷️ Tag filter changed: \(tagIds.count) tags, mode: \(matchMode)")
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

    var activeTodayQuests: [Quest] {
        let now = Date()
        return quests.filter { quest in
            quest.isActive(on: now) && !quest.isFinished
        }
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
