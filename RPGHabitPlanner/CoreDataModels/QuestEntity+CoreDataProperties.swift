//
//  QuestEntity+CoreDataProperties.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 27.07.2025.
//
//

import Foundation
import CoreData

extension QuestEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<QuestEntity> {
        NSFetchRequest<QuestEntity>(entityName: "QuestEntity")
    }

    @NSManaged public var creationDate: Date?
    @NSManaged public var difficulty: Int16
    @NSManaged public var dueDate: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var info: String?
    @NSManaged public var isActive: Bool
    @NSManaged public var isCompleted: Bool
    @NSManaged public var isFinished: Bool
    @NSManaged public var isFinishedDate: Date?
    @NSManaged public var isMainQuest: Bool
    @NSManaged public var progress: Int16
    @NSManaged public var title: String?
    @NSManaged public var tasks: NSOrderedSet?
    @NSManaged public var repeatType: String
    @NSManaged public var completionDate: Date?
    @NSManaged public var completions: NSSet?
}

extension QuestEntity {
    @objc(addCompletionsObject:)
    @NSManaged public func addToCompletions(_ value: QuestCompletionEntity)

    @objc(removeCompletionsObject:)
    @NSManaged public func removeFromCompletions(_ value: QuestCompletionEntity)

    @objc(addCompletions:)
    @NSManaged public func addToCompletions(_ values: NSSet)

    @objc(removeCompletions:)
    @NSManaged public func removeFromCompletions(_ values: NSSet)
}

extension QuestEntity: Identifiable {
    var taskList: [TaskEntity] {
        (tasks?.array as? [TaskEntity]) ?? []
    }
    var completionList: [QuestCompletionEntity] {
        (completions?.allObjects as? [QuestCompletionEntity]) ?? []
    }
}
