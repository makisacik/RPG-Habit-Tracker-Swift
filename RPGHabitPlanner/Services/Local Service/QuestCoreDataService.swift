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
        questEntity.isCompleted = quest.isCompleted
        
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
                    id: entity.id ?? UUID(),
                    title: entity.title ?? "",
                    isMainQuest: entity.isMainQuest,
                    info: entity.info ?? "",
                    difficulty: Int(entity.difficulty),
                    creationDate: entity.creationDate ?? Date(),
                    dueDate: entity.dueDate ?? Date(),
                    isActive: entity.isActive,
                    isCompleted: entity.isCompleted
                )
            }
            completion(quests, nil)
        } catch {
            completion([], error)
        }
    }
    
    func fetchCompletedQuests(completion: @escaping ([Quest], Error?) -> Void) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<QuestEntity> = QuestEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isCompleted == YES")
        
        do {
            let questEntities = try context.fetch(fetchRequest)
            let quests: [Quest] = questEntities.map { entity in
                Quest(
                    id: entity.id ?? UUID(),
                    title: entity.title ?? "",
                    isMainQuest: entity.isMainQuest,
                    info: entity.info ?? "",
                    difficulty: Int(entity.difficulty),
                    creationDate: entity.creationDate ?? Date(),
                    dueDate: entity.dueDate ?? Date(),
                    isActive: entity.isActive,
                    isCompleted: entity.isCompleted
                )
            }
            completion(quests, nil)
        } catch {
            completion([], error)
        }
    }

    
    func fetchNonCompletedQuests(completion: @escaping ([Quest], Error?) -> Void) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<QuestEntity> = QuestEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isCompleted == NO")

        do {
            let questEntities = try context.fetch(fetchRequest)
            let quests: [Quest] = questEntities.map { entity in
                Quest(
                    id: entity.id ?? UUID(),
                    title: entity.title ?? "",
                    isMainQuest: entity.isMainQuest,
                    info: entity.info ?? "",
                    difficulty: Int(entity.difficulty),
                    creationDate: entity.creationDate ?? Date(),
                    dueDate: entity.dueDate ?? Date(),
                    isActive: entity.isActive,
                    isCompleted: entity.isCompleted
                )
            }
            completion(quests, nil)
        } catch {
            completion([], error)
        }
    }

    
    func fetchQuestById(_ id: UUID, completion: @escaping (Quest?, Error?) -> Void) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<QuestEntity> = QuestEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            if let questEntity = try context.fetch(fetchRequest).first {
                let quest = Quest(
                    id: questEntity.id ?? UUID(),
                    title: questEntity.title ?? "",
                    isMainQuest: questEntity.isMainQuest,
                    info: questEntity.info ?? "",
                    difficulty: Int(questEntity.difficulty),
                    creationDate: questEntity.creationDate ?? Date(),
                    dueDate: questEntity.dueDate ?? Date(),
                    isActive: questEntity.isActive,
                    isCompleted: questEntity.isCompleted
                )
                completion(quest, nil)
            } else {
                completion(nil, NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Quest not found"]))
            }
        } catch {
            completion(nil, error)
        }
    }

    func deleteQuest(withId id: UUID, completion: @escaping (Error?) -> Void) {
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

    func updateQuestCompletion(forId id: UUID, to isCompleted: Bool, completion: @escaping (Error?) -> Void) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<QuestEntity> = QuestEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            if let questEntity = try context.fetch(fetchRequest).first {
                questEntity.isCompleted = isCompleted
                try context.save()
                completion(nil)
            } else {
                completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Quest not found"]))
            }
        } catch {
            completion(error)
        }
    }
    
    func updateQuest(
            withId id: UUID,
            title: String?,
            isMainQuest: Bool?,
            difficulty: Int?,
            dueDate: Date?,
            isActive: Bool?,
            completion: @escaping (Error?) -> Void
        ) {
            let context = persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<QuestEntity> = QuestEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

            do {
                if let questEntity = try context.fetch(fetchRequest).first {
                    if let title = title {
                        questEntity.title = title
                    }
                    if let isMainQuest = isMainQuest {
                        questEntity.isMainQuest = isMainQuest
                    }
                    if let difficulty = difficulty {
                        questEntity.difficulty = Int16(difficulty)
                    }
                    if let dueDate = dueDate {
                        questEntity.dueDate = dueDate
                    }
                    if let isActive = isActive {
                        questEntity.isActive = isActive
                    }

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
