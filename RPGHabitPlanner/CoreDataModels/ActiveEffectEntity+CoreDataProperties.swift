//
//  ActiveEffectEntity+CoreDataProperties.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 18.08.2025.
//

import Foundation
import CoreData

extension ActiveEffectEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ActiveEffectEntity> {
        return NSFetchRequest<ActiveEffectEntity>(entityName: "ActiveEffectEntity")
    }

    @NSManaged public var effectType: String?
    @NSManaged public var effectValue: Int32
    @NSManaged public var endTime: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var isPercentage: Bool
    @NSManaged public var sourceItemId: UUID?
    @NSManaged public var startTime: Date?
}

extension ActiveEffectEntity: Identifiable {
}

// MARK: - Conversion Methods

extension ActiveEffectEntity {
    func toActiveEffect() -> ActiveEffect? {
        guard let id = id,
              let effectTypeString = effectType,
              let effectType = ItemEffect.EffectType(rawValue: effectTypeString),
              let startTime = startTime,
              let sourceItemId = sourceItemId else {
            return nil
        }
        
        let effect = ItemEffect(
            type: effectType,
            value: Int(effectValue),
            duration: nil, // Duration is calculated from startTime and endTime
            isPercentage: isPercentage
        )
        
        // Create ActiveEffect with the persisted ID and times
        return ActiveEffect(
            id: id,
            effect: effect,
            startTime: startTime,
            endTime: endTime,
            sourceItemId: sourceItemId
        )
    }
    
    func updateFromActiveEffect(_ activeEffect: ActiveEffect) {
        self.id = activeEffect.id
        self.effectType = activeEffect.effect.type.rawValue
        self.effectValue = Int32(activeEffect.effect.value)
        self.isPercentage = activeEffect.effect.isPercentage
        self.startTime = activeEffect.startTime
        self.endTime = activeEffect.endTime
        self.sourceItemId = activeEffect.sourceItemId
    }
}
