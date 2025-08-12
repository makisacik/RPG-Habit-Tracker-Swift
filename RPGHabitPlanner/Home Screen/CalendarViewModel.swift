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
        print("��️ CalendarViewModel: Starting fetchQuests()")
        isLoading = true
        questDataService.fetchAllQuests { [weak self] quests, _ in
            DispatchQueue.main.async {
                print("��️ CalendarViewModel: Received \(quests.count) quests from fetchAllQuests")
                self?.isLoading = false
                self?.allQuests = quests
            }
        }
    }
    
    func items(for date: Date) -> [DayQuestItem] {
        let day = calendar.startOfDay(for: date)
        let result = allQuests.compactMap { (quest: Quest) -> DayQuestItem? in
            if quest.isFinished { return nil }
            let state = stateFor(quest, on: day)
            return state == .inactive ? nil : DayQuestItem(id: quest.id, quest: quest, date: day, state: state)
        }
        print("��️ CalendarViewModel: Computing items for \(day) - found \(result.count) items")
        return result
    }
    
    func toggle(item: DayQuestItem) {
        let today = calendar.startOfDay(for: Date())
        switch item.quest.repeatType {
        case .daily:
            guard calendar.isDate(item.date, inSameDayAs: today) else {
                alertMessage = "Daily quests can only be toggled for today."
                return
            }
            let dayAnchor = calendar.startOfDay(for: item.date)
            if item.state == .done {
                questDataService.unmarkQuestCompleted(forId: item.id, on: dayAnchor) { [weak self] _ in self?.fetchQuests() }
            } else {
                questDataService.markQuestCompleted(forId: item.id, on: dayAnchor) { [weak self] _ in self?.fetchQuests() }
            }
        case .weekly:
            guard isSameWeek(item.date, today) else {
                alertMessage = "Weekly quests can only be toggled in the current week."
                return
            }
            let anchor = weekAnchor(for: item.date)
            if item.state == .done {
                questDataService.unmarkQuestCompleted(forId: item.id, on: anchor) { [weak self] _ in self?.fetchQuests() }
            } else {
                questDataService.markQuestCompleted(forId: item.id, on: anchor) { [weak self] _ in self?.fetchQuests() }
            }
        case .oneTime:
            guard item.date >= calendar.startOfDay(for: item.quest.creationDate) &&
                  item.date <= calendar.startOfDay(for: item.quest.dueDate) else {
                alertMessage = "This quest can only be completed between creation and due date."
                return
            }
            // For one-time quests, always store completion at the due date
            let dueDateAnchor = calendar.startOfDay(for: item.quest.dueDate)
            if item.state == .done {
                questDataService.unmarkQuestCompleted(forId: item.id, on: dueDateAnchor) { [weak self] _ in self?.fetchQuests() }
            } else {
                questDataService.markQuestCompleted(forId: item.id, on: dueDateAnchor) { [weak self] _ in self?.fetchQuests() }
            }
        }
    }
    
    // MARK: - Quest Management
    
    func markQuestAsFinished(questId: UUID) {
        print("��️ CalendarViewModel: Marking quest \(questId) as finished")
        
        // Optimistically update the local quest array
        if let index = allQuests.firstIndex(where: { $0.id == questId }) {
            allQuests[index].isFinished = true
            allQuests[index].isFinishedDate = Date()
            print("��️ CalendarViewModel: Updated local quest array - quest is now finished")
        }
        
        // Update the server
        questDataService.markQuestAsFinished(forId: questId) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    print("��️ CalendarViewModel: Error marking quest as finished: \(error)")
                    // Revert the optimistic update on error
                    self?.fetchQuests()
                } else {
                    print("��️ CalendarViewModel: Successfully marked quest as finished on server")
                    // Optionally refresh to ensure consistency
                    self?.fetchQuests()
                }
            }
        }
    }
    
    private func stateFor(_ quest: Quest, on day: Date) -> DayQuestState {
        if quest.dueDate < day { return .inactive }
        switch quest.repeatType {
        case .oneTime:
            guard day >= calendar.startOfDay(for: quest.creationDate) &&
                  day <= calendar.startOfDay(for: quest.dueDate) else { return .inactive }
            // For one-time quests, check if completed at the due date anchor
            let dueDateAnchor = calendar.startOfDay(for: quest.dueDate)
            return quest.completions.contains(dueDateAnchor) ? .done : .todo
        case .daily:
            let start = Calendar.current.startOfDay(for: quest.creationDate)
            guard day >= start && day <= Calendar.current.startOfDay(for: quest.dueDate) else { return .inactive }
            let dayAnchor = calendar.startOfDay(for: day)
            return quest.completions.contains(dayAnchor) ? .done : .todo
        case .weekly:
            guard isInRange(quest: quest, day: day) else { return .inactive }
            return completedInWeek(quest: quest, containing: day) ? .done : .todo
        }
    }
    
    private func isInRange(quest: Quest, day: Date) -> Bool {
        let start = Calendar.current.startOfDay(for: quest.creationDate)
        let end = Calendar.current.startOfDay(for: quest.dueDate)
        return day >= start && day <= end
    }
    
    private func completedInWeek(quest: Quest, containing day: Date) -> Bool {
        let weekAnchor = self.weekAnchor(for: day)
        return quest.completions.contains(weekAnchor)
    }

    private func isSameWeek(_ a: Date, _ b: Date) -> Bool {
        calendar.isDate(a, equalTo: b, toGranularity: .weekOfYear)
    }

    private func weekAnchor(for day: Date) -> Date {
        let comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: day)
        let start = calendar.date(from: comps) ?? day
        return calendar.startOfDay(for: start)
    }
    
    func toggleTaskCompletion(questId: UUID, taskId: UUID, newValue: Bool) {
        print("️ CalendarViewModel: Toggling task \(taskId) completion to \(newValue)")
        
        // Optimistically update the local quest array
        if let questIndex = allQuests.firstIndex(where: { $0.id == questId }),
           let taskIndex = allQuests[questIndex].tasks.firstIndex(where: { $0.id == taskId }) {
            allQuests[questIndex].tasks[taskIndex].isCompleted = newValue
            print("️ CalendarViewModel: Updated local quest array - task completion is now \(newValue)")
        }
        
        // Update the server
        questDataService.updateTask(withId: taskId, isCompleted: newValue) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    print("️ CalendarViewModel: Error updating task completion: \(error)")
                    // Revert the optimistic update on error
                    self?.fetchQuests()
                } else {
                    print("️ CalendarViewModel: Successfully updated task completion on server")
                }
            }
        }
    }
}
