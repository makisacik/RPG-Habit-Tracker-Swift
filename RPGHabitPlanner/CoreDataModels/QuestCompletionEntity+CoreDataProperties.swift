//
//  QuestCompletionEntity+CoreDataProperties.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 9.08.2025.
//

import Foundation
import CoreData

extension QuestCompletionEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<QuestCompletionEntity> {
        NSFetchRequest<QuestCompletionEntity>(entityName: "QuestCompletionEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var quest: QuestEntity?
}

extension QuestCompletionEntity: Identifiable {}
