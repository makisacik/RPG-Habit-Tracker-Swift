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
        questEntity.repeatType = quest.repeatType.rawValue
        questEntity.repeatIntervalWeeks = Int16(quest.repeatIntervalWeeks ?? 1)

        let trimmedTasks = taskTitles
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
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
                    completionDate: entity.completionDate,
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
                    completionDate: entity.completionDate,
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
                    completionDate: entity.completionDate,
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
                    isCompleted: questEntity.isCompleted,
                    completionDate: questEntity.completionDate
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
                NotificationManager.shared.cancelQuestNotifications(questId: id)
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
                
                // Set completion date when quest is completed
                if isCompleted {
                    questEntity.completionDate = Date()
                } else {
                    // Clear completion date if quest is uncompleted
                    questEntity.completionDate = nil
                }
                
                NotificationManager.shared.cancelQuestNotifications(questId: id)
                try context.save()
                completion(nil)
            } else {
                completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Quest not found"]))
            }
        } catch {
            completion(error)
        }
    }
    
    func updateQuestProgress(withId id: UUID, progress: Int, completion: @escaping (Error?) -> Void) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<QuestEntity> = QuestEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            if let questEntity = try context.fetch(fetchRequest).first {
                questEntity.progress = Int16(progress)
                try context.save()
                print("📊 Updated quest progress: '\(questEntity.title ?? "Unknown")' to \(progress)%")
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
        repeatType: QuestRepeatType?,
        repeatIntervalWeeks: Int?,
        tasks: [String]?,
        completion: @escaping (Error?) -> Void
    ) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<QuestEntity> = QuestEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            if let questEntity = try context.fetch(fetchRequest).first {
                if let title { questEntity.title = title }
                if let isMainQuest { questEntity.isMainQuest = isMainQuest }
                if let info { questEntity.info = info }
                if let difficulty { questEntity.difficulty = Int16(difficulty) }
                if let dueDate { questEntity.dueDate = dueDate }
                if let isActive { questEntity.isActive = isActive }
                if let progress { questEntity.progress = Int16(progress) }
                if let repeatType { questEntity.repeatType = repeatType.rawValue }
                if let repeatIntervalWeeks { questEntity.repeatIntervalWeeks = Int16(repeatIntervalWeeks) }

                if let tasks = tasks {
                    if let existingTasksArray = questEntity.tasks?.array as? [TaskEntity] {
                        var existingTasksSet = Set(existingTasksArray)

                        for (index, title) in tasks.enumerated() {
                            if let existingTask = existingTasksSet.first(where: { $0.title == title }) {
                                // Update existing task - preserve ID and completion status
                                existingTask.order = Int16(index)
                                existingTasksSet.remove(existingTask)
                                print("🔄 Updated existing task: '\(title)' with ID: \(existingTask.id?.uuidString ?? "No ID"), isCompleted: \(existingTask.isCompleted)")
                            } else {
                                // Create new task only if it doesn't exist
                                let taskEntity = TaskEntity(context: context)
                                taskEntity.id = UUID()
                                taskEntity.title = title
                                taskEntity.isCompleted = false
                                taskEntity.order = Int16(index)
                                taskEntity.quest = questEntity
                                print("🆕 Created new task: '\(title)' with ID: \(taskEntity.id?.uuidString ?? "No ID")")
                            }
                        }

                        // Only delete tasks that are no longer in the list
                        for task in existingTasksSet {
                            print("🗑️ Deleting task: '\(task.title ?? "Unknown")' with ID: \(task.id?.uuidString ?? "No ID")")
                            context.delete(task)
                        }
                    }
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
                    print("🔧 Found task: \(taskEntity.title ?? "Unknown") with ID: \(taskEntity.id?.uuidString ?? "No ID")")
                    print("🔧 Current isCompleted: \(taskEntity.isCompleted)")
                    
                    if let title {
                        taskEntity.title = title
                        print("🔧 Updated title to: \(title)")
                    }
                    if let isCompleted {
                        taskEntity.isCompleted = isCompleted
                        print("🔧 Updated isCompleted to: \(isCompleted)")
                    }
                    if let order {
                        taskEntity.order = order
                        print("🔧 Updated order to: \(order)")
                    }
                    if let questId {
                        let questFetch: NSFetchRequest<QuestEntity> = QuestEntity.fetchRequest()
                        questFetch.predicate = NSPredicate(format: "id == %@", questId as CVarArg)
                        if let questEntity = try context.fetch(questFetch).first {
                            taskEntity.quest = questEntity
                            print("🔧 Reassigned to quest: \(questEntity.title ?? "Unknown")")
                        } else {
                            completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Quest not found for reassignment"]))
                            return
                        }
                    }

                    try context.save()
                    print("🔧 Successfully saved task update to Core Data")
                    completion(nil)
                } else {
                    print("❌ Task not found with ID: \(id.uuidString)")
                    completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Task not found"]))
                }
            } catch {
                print("❌ Error updating task: \(error)")
                completion(error)
            }
        }
}
