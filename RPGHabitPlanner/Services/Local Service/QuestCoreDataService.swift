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

    func saveQuest(_ quest: Quest, withTasks taskTitles: [String], completion: @escaping (Error?) -> Void) {
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
        questEntity.progress = Int16(quest.progress)

        let trimmedTasks = taskTitles.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                                     .filter { !$0.isEmpty }

        if !trimmedTasks.isEmpty {
            let taskEntities: [TaskEntity] = trimmedTasks.enumerated().map { index, title in
                let task = TaskEntity(context: context)
                task.id = UUID()
                task.title = title
                task.isCompleted = false
                task.order = Int16(index)
                task.quest = questEntity
                return task
            }
            questEntity.tasks = NSOrderedSet(array: taskEntities)
        }

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
                    progress: Int(entity.progress),
                    isCompleted: entity.isCompleted,
                    tasks: entity.taskList
                        .sorted { $0.order < $1.order }
                        .map { QuestTask(entity: $0) },
                    repeatType: QuestRepeatType(rawValue: entity.repeatType) ?? .oneTime,
                    repeatIntervalWeeks: entity.repeatIntervalWeeks > 0 ? Int(entity.repeatIntervalWeeks) : nil
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
                    progress: Int(entity.progress),
                    isCompleted: entity.isCompleted,
                    tasks: entity.taskList
                        .sorted { $0.order < $1.order }
                        .map { QuestTask(entity: $0) },
                    repeatType: QuestRepeatType(rawValue: entity.repeatType) ?? .oneTime,
                    repeatIntervalWeeks: entity.repeatIntervalWeeks > 0 ? Int(entity.repeatIntervalWeeks) : nil
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
                    progress: Int(entity.progress),
                    isCompleted: entity.isCompleted,
                    tasks: entity.taskList
                        .sorted { $0.order < $1.order }
                        .map { QuestTask(entity: $0) },
                    repeatType: QuestRepeatType(rawValue: entity.repeatType) ?? .oneTime,
                    repeatIntervalWeeks: entity.repeatIntervalWeeks > 0 ? Int(entity.repeatIntervalWeeks) : nil
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
                    progress: Int(questEntity.progress),
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
        info: String?,
        difficulty: Int?,
        dueDate: Date?,
        isActive: Bool?,
        progress: Int?,
        completion: @escaping (Error?) -> Void
        ) {
            let context = persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<QuestEntity> = QuestEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

            do {
                if let questEntity = try context.fetch(fetchRequest).first {
                    if let title {
                        questEntity.title = title
                    }
                    if let isMainQuest {
                        questEntity.isMainQuest = isMainQuest
                    }
                    if let info {
                        questEntity.info = info
                    }
                    if let difficulty {
                        questEntity.difficulty = Int16(difficulty)
                    }
                    if let dueDate {
                        questEntity.dueDate = dueDate
                    }
                    if let isActive {
                        questEntity.isActive = isActive
                    }
                    
                    if let progress {
                        questEntity.progress = Int16(progress)
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
    
        func updateTask(
            withId id: UUID,
            title: String? = nil,
            isCompleted: Bool? = nil,
            order: Int16? = nil,
            questId: UUID? = nil,
            completion: @escaping (Error?) -> Void
        ) {
            let context = persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

            do {
                if let taskEntity = try context.fetch(fetchRequest).first {
                    if let title {
                        taskEntity.title = title
                    }
                    if let isCompleted {
                        taskEntity.isCompleted = isCompleted
                    }
                    if let order {
                        taskEntity.order = order
                    }
                    if let questId {
                        let questFetch: NSFetchRequest<QuestEntity> = QuestEntity.fetchRequest()
                        questFetch.predicate = NSPredicate(format: "id == %@", questId as CVarArg)
                        if let questEntity = try context.fetch(questFetch).first {
                            taskEntity.quest = questEntity
                        } else {
                            completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Quest not found for reassignment"]))
                            return
                        }
                    }

                    try context.save()
                    completion(nil)
                } else {
                    completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Task not found"]))
                }
            } catch {
                completion(error)
            }
        }
}
