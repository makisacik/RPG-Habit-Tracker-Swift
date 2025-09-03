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
    @NSManaged public var scheduledDays: String?
    @NSManaged public var completionDate: Date?
    @NSManaged public var completions: NSSet?
    @NSManaged public var tags: NSSet?
    @NSManaged public var showProgress: Bool
    @NSManaged public var reminderTimes: String? // Stored as comma-separated ISO date strings
    @NSManaged public var enableReminders: Bool
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

extension QuestEntity {
    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: TagEntity)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: TagEntity)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)
}

extension QuestEntity: Identifiable {
    var taskList: [TaskEntity] {
        guard let tasks = tasks,
              let array = tasks.array as? [TaskEntity] else {
            return []
        }
        return array
    }
    var completionList: [QuestCompletionEntity] {
        guard let completions = completions,
              let array = completions.allObjects as? [QuestCompletionEntity] else {
            return []
        }
        return array
    }
    var tagList: [TagEntity] {
        guard let tags = tags,
              let array = tags.allObjects as? [TagEntity] else {
            return []
        }
        return array
    }
}
