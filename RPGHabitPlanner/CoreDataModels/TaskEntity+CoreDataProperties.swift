//
//  TaskEntity+CoreDataProperties.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 27.07.2025.
//
//

import Foundation
import CoreData


extension TaskEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskEntity> {
        return NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var order: Int16
    @NSManaged public var quest: QuestEntity?
}

extension TaskEntity: Identifiable {
}
