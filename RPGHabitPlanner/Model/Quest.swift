//
//  QuestProtocol.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 30.10.2024.
//

import Foundation

struct Quest: Identifiable {
    let id = UUID()
    let title: String
    let isMainQuest: Bool
    let info: String
    let difficulty: Int
    let creationDate: Date
    let dueDate: Date
    let isActive: Bool
}
