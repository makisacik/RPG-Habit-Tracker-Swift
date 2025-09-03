//
//  QuestDataService.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 30.10.2024.
//

import Foundation

protocol QuestDataServiceProtocol {
    func saveQuest(_ quest: Quest, withTasks taskTitles: [String], completion: @escaping (Error?) -> Void)
    func fetchAllQuests(completion: @escaping ([Quest], Error?) -> Void)
    func fetchNonCompletedQuests(completion: @escaping ([Quest], Error?) -> Void)
    func fetchCompletedQuests(completion: @escaping ([Quest], Error?) -> Void)
    func fetchFinishedQuests(completion: @escaping ([Quest], Error?) -> Void)
    func fetchQuestById(_ id: UUID, completion: @escaping (Quest?, Error?) -> Void)
    func deleteQuest(withId id: UUID, completion: @escaping (Error?) -> Void)

    func updateQuestCompletion(forId id: UUID, to isCompleted: Bool, completion: @escaping (Error?) -> Void)
    func updateQuestProgress(withId id: UUID, progress: Int, completion: @escaping (Error?) -> Void)
    func markQuestAsFinished(forId id: UUID, completion: @escaping (Error?) -> Void)
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
    )

    func updateTask(
        withId id: UUID,
        title: String?,
        isCompleted: Bool?,
        order: Int16?,
        questId: UUID?,
        completion: @escaping (Error?) -> Void
    )

    func markQuestCompleted(forId id: UUID, on date: Date, completion: @escaping (Error?) -> Void)
    func unmarkQuestCompleted(forId id: UUID, on date: Date, completion: @escaping (Error?) -> Void)
    func isQuestCompleted(forId id: UUID, on date: Date, completion: @escaping (Bool, Error?) -> Void)
    func questCompletionCount(forId id: UUID, from startDate: Date, to endDate: Date, completion: @escaping (Int, Error?) -> Void)
    func questCompletionDates(forId id: UUID, from startDate: Date, to endDate: Date, completion: @escaping ([Date], Error?) -> Void)
    func questCurrentStreak(forId id: UUID, asOf date: Date, completion: @escaping (Int, Error?) -> Void)

    func refreshQuestState(forId id: UUID, on date: Date, completion: @escaping (Error?) -> Void)
    func refreshAllQuests(on date: Date, completion: @escaping (Error?) -> Void)
}

extension QuestDataServiceProtocol {
    func updateTask(
        withId id: UUID,
        isCompleted: Bool,
        completion: @escaping (Error?) -> Void
    ) {
        updateTask(
            withId: id,
            title: nil,
            isCompleted: isCompleted,
            order: nil,
            questId: nil,
            completion: completion
        )
    }
}
