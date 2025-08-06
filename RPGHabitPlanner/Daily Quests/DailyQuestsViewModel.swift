//
//  DailyQuestsViewModel.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import Foundation
import Combine

@MainActor
class DailyQuestsViewModel: ObservableObject {
    @Published var allDailyQuests: [DailyQuestTemplate] = []
    @Published var userActiveQuests: [Quest] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let questDataService: QuestDataServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(questDataService: QuestDataServiceProtocol) {
        self.questDataService = questDataService
        loadDailyQuestTemplates()
        fetchUserActiveQuests()
    }
    
    func loadDailyQuestTemplates() {
        allDailyQuests = DailyQuestTemplate.allTemplates
    }
    
    func fetchUserActiveQuests() {
        isLoading = true
        
        questDataService.fetchNonCompletedQuests { [weak self] quests, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Failed to load quests: \(error.localizedDescription)"
                } else {
                    self?.userActiveQuests = quests.filter { $0.isActive && !$0.isCompleted }
                }
            }
        }
    }
    
    func questsForCategory(_ category: DailyQuestCategory) -> [DailyQuestTemplate] {
        return allDailyQuests.filter { $0.category == category }
    }
    
    func isQuestAlreadyAdded(_ template: DailyQuestTemplate) -> Bool {
        return userActiveQuests.contains { quest in
            quest.title == template.title && quest.repeatType == .daily
        }
    }
    
    func addDailyQuest(_ template: DailyQuestTemplate) {
        let newQuest = Quest(
            title: template.title,
            isMainQuest: false,
            info: template.description,
            difficulty: template.difficulty,
            creationDate: Date(),
            dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
            isActive: true,
            progress: 0,
            tasks: template.tasks,
            repeatType: .daily
        )
        
        let taskTitles = template.tasks.map { $0.title }
        questDataService.saveQuest(newQuest, withTasks: taskTitles) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Failed to add quest: \(error.localizedDescription)"
                } else {
                    self?.fetchUserActiveQuests()
                }
            }
        }
    }
}
