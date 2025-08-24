//
//  DamageEventEntity+CoreDataProperties.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import Foundation
import CoreData

extension DamageEventEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<DamageEventEntity> {
        return NSFetchRequest<DamageEventEntity>(entityName: "DamageEventEntity")
    }

    @NSManaged public var damageAmount: Int32
    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var reason: String?
    @NSManaged public var tracker: QuestDamageTrackerEntity?
}

extension DamageEventEntity: Identifiable {
}
