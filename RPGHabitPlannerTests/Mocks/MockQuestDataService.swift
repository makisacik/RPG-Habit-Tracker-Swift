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

    func fetchNonCompletedQuests(completion: @escaping ([Quest], Error?) -> Void) {
        if let error = mockError {
            completion([], error)
        } else {
            completion(mockQuests, nil)
        }
    }

    func fetchCompletedQuests(completion: @escaping ([Quest], Error?) -> Void) {
        if let error = mockError {
            completion([], error)
        } else {
            completion(mockQuests, nil)
        }
    }

    func fetchQuestById(_ id: UUID, completion: @escaping (Quest?, Error?) -> Void) {
        if let error = mockError {
            completion(nil, error)
        } else {
            let quest = mockQuests.first { $0.id == id }
            completion(quest, nil)
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

    func updateQuestCompletion(forId id: UUID, to isCompleted: Bool, completion: @escaping (Error?) -> Void) {
        if let error = mockError {
            completion(error)
        } else {
            if let index = mockQuests.firstIndex(where: { $0.id == id }) {
                mockQuests[index].isActive = isCompleted
                completion(nil)
            } else {
                completion(NSError(domain: "MockQuestDataService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Quest not found"]))
            }
        }
    }
    
    func updateQuest(withId id: UUID, title: String?, isMainQuest: Bool?, difficulty: Int?, dueDate: Date?, isActive: Bool?, completion: @escaping ((any Error)?) -> Void) {
    }
}
