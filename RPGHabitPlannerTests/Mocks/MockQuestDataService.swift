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
    
    func updateQuest(withId id: UUID,
                     title: String?,
                     isMainQuest: Bool?,
                     info: String?,
                     difficulty: Int?,
                     dueDate: Date?,
                     isActive: Bool?,
                     progress: Int?,
                     completion: @escaping ((Error?) -> Void)) {
        if let error = mockError {
            completion(error)
            return
        }
        
        guard let index = mockQuests.firstIndex(where: { $0.id == id }) else {
            completion(NSError(domain: "MockQuestDataService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Quest not found"]))
            return
        }
        
        // Update fields using nil coalescing and optional binding for clarity
        if let title = title { mockQuests[index].title = title }
        if let isMainQuest = isMainQuest { mockQuests[index].isMainQuest = isMainQuest }
        if let info = info { mockQuests[index].info = info }
        if let difficulty = difficulty { mockQuests[index].difficulty = difficulty }
        if let dueDate = dueDate { mockQuests[index].dueDate = dueDate }
        if let isActive = isActive { mockQuests[index].isActive = isActive }
        if let progress = progress { mockQuests[index].progress = progress }
        
        completion(nil)
    }
}
