//
//  QuestFirebaseService.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 30.10.2024.
//

import Foundation

final class QuestFirebaseService: QuestDataServiceProtocol {
    func updateQuestProgress(withId id: UUID, progress: Int, completion: @escaping (Error?) -> Void) {
        // TODO: Implement Firebase quest progress update
        completion(nil)
    }
    
    func updateQuest(withId id: UUID, title: String?, isMainQuest: Bool?, info: String?, difficulty: Int?, dueDate: Date?, isActive: Bool?, progress: Int?, repeatType: QuestRepeatType?, repeatIntervalWeeks: Int?, tasks: [String]?, completion: @escaping ((any Error)?) -> Void) {
    }
    
    func updateTask(withId id: UUID, title: String?, isCompleted: Bool?, order: Int16?, questId: UUID?, completion: @escaping ((any Error)?) -> Void) {
    }
    
    func updateTaskCompletion(forQuestId questId: UUID, andTaskIndex taskIndex: Int, to isCompleted: Bool, completion: @escaping ((any Error)?) -> Void) {
    }
    
    func saveQuest(_ quest: Quest, withTasks taskTitles: [String], completion: @escaping ((any Error)?) -> Void) {
    }
    
    func updateQuest(withId id: UUID, title: String?, isMainQuest: Bool?, info: String?, difficulty: Int?, dueDate: Date?, isActive: Bool?, progress: Int?, completion: @escaping ((any Error)?) -> Void) {
    }
    
    func fetchCompletedQuests(completion: @escaping ([Quest], (any Error)?) -> Void) {
    }
    
    func fetchNonCompletedQuests(completion: @escaping ([Quest], (any Error)?) -> Void) {
    }
    
    func fetchQuestById(_ id: UUID, completion: @escaping (Quest?, (any Error)?) -> Void) {
    }
    
    func updateQuestCompletion(forId id: UUID, to isCompleted: Bool, completion: @escaping ((any Error)?) -> Void) {
        // TODO: Implement Firebase quest completion update with completionDate
        // When implementing, set completionDate to Date() when isCompleted is true
        // and set it to nil when isCompleted is false
        completion(nil)
    }
    
    func deleteQuest(withId id: UUID, completion: @escaping ((any Error)?) -> Void) {
    }
    
    
    func fetchAllQuests(completion: @escaping ([Quest], (any Error)?) -> Void) {
    }
}
