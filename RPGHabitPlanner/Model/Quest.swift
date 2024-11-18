//
//  QuestProtocol.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 30.10.2024.
//

import Foundation

struct Quest: Identifiable, Equatable {
    let id: UUID
    var title: String
    var isMainQuest: Bool
    var info: String
    var difficulty: Int
    let creationDate: Date
    var dueDate: Date
    var isActive: Bool
    var isCompleted = false
    
    init(id: UUID = UUID(), title: String, isMainQuest: Bool, info: String, difficulty: Int, creationDate: Date, dueDate: Date, isActive: Bool, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isMainQuest = isMainQuest
        self.info = info
        self.difficulty = difficulty
        self.creationDate = creationDate
        self.dueDate = dueDate
        self.isActive = isActive
        self.isCompleted = isCompleted
    }
}
