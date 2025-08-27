//
//  TagEntity+CoreDataProperties.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 14.08.2025.
//
//

import Foundation
import CoreData

extension TagEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TagEntity> {
        NSFetchRequest<TagEntity>(entityName: "TagEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var nameNormalized: String?
    @NSManaged public var icon: String?
    @NSManaged public var color: String?
    @NSManaged public var quests: NSSet?
}

extension TagEntity {
    @objc(addQuestsObject:)
    @NSManaged public func addToQuests(_ value: QuestEntity)

    @objc(removeQuestsObject:)
    @NSManaged public func removeFromQuests(_ value: QuestEntity)

    @objc(addQuests:)
    @NSManaged public func addToQuests(_ values: NSSet)

    @objc(removeQuests:)
    @NSManaged public func removeFromQuests(_ values: NSSet)
}

extension TagEntity: Identifiable {
    var questList: [QuestEntity] {
        guard let quests = quests,
              let array = quests.allObjects as? [QuestEntity] else {
            return []
        }
        return array
    }
}
