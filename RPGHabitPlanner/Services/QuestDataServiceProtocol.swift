//
//  QuestDataService.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 30.10.2024.
//

import Foundation

protocol QuestDataServiceProtocol {
    func saveQuest(_ quest: Quest, completion: @escaping (Error?) -> Void)
    func fetchAllQuests(completion: @escaping ([Quest], Error?) -> Void)
    func fetchNonCompletedQuests(completion: @escaping ([Quest], Error?) -> Void)
    func fetchCompletedQuests(completion: @escaping ([Quest], Error?) -> Void)
    func deleteQuest(withId id: UUID, completion: @escaping (Error?) -> Void)
    func updateQuestCompletion(forId id: UUID, to isCompleted: Bool, completion: @escaping (Error?) -> Void)
    func fetchQuestById(_ id: UUID, completion: @escaping (Quest?, Error?) -> Void)
    func updateQuest(withId id: UUID, title: String?, isMainQuest: Bool?, info: String?, difficulty: Int?, dueDate: Date?, isActive: Bool?, progress: Int?, completion: @escaping (Error?) -> Void)
}
