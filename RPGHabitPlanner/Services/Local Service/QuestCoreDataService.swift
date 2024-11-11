//
//  QuestCoreDataService.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 30.10.2024.
//

import Foundation
import CoreData

final class QuestCoreDataService: QuestDataServiceProtocol {
    private let persistentContainer: NSPersistentContainer

    init(container: NSPersistentContainer = PersistenceController.shared.container) {
        self.persistentContainer = container
    }

    func saveQuest(_ quest: Quest, completion: @escaping (Error?) -> Void) {
        let context = persistentContainer.viewContext
        let questEntity = QuestEntity(context: context)
        questEntity.id = quest.id
        questEntity.title = quest.title
        questEntity.isMainQuest = quest.isMainQuest
        questEntity.info = quest.info
        questEntity.difficulty = Int16(quest.difficulty)
        questEntity.creationDate = quest.creationDate
        questEntity.dueDate = quest.dueDate
        questEntity.isActive = quest.isActive
        
        do {
            try context.save()
            completion(nil)
        } catch {
            completion(error)
        }
    }

    func fetchAllQuests(completion: @escaping ([Quest], Error?) -> Void) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<QuestEntity> = QuestEntity.fetchRequest()

        do {
            let questEntities = try context.fetch(fetchRequest)
            let quests: [Quest] = questEntities.map { entity in
                Quest(
                    title: entity.title ?? "",
                    isMainQuest: entity.isMainQuest,
                    info: entity.info ?? "",
                    difficulty: Int(entity.difficulty),
                    creationDate: entity.creationDate ?? Date(),
                    dueDate: entity.dueDate ?? Date(),
                    isActive: true
                )
            }
            completion(quests, nil)
        } catch {
            completion([], error)
        }
    }

    func deleteQuest(withId id: UUID, completion: @escaping (Error?) -> Void) { // New function
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<QuestEntity> = QuestEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            if let questEntity = try context.fetch(fetchRequest).first {
                context.delete(questEntity)
                try context.save()
                completion(nil)
            } else {
                completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Quest not found"]))
            }
        } catch {
            completion(error)
        }
    }
}
