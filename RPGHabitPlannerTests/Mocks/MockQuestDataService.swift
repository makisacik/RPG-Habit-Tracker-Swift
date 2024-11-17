//
//  MockQuestDataService.swift
//  RPGHabitPlannerTests
//
//  Created by Mehmet Ali Kısacık on 16.11.2024.
//

import Foundation
@testable import RPGHabitPlanner

class MockQuestDataService: QuestDataServiceProtocol {
    var mockQuests: [Quest] = []
    var mockError: Error?

    func saveQuest(_ quest: Quest, completion: @escaping (Error?) -> Void) {
        if let error = mockError {
            completion(error)
        } else {
            mockQuests.append(quest)
            completion(nil)
        }
    }

    func fetchAllQuests(completion: @escaping ([Quest], Error?) -> Void) {
        if let error = mockError {
            completion([], error)
        } else {
            completion(mockQuests, nil)
        }
    }

    func deleteQuest(withId id: UUID, completion: @escaping (Error?) -> Void) {
        if let error = mockError {
            completion(error)
        } else {
            mockQuests.removeAll { $0.id == id }
            completion(nil)
        }
    }
    
    func updateQuestCompletion(forId id: UUID, to isCompleted: Bool, completion: @escaping ((any Error)?) -> Void) {
    }
}
