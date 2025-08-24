//
//  QuestDamageTrackerEntity+CoreDataProperties.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import Foundation
import CoreData

extension QuestDamageTrackerEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<QuestDamageTrackerEntity> {
        return NSFetchRequest<QuestDamageTrackerEntity>(entityName: "QuestDamageTrackerEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var isActive: Bool
    @NSManaged public var lastDamageCheckDate: Date?
    @NSManaged public var questId: UUID?
    @NSManaged public var totalDamageTaken: Int32
    @NSManaged public var damageHistory: NSSet?
}

extension QuestDamageTrackerEntity: Identifiable {
}

// MARK: - Generated accessors for damageHistory
extension QuestDamageTrackerEntity {
    @objc(addDamageHistoryObject:)
    @NSManaged public func addToDamageHistory(_ value: DamageEventEntity)

    @objc(removeDamageHistoryObject:)
    @NSManaged public func removeFromDamageHistory(_ value: DamageEventEntity)

    @objc(addDamageHistory:)
    @NSManaged public func addToDamageHistory(_ values: NSSet)

    @objc(removeDamageHistory:)
    @NSManaged public func removeFromDamageHistory(_ values: NSSet)
}
