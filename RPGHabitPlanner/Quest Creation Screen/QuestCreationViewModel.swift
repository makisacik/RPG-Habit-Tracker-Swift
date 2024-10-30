//
//  QuestCreationViewModel.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 28.10.2024.
//

import Foundation
import CoreData

final class QuestCreationViewModel {
    func createQuest(title: String, isMainQuest: Bool, info: String, difficulty: Int, creationDate: Date, dueDate: Date, completion: @escaping (Error?) -> Void) {
        completion(nil)
    }
}
