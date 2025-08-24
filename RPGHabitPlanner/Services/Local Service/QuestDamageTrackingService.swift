//
//  QuestDamageTrackingService.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import Foundation
import CoreData

final class QuestDamageTrackingService {
    static let shared = QuestDamageTrackingService()
    private let persistentContainer: NSPersistentContainer
    
    private init(container: NSPersistentContainer = PersistenceController.shared.container) {
        self.persistentContainer = container
    }
    
    // MARK: - Quest Damage Tracker Management
    
    func createOrUpdateDamageTracker(
        for questId: UUID,
        lastDamageCheckDate: Date,
        totalDamageTaken: Int = 0,
        isActive: Bool = true,
        completion: @escaping (QuestDamageTracker?, Error?) -> Void
    ) {
        let context = persistentContainer.viewContext
        
        // Check if tracker already exists
        let fetchRequest: NSFetchRequest<QuestDamageTrackerEntity> = QuestDamageTrackerEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "questId == %@", questId as CVarArg)
        
        do {
            let existingTrackers = try context.fetch(fetchRequest)
            
            if let existingTracker = existingTrackers.first {
                // Update existing tracker
                existingTracker.lastDamageCheckDate = lastDamageCheckDate
                existingTracker.totalDamageTaken = Int32(totalDamageTaken)
                existingTracker.isActive = isActive
            } else {
                // Create new tracker
                let trackerEntity = QuestDamageTrackerEntity(context: context)
                trackerEntity.id = UUID()
                trackerEntity.questId = questId
                trackerEntity.lastDamageCheckDate = lastDamageCheckDate
                trackerEntity.totalDamageTaken = Int32(totalDamageTaken)
                trackerEntity.isActive = isActive
            }
            
            try context.save()
            
            // Fetch and return the updated tracker
            fetchDamageTracker(for: questId, completion: completion)
        } catch {
            completion(nil, error)
        }
    }
    
    func fetchDamageTracker(
        for questId: UUID,
        completion: @escaping (QuestDamageTracker?, Error?) -> Void
    ) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<QuestDamageTrackerEntity> = QuestDamageTrackerEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "questId == %@", questId as CVarArg)
        
        do {
            let trackerEntities = try context.fetch(fetchRequest)
            
            if let trackerEntity = trackerEntities.first {
                let tracker = mapQuestDamageTrackerEntityToModel(trackerEntity)
                completion(tracker, nil)
            } else {
                completion(nil, nil) // No tracker found
            }
        } catch {
            completion(nil, error)
        }
    }
    
    func fetchAllActiveDamageTrackers(
        completion: @escaping ([QuestDamageTracker], Error?) -> Void
    ) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<QuestDamageTrackerEntity> = QuestDamageTrackerEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isActive == YES")
        
        do {
            let trackerEntities = try context.fetch(fetchRequest)
            let trackers = trackerEntities.map { mapQuestDamageTrackerEntityToModel($0) }
            completion(trackers, nil)
        } catch {
            completion([], error)
        }
    }
    
    func updateDamageTracker(
        _ tracker: QuestDamageTracker,
        completion: @escaping (Error?) -> Void
    ) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<QuestDamageTrackerEntity> = QuestDamageTrackerEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        do {
            let trackerEntities = try context.fetch(fetchRequest)
            
            if let trackerEntity = trackerEntities.first {
                trackerEntity.lastDamageCheckDate = tracker.lastDamageCheckDate
                trackerEntity.totalDamageTaken = Int32(tracker.totalDamageTaken)
                trackerEntity.isActive = tracker.isActive
                
                try context.save()
                completion(nil)
            } else {
                completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Damage tracker not found"]))
            }
        } catch {
            completion(error)
        }
    }
    
    func deactivateDamageTracker(
        for questId: UUID,
        completion: @escaping (Error?) -> Void
    ) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<QuestDamageTrackerEntity> = QuestDamageTrackerEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "questId == %@", questId as CVarArg)
        
        do {
            let trackerEntities = try context.fetch(fetchRequest)
            
            if let trackerEntity = trackerEntities.first {
                trackerEntity.isActive = false
                try context.save()
                completion(nil)
            } else {
                completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Damage tracker not found"]))
            }
        } catch {
            completion(error)
        }
    }
    
    func deleteDamageTracker(
        for questId: UUID,
        completion: @escaping (Error?) -> Void
    ) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<QuestDamageTrackerEntity> = QuestDamageTrackerEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "questId == %@", questId as CVarArg)
        
        do {
            let trackerEntities = try context.fetch(fetchRequest)
            
            for trackerEntity in trackerEntities {
                context.delete(trackerEntity)
            }
            
            try context.save()
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    // MARK: - Damage Event Management
    
    func addDamageEvent(
        to trackerId: UUID,
        damageAmount: Int,
        reason: String,
        date: Date = Date(),
        completion: @escaping (Error?) -> Void
    ) {
        let context = persistentContainer.viewContext
        
        // Find the tracker
        let trackerFetchRequest: NSFetchRequest<QuestDamageTrackerEntity> = QuestDamageTrackerEntity.fetchRequest()
        trackerFetchRequest.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg)
        
        do {
            let trackerEntities = try context.fetch(trackerFetchRequest)
            
            guard let trackerEntity = trackerEntities.first else {
                completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Damage tracker not found"]))
                return
            }
            
            // Create damage event
            let damageEventEntity = DamageEventEntity(context: context)
            damageEventEntity.id = UUID()
            damageEventEntity.date = date
            damageEventEntity.damageAmount = Int32(damageAmount)
            damageEventEntity.reason = reason
            damageEventEntity.tracker = trackerEntity
            
            // Update tracker's total damage
            trackerEntity.totalDamageTaken += Int32(damageAmount)
            
            try context.save()
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    func fetchDamageEvents(
        for trackerId: UUID,
        completion: @escaping ([DamageEvent], Error?) -> Void
    ) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<DamageEventEntity> = DamageEventEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "tracker.id == %@", trackerId as CVarArg)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let eventEntities = try context.fetch(fetchRequest)
            let events = eventEntities.map { mapDamageEventEntityToModel($0) }
            completion(events, nil)
        } catch {
            completion([], error)
        }
    }
    
    // MARK: - Mapping Methods
    
    private func mapQuestDamageTrackerEntityToModel(_ entity: QuestDamageTrackerEntity) -> QuestDamageTracker {
        let damageHistory = (entity.damageHistory?.allObjects as? [DamageEventEntity])?.map { mapDamageEventEntityToModel($0) } ?? []
        
        return QuestDamageTracker(
            id: entity.id ?? UUID(),
            questId: entity.questId ?? UUID(),
            lastDamageCheckDate: entity.lastDamageCheckDate ?? Date(),
            totalDamageTaken: Int(entity.totalDamageTaken),
            damageHistory: damageHistory,
            isActive: entity.isActive
        )
    }
    
    private func mapDamageEventEntityToModel(_ entity: DamageEventEntity) -> DamageEvent {
        return DamageEvent(
            id: entity.id ?? UUID(),
            date: entity.date ?? Date(),
            damageAmount: Int(entity.damageAmount),
            reason: entity.reason ?? "Unknown"
        )
    }
}
