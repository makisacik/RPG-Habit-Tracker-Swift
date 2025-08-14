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

    let questDataService: QuestDataServiceProtocol
    private let calendar = Calendar.current

    // Tag filtering support
    lazy var tagFilterViewModel: TagFilterViewModel = {
        TagFilterViewModel { [weak self] tagIds, matchMode in
            self?.handleTagFilterChange(tagIds: tagIds, matchMode: matchMode)
        }
    }()

    init(questDataService: QuestDataServiceProtocol) {
        self.questDataService = questDataService
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
        }
    }

    @objc private func handleQuestDeleted(_ notification: Notification) {
        print("🗑️ CalendarViewModel: Received quest deleted notification")
        DispatchQueue.main.async { [weak self] in
            self?.fetchQuests()
        }
    }

    @objc private func handleQuestCreated(_ notification: Notification) {
        print("➕ CalendarViewModel: Received quest created notification")
        DispatchQueue.main.async { [weak self] in
            self?.fetchQuests()
        }
    }

    var itemsForSelectedDate: [DayQuestItem] { items(for: selectedDate) }

    func fetchQuests() {
        print("📅 CalendarViewModel: Starting fetchQuests()")
        isLoading = true
        questDataService.fetchAllQuests { [weak self] quests, _ in
            DispatchQueue.main.async {
                print("📅 CalendarViewModel: Received \(quests.count) quests from fetchAllQuests")
                self?.isLoading = false
                self?.allQuests = quests
            }
        }
    }

    func items(for date: Date) -> [DayQuestItem] {
        let day = calendar.startOfDay(for: date)
        let filteredQuests = applyTagFiltering(to: allQuests)

        return filteredQuests.compactMap { quest in
            guard quest.isActive(on: day) else { return nil }

            let state: DayQuestState
            if quest.isCompleted(on: day) {
                state = .done
            } else if quest.isActive(on: day) {
                state = .todo
            } else {
                state = .inactive
            }

            return DayQuestItem(id: quest.id, quest: quest, date: day, state: state)
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

        if newState == .done {
            // Mark as completed
            questDataService.markQuestCompleted(forId: item.quest.id, on: item.date) { [weak self] error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.alertMessage = error.localizedDescription
                    } else {
                        self?.fetchQuests()
                    }
                }
            }
        } else {
            // Mark as incomplete
            questDataService.unmarkQuestCompleted(forId: item.quest.id, on: item.date) { [weak self] error in
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
        questDataService.markQuestAsFinished(forId: questId) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.alertMessage = error.localizedDescription
                } else {
                    self?.fetchQuests()
                }
            }
        }
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
