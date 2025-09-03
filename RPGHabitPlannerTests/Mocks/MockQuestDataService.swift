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
    var shouldMarkQuestAsFinishedSucceed: Bool = true
    var markQuestAsFinishedCalled: Bool = false

    func saveQuest(_ quest: Quest, withTasks taskTitles: [String], completion: @escaping (Error?) -> Void) {
        if let error = mockError {
            completion(error)
        } else {
            mockQuests.append(quest)
            completion(nil)
        }
    }

    func saveQuest(_ quest: Quest, completion: @escaping (Error?) -> Void) {
        saveQuest(quest, withTasks: [], completion: completion)
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

    func updateQuest(
        withId id: UUID,
        title: String?,
        isMainQuest: Bool?,
        info: String?,
        difficulty: Int?,
        dueDate: Date?,
        isActive: Bool?,
        progress: Int?,
        repeatType: QuestRepeatType?,
        tasks: [String]?,
        tags: [Tag]?,
        showProgress: Bool?,
        scheduledDays: Set<Int>?,
        reminderTimes: Set<Date>?,
        enableReminders: Bool?,
        completion: @escaping (Error?) -> Void
    ) {
        if let error = mockError {
            completion(error)
            return
        }

        guard let index = mockQuests.firstIndex(where: { $0.id == id }) else {
            completion(NSError(domain: "MockQuestDataService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Quest not found"]))
            return
        }

        if let title = title { mockQuests[index].title = title }
        if let isMainQuest = isMainQuest { mockQuests[index].isMainQuest = isMainQuest }
        if let info = info { mockQuests[index].info = info }
        if let difficulty = difficulty { mockQuests[index].difficulty = difficulty }
        if let dueDate = dueDate { mockQuests[index].dueDate = dueDate }
        if let isActive = isActive { mockQuests[index].isActive = isActive }
        if let progress = progress { mockQuests[index].progress = max(0, min(100, progress)) } // Ensure progress stays between 0 and 100
        if let showProgress = showProgress { mockQuests[index].showProgress = showProgress }
        if let tags = tags { mockQuests[index].tags = Set(tags) }
        if let scheduledDays = scheduledDays { mockQuests[index].scheduledDays = scheduledDays }
        if let enableReminders = enableReminders { mockQuests[index].enableReminders = enableReminders }
        if let reminderTimes = reminderTimes { mockQuests[index].reminderTimes = reminderTimes }

        completion(nil)
    }

    func updateQuestProgress(withId id: UUID, progress: Int, completion: @escaping (Error?) -> Void) {
        if let error = mockError {
            completion(error)
        } else {
            if let index = mockQuests.firstIndex(where: { $0.id == id }) {
                mockQuests[index].progress = max(0, min(100, progress))
                completion(nil)
            } else {
                completion(NSError(domain: "MockQuestDataService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Quest not found"]))
            }
        }
    }

    func markQuestAsFinished(forId id: UUID, completion: @escaping (Error?) -> Void) {
        markQuestAsFinishedCalled = true

        if let error = mockError {
            completion(error)
        } else if !shouldMarkQuestAsFinishedSucceed {
            completion(NSError(domain: "MockQuestDataService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Mock failure"]))
        } else {
            if let index = mockQuests.firstIndex(where: { $0.id == id }) {
                mockQuests[index].isFinished = true
                mockQuests[index].isFinishedDate = Date()
                completion(nil)
            } else {
                completion(NSError(domain: "MockQuestDataService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Quest not found"]))
            }
        }
    }

    func updateTask(withId id: UUID, title: String?, isCompleted: Bool?, order: Int16?, questId: UUID?, completion: @escaping (Error?) -> Void) {
        if let error = mockError {
            completion(error)
        } else {
            // For simplicity, just update the first quest's tasks
            if let questIndex = mockQuests.firstIndex(where: { $0.id == questId }),
               let taskIndex = mockQuests[questIndex].tasks.firstIndex(where: { $0.id == id }) {
                if let title = title { mockQuests[questIndex].tasks[taskIndex].title = title }
                if let isCompleted = isCompleted { mockQuests[questIndex].tasks[taskIndex].isCompleted = isCompleted }
                if let order = order { mockQuests[questIndex].tasks[taskIndex].order = Int(order) }
                completion(nil)
            } else {
                completion(NSError(domain: "MockQuestDataService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Task not found"]))
            }
        }
    }

    func markQuestCompleted(forId id: UUID, on date: Date, completion: @escaping (Error?) -> Void) {
        if let error = mockError {
            completion(error)
        } else {
            if let index = mockQuests.firstIndex(where: { $0.id == id }) {
                mockQuests[index].completions.insert(date)
                completion(nil)
            } else {
                completion(NSError(domain: "MockQuestDataService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Quest not found"]))
            }
        }
    }

    func unmarkQuestCompleted(forId id: UUID, on date: Date, completion: @escaping (Error?) -> Void) {
        if let error = mockError {
            completion(error)
        } else {
            if let index = mockQuests.firstIndex(where: { $0.id == id }) {
                mockQuests[index].completions.remove(date)
                completion(nil)
            } else {
                completion(NSError(domain: "MockQuestDataService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Quest not found"]))
            }
        }
    }

    func isQuestCompleted(forId id: UUID, on date: Date, completion: @escaping (Bool, Error?) -> Void) {
        if let error = mockError {
            completion(false, error)
        } else {
            if let quest = mockQuests.first(where: { $0.id == id }) {
                let isCompleted = quest.completions.contains(date)
                completion(isCompleted, nil)
            } else {
                completion(false, NSError(domain: "MockQuestDataService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Quest not found"]))
            }
        }
    }

    func questCompletionCount(forId id: UUID, from startDate: Date, to endDate: Date, completion: @escaping (Int, Error?) -> Void) {
        if let error = mockError {
            completion(0, error)
        } else {
            if let quest = mockQuests.first(where: { $0.id == id }) {
                let count = quest.completions.filter { $0 >= startDate && $0 <= endDate }.count
                completion(count, nil)
            } else {
                completion(0, NSError(domain: "MockQuestDataService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Quest not found"]))
            }
        }
    }

    func questCompletionDates(forId id: UUID, from startDate: Date, to endDate: Date, completion: @escaping ([Date], Error?) -> Void) {
        if let error = mockError {
            completion([], error)
        } else {
            if let quest = mockQuests.first(where: { $0.id == id }) {
                let dates = quest.completions.filter { $0 >= startDate && $0 <= endDate }.sorted()
                completion(dates, nil)
            } else {
                completion([], NSError(domain: "MockQuestDataService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Quest not found"]))
            }
        }
    }

    func questCurrentStreak(forId id: UUID, asOf date: Date, completion: @escaping (Int, Error?) -> Void) {
        if let error = mockError {
            completion(0, error)
        } else {
            // Simple implementation - just return a mock streak
            completion(3, nil)
        }
    }

    func refreshQuestState(forId id: UUID, on date: Date, completion: @escaping (Error?) -> Void) {
        completion(nil)
    }

    func refreshAllQuests(on date: Date, completion: @escaping (Error?) -> Void) {
        completion(nil)
    }

    func fetchFinishedQuests(completion: @escaping ([Quest], Error?) -> Void) {
        if let error = mockError {
            completion([], error)
        } else {
            let finishedQuests = mockQuests.filter { $0.isFinished }
            completion(finishedQuests, nil)
        }
    }
}
