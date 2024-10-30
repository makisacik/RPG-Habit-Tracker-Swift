//
//  QuestDataService.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 30.10.2024.
//

import Foundation

protocol QuestDataService {
    func saveQuest(_ quest: QuestProtocol, completion: @escaping (Error?) -> ())
    func fetchAllQuests(completion: @escaping ([QuestProtocol], Error?) -> ())
}
