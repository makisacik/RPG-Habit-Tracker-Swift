//
//  QuestTask.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 1.08.2025.
//

import Foundation

struct QuestTask: Identifiable, Equatable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var order: Int
}

extension QuestTask {
    init(entity: TaskEntity) {
        self.id = entity.id ?? UUID()
        self.title = entity.title ?? ""
        self.isCompleted = entity.isCompleted
        self.order = Int(entity.order)

        // Debug logging for task loading
        print("📋 Loading task: '\(self.title)' with ID: \(self.id.uuidString), isCompleted: \(self.isCompleted)")
    }
}
