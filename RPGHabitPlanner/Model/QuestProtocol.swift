//
//  QuestProtocol.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 30.10.2024.
//

import Foundation

protocol QuestProtocol {
    var title: String { get }
    var isMainQuest: Bool { get }
    var info: String { get }
    var difficulty: Int { get }
    var creationDate: Date { get }
    var dueDate: Date { get }
}
