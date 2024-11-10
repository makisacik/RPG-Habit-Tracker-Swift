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
    func deleteQuest(withId id: UUID, completion: @escaping (Error?) -> Void)
}
