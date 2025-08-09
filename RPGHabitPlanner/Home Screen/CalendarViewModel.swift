//
//  CalendarViewModel.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 11.11.2024.
//

import SwiftUI

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
    
    let questDataService: QuestDataServiceProtocol
    private let calendar = Calendar.current
    
    init(questDataService: QuestDataServiceProtocol) {
        self.questDataService = questDataService
    }
    
    var itemsForSelectedDate: [DayQuestItem] { items(for: selectedDate) }
    
    func fetchQuests() {
        isLoading = true
        questDataService.fetchAllQuests { [weak self] quests, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.allQuests = quests
            }
        }
    }
    
    func items(for date: Date) -> [DayQuestItem] {
        let day = calendar.startOfDay(for: date)
        return allQuests.compactMap { quest in
            let state = stateFor(quest, on: day)
            return state == .inactive ? nil : DayQuestItem(id: quest.id, quest: quest, date: day, state: state)
        }
    }
    
    func toggle(item: DayQuestItem) {
        switch item.state {
        case .done:
            questDataService.unmarkQuestCompleted(forId: item.id, on: item.date) { [weak self] _ in
                self?.fetchQuests()
            }
        case .todo:
            questDataService.markQuestCompleted(forId: item.id, on: item.date) { [weak self] _ in
                self?.fetchQuests()
            }
        case .inactive:
            break
        }
    }
    
    private func stateFor(_ quest: Quest, on day: Date) -> DayQuestState {
        if quest.dueDate < day { return .inactive }
        switch quest.repeatType {
        case .oneTime:
            guard Calendar.current.isDate(quest.dueDate, inSameDayAs: day) else { return .inactive }
            return quest.completions.contains(day) ? .done : .todo
        case .daily:
            let start = Calendar.current.startOfDay(for: quest.creationDate)
            guard day >= start && day <= Calendar.current.startOfDay(for: quest.dueDate) else { return .inactive }
            return quest.completions.contains(day) ? .done : .todo
        case .weekly:
            guard isInRange(quest: quest, day: day) else { return .inactive }
            let done = completedInWeek(quest: quest, containing: day)
            return done ? .done : .todo
        }
    }
    
    private func isInRange(quest: Quest, day: Date) -> Bool {
        let start = Calendar.current.startOfDay(for: quest.creationDate)
        let end = Calendar.current.startOfDay(for: quest.dueDate)
        return day >= start && day <= end
    }
    
    private func completedInWeek(quest: Quest, containing day: Date) -> Bool {
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: day)),
              let range = calendar.range(of: .day, in: .weekOfYear, for: day) else { return false }
        let days = (0..<(range.count)).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }.map { calendar.startOfDay(for: $0) }
        return days.contains { quest.completions.contains($0) }
    }
}
