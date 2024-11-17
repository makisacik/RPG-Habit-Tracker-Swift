//
//  QuestFirebaseService.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 30.10.2024.
//

import Foundation

final class QuestFirebaseService: QuestDataServiceProtocol {
    func updateQuestCompletion(forId id: UUID, to isCompleted: Bool, completion: @escaping ((any Error)?) -> Void) {
    }
    
    func deleteQuest(withId id: UUID, completion: @escaping ((any Error)?) -> Void) {
    }
    
    func saveQuest(_ quest: Quest, completion: @escaping ((any Error)?) -> Void) {
    }
    
    func fetchAllQuests(completion: @escaping ([Quest], (any Error)?) -> Void) {
    }
}
