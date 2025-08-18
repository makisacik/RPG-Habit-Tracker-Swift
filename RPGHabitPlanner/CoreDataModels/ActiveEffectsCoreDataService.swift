//
//  ActiveEffectsCoreDataService.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 18.08.2025.
//

import Foundation
import CoreData

protocol ActiveEffectsServiceProtocol {
    func fetchActiveEffects() -> [ActiveEffect]
    func saveActiveEffect(_ effect: ActiveEffect)
    func removeActiveEffect(_ effect: ActiveEffect)
    func clearExpiredEffects()
    func clearAllEffects()
}

final class ActiveEffectsCoreDataService: ActiveEffectsServiceProtocol {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext

    init(container: NSPersistentContainer = PersistenceController.shared.container) {
        self.container = container
        self.context = container.viewContext
    }

    func fetchActiveEffects() -> [ActiveEffect] {
        let request: NSFetchRequest<ActiveEffectEntity> = ActiveEffectEntity.fetchRequest()
        
        // Only fetch non-expired effects
        let now = Date()
        request.predicate = NSPredicate(format: "endTime == nil OR endTime > %@", now as NSDate)
        
        do {
            let entities = try context.fetch(request)
            let effects = entities.compactMap { $0.toActiveEffect() }
            print("💾 ActiveEffectsCoreDataService: Fetched \(effects.count) active effects")
            return effects
        } catch {
            print("❌ ActiveEffectsCoreDataService: Error fetching active effects: \(error)")
            return []
        }
    }

    func saveActiveEffect(_ effect: ActiveEffect) {
        let entity = ActiveEffectEntity(context: context)
        entity.updateFromActiveEffect(effect)
        
        do {
            try context.save()
            print("💾 ActiveEffectsCoreDataService: Saved active effect \(effect.effect.type.rawValue)")
        } catch {
            print("❌ ActiveEffectsCoreDataService: Error saving active effect: \(error)")
        }
    }

    func removeActiveEffect(_ effect: ActiveEffect) {
        let request: NSFetchRequest<ActiveEffectEntity> = ActiveEffectEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", effect.id as CVarArg)
        
        do {
            let entities = try context.fetch(request)
            entities.forEach { context.delete($0) }
            try context.save()
            print("💾 ActiveEffectsCoreDataService: Removed active effect")
        } catch {
            print("❌ ActiveEffectsCoreDataService: Error removing active effect: \(error)")
        }
    }

    func clearExpiredEffects() {
        let request: NSFetchRequest<ActiveEffectEntity> = ActiveEffectEntity.fetchRequest()
        let now = Date()
        request.predicate = NSPredicate(format: "endTime != nil AND endTime <= %@", now as NSDate)
        
        do {
            let expiredEntities = try context.fetch(request)
            let expiredCount = expiredEntities.count
            
            expiredEntities.forEach { context.delete($0) }
            try context.save()
            
            if expiredCount > 0 {
                print("💾 ActiveEffectsCoreDataService: Removed \(expiredCount) expired effects")
            }
        } catch {
            print("❌ ActiveEffectsCoreDataService: Error clearing expired effects: \(error)")
        }
    }

    func clearAllEffects() {
        let request: NSFetchRequest<NSFetchRequestResult> = ActiveEffectEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
            print("💾 ActiveEffectsCoreDataService: Cleared all active effects")
        } catch {
            print("❌ ActiveEffectsCoreDataService: Error clearing all effects: \(error)")
        }
    }
}
