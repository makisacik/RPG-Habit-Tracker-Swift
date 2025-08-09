//
//  CalendarViewModel.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 11.11.2024.
//

import SwiftUI
import Foundation

class CalendarViewModel: ObservableObject {
    @Published var allQuests: [Quest] = []
    @Published var selectedDate = Date()
    @Published var isLoading = false
    
    private let questDataService: QuestDataServiceProtocol
    private let calendar = Calendar.current
    
    init(questDataService: QuestDataServiceProtocol) {
        self.questDataService = questDataService
    }
    
    var questDataServiceProtocol: QuestDataServiceProtocol {
        return questDataService
    }
    
    var questsForSelectedDate: [Quest] {
        return questsForDate(selectedDate)
    }
    
    func fetchQuests() {
        isLoading = true
        
        questDataService.fetchAllQuests { [weak self] quests, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    print("Failed to fetch quests for calendar: \(error)")
                } else {
                    self?.allQuests = quests
                }
            }
        }
    }
    
    func questsForDate(_ date: Date) -> [Quest] {
        return allQuests.filter { quest in
            // Check if the quest is due on this date or was completed on this date
            let isDueOnDate = calendar.isDate(quest.dueDate, inSameDayAs: date)
            let wasCompletedOnDate = quest.completionDate != nil && calendar.isDate(quest.completionDate!, inSameDayAs: date)
            
            return isDueOnDate || wasCompletedOnDate
        }
    }
    
    func questsForMonth(_ date: Date) -> [Quest] {
        let startOfMonth = calendar.dateInterval(of: .month, for: date)?.start ?? date
        let endOfMonth = calendar.dateInterval(of: .month, for: date)?.end ?? date
        
        return allQuests.filter { quest in
            // Check if the quest is due within this month or was completed within this month
            let isDueInMonth = quest.dueDate >= startOfMonth && quest.dueDate < endOfMonth
            let wasCompletedInMonth = quest.completionDate != nil && quest.completionDate! >= startOfMonth && quest.completionDate! < endOfMonth
            
            return isDueInMonth || wasCompletedInMonth
        }
    }
    
    func questsForWeek(_ date: Date) -> [Quest] {
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        let endOfWeek = calendar.dateInterval(of: .weekOfYear, for: date)?.end ?? date
        
        return allQuests.filter { quest in
            // Check if the quest is due within this week or was completed within this week
            let isDueInWeek = quest.dueDate >= startOfWeek && quest.dueDate < endOfWeek
            let wasCompletedInWeek = quest.completionDate != nil && quest.completionDate! >= startOfWeek && quest.completionDate! < endOfWeek
            
            return isDueInWeek || wasCompletedInWeek
        }
    }
    
    func hasQuestsOnDate(_ date: Date) -> Bool {
        return !questsForDate(date).isEmpty
    }
    
    func getQuestCountForDate(_ date: Date) -> Int {
        return questsForDate(date).count
    }
    
    func getCompletedQuestsForDate(_ date: Date) -> [Quest] {
        return questsForDate(date).filter { $0.isCompleted }
    }
    
    func getActiveQuestsForDate(_ date: Date) -> [Quest] {
        return questsForDate(date).filter { !$0.isCompleted }
    }
}
