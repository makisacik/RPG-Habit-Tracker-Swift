//
//  EditQuestViewModel.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 2.08.2025.
//

import Foundation
import SwiftUI
import Combine

final class EditQuestViewModel: ObservableObject {
    @Published var quest: Quest

    // Editable fields
    @Published var title: String
    @Published var description: String
    @Published var dueDate: Date
    @Published var isMainQuest: Bool
    @Published var difficulty: Int        // 1...5
    @Published var isActiveQuest: Bool

    @Published var tasks: [String]        // Task titles only (UI edits)
    @Published var selectedTags: [Tag]    // Selected tags for the quest
    @Published var repeatType: QuestRepeatType
    @Published var selectedScheduledDays: Set<Int>

    // UI state
    @Published var isSaving: Bool = false
    @Published var errorMessage: String?
    @Published var didUpdateQuest: Bool = false

    private let questDataService: QuestDataServiceProtocol

    init(quest: Quest, questDataService: QuestDataServiceProtocol) {
        self.quest = quest
        self.title = quest.title
        self.description = quest.info
        self.dueDate = quest.dueDate
        self.isMainQuest = quest.isMainQuest
        self.difficulty = quest.difficulty
        self.isActiveQuest = quest.isActive

        self.tasks = quest.tasks.map { $0.title }
        self.selectedTags = Array(quest.tags)
        self.repeatType = quest.repeatType
        self.selectedScheduledDays = quest.scheduledDays
        self.questDataService = questDataService
    }

    // MARK: - Validation

    func validateInputs() -> Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            errorMessage = String(localized: "quest_title_cannot_be_empty")
            return false
        }
        guard (1...5).contains(difficulty) else {
            errorMessage = String(localized: "difficulty_must_be_between_1_and_5")
            return false
        }

        // Don’t let due date be before creation date
        if dueDate < quest.creationDate {
            errorMessage = String(localized: "due_date_cannot_be_earlier_than_creation")
            return false
        }
        return true
    }

    // MARK: - Update

    func updateQuest(completion: @escaping (Bool) -> Void) {
        isSaving = true
        errorMessage = nil

        let dueDateChanged = quest.dueDate != dueDate

        questDataService.updateQuest(
            withId: quest.id,
            title: title,
            isMainQuest: isMainQuest,
            info: description,
            difficulty: difficulty,
            dueDate: dueDate,
            isActive: isActiveQuest,
            progress: quest.progress,
            repeatType: repeatType,
            tasks: tasks,
            tags: selectedTags,
            showProgress: quest.showProgress,
            scheduledDays: selectedScheduledDays
        ) { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isSaving = false

                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.didUpdateQuest = false
                    completion(false)
                    return
                }

                // Apply edits to local copy for immediate UI reflect
                self.applyEditsToLocalQuest()

                // Reschedule notifications if needed
                if dueDateChanged {
                    NotificationManager.shared.cancelQuestNotifications(questId: self.quest.id)
                    NotificationManager.shared.scheduleQuestNotification(for: self.quest)
                }

                self.didUpdateQuest = true
                completion(true)
            }
        }
    }

    // Preserve task IDs by index when possible; new tasks get new IDs.
    private func applyEditsToLocalQuest() {
        quest.title = title
        quest.info = description
        quest.dueDate = dueDate
        quest.isMainQuest = isMainQuest
        quest.difficulty = difficulty
        quest.isActive = isActiveQuest

        quest.repeatType = repeatType
        quest.scheduledDays = selectedScheduledDays
        quest.tags = Set(selectedTags)

        let existing = quest.tasks

        var newTasks: [QuestTask] = []
        newTasks.reserveCapacity(tasks.count)
        for (idx, title) in tasks.enumerated() {
            if idx < existing.count {
                // Keep the same ID and completion state if the slot still exists
                let old = existing[idx]
                newTasks.append(
                    QuestTask(
                        id: old.id,
                        title: title,
                        isCompleted: old.isCompleted,
                        order: idx
                    )
                )
            } else {
                // New task
                newTasks.append(
                    QuestTask(
                        id: UUID(),
                        title: title,
                        isCompleted: false,
                        order: idx
                    )
                )
            }
        }
        quest.tasks = newTasks
    }

    // MARK: - Delete

    func deleteQuest(completion: @escaping (Bool) -> Void) {
        isSaving = true
        errorMessage = nil
        questDataService.deleteQuest(withId: quest.id) { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isSaving = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    // Cancel any pending notifications
                    NotificationManager.shared.cancelQuestNotifications(questId: self.quest.id)
                    completion(true)
                }
            }
        }
    }
}
