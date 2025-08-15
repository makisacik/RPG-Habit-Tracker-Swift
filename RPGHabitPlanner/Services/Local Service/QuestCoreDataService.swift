//
//  QuestCoreDataService.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 30.10.2024.
//  Updated for QuestCompletionEntity & completions set
//

import Foundation
import CoreData

final class QuestCoreDataService: QuestDataServiceProtocol {
    private let persistentContainer: NSPersistentContainer
    private let calendar = Calendar.current

    init(container: NSPersistentContainer = PersistenceController.shared.container) {
        self.persistentContainer = container
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
        tasks: [String]?,
        tags: [Tag]?,
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

                if let tasks = tasks {
                    // Existing tasks
                    let existingTasks = questEntity.tasks?.array as? [TaskEntity] ?? []
                    var existingTasksSet = Set(existingTasks)

                    for (index, title) in tasks.enumerated() {
                        if let existingTask = existingTasksSet.first(where: { $0.title == title }) {
                            existingTask.order = Int16(index)
                            existingTasksSet.remove(existingTask)
                        } else {
                            let taskEntity = TaskEntity(context: context)
                            taskEntity.id = UUID()
                            taskEntity.title = title
                            taskEntity.isCompleted = false
                            taskEntity.order = Int16(index)
                            taskEntity.quest = questEntity
                        }
                    }

                    // Remove tasks not in new list
                    for task in existingTasksSet {
                        context.delete(task)
                    }
                }

                // Update tags
                if let tags = tags {
                    // Remove existing tags
                    if let existingTags = questEntity.tags as? Set<TagEntity> {
                        for tagEntity in existingTags {
                            questEntity.removeFromTags(tagEntity)
                        }
                    }
                    
                    // Add new tags
                    if !tags.isEmpty {
                        let tagFetchRequest: NSFetchRequest<TagEntity> = TagEntity.fetchRequest()
                        let tagIds = tags.map { $0.id.uuidString }
                        tagFetchRequest.predicate = NSPredicate(format: "id IN %@", tagIds)
                        
                        do {
                            let tagEntities = try context.fetch(tagFetchRequest)
                            for tagEntity in tagEntities {
                                questEntity.addToTags(tagEntity)
                            }
                        } catch {
                            print("❌ Error fetching tags for quest update: \(error)")
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
        title: String?,
        isCompleted: Bool?,
        order: Int16?,
        questId: UUID?,
        completion: @escaping (Error?) -> Void
    ) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            if let taskEntity = try context.fetch(fetchRequest).first {
                if let title { taskEntity.title = title }
                if let isCompleted { taskEntity.isCompleted = isCompleted }
                if let order { taskEntity.order = order }

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


    // MARK: - Save Quest
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
        questEntity.completionDate = quest.completionDate
        questEntity.isFinished = quest.isFinished
        questEntity.isFinishedDate = quest.isFinishedDate

        // Save completion history if provided
        for date in quest.completions {
            let log = QuestCompletionEntity(context: context)
            log.id = UUID()
            log.date = calendar.startOfDay(for: date)
            log.quest = questEntity
        }

        // Save tasks
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

        // Save tags
        if !quest.tags.isEmpty {
            let tagFetchRequest: NSFetchRequest<TagEntity> = TagEntity.fetchRequest()
            let tagIds = quest.tags.map { $0.id.uuidString }
            tagFetchRequest.predicate = NSPredicate(format: "id IN %@", tagIds)
            
            do {
                let tagEntities = try context.fetch(tagFetchRequest)
                for tagEntity in tagEntities {
                    questEntity.addToTags(tagEntity)
                }
            } catch {
                print("❌ Error fetching tags for quest: \(error)")
            }
        }

        do {
            try context.save()
            completion(nil)
        } catch {
            completion(error)
        }
    }

    // MARK: - Fetch All
    func fetchAllQuests(completion: @escaping ([Quest], Error?) -> Void) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<QuestEntity> = QuestEntity.fetchRequest()

        do {
            let questEntities = try context.fetch(fetchRequest)
            let quests = questEntities.map { self.mapQuestEntityToQuest($0) }
            completion(quests, nil)
        } catch {
            completion([], error)
        }
    }

    func fetchCompletedQuests(completion: @escaping ([Quest], Error?) -> Void) {
        fetchQuests(predicate: NSPredicate(format: "isCompleted == YES"), completion: completion)
    }

    func fetchNonCompletedQuests(completion: @escaping ([Quest], Error?) -> Void) {
        fetchQuests(predicate: NSPredicate(format: "isCompleted == NO"), completion: completion)
    }

    func fetchFinishedQuests(completion: @escaping ([Quest], Error?) -> Void) {
        fetchQuests(predicate: NSPredicate(format: "isFinished == YES"), completion: completion)
    }

    func fetchQuestById(_ id: UUID, completion: @escaping (Quest?, Error?) -> Void) {
        fetchQuests(predicate: NSPredicate(format: "id == %@", id as CVarArg)) { quests, error in
            completion(quests.first, error)
        }
    }

    private func fetchQuests(predicate: NSPredicate?, completion: @escaping ([Quest], Error?) -> Void) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<QuestEntity> = QuestEntity.fetchRequest()
        fetchRequest.predicate = predicate

        do {
            let questEntities = try context.fetch(fetchRequest)
            print("🗄️ QuestCoreDataService: Fetched \(questEntities.count) quest entities from Core Data")
            let quests = questEntities.map { self.mapQuestEntityToQuest($0) }
            print("🗄️ QuestCoreDataService: Mapped \(quests.count) quest entities to Quest objects")
            completion(quests, nil)
        } catch {
            completion([], error)
        }
    }

    private func mapQuestEntityToQuest(_ entity: QuestEntity) -> Quest {
        let completions: Set<Date> = (entity.completions as? Set<QuestCompletionEntity>)?
            .compactMap { $0.date }
            .map { calendar.startOfDay(for: $0) }
            .reduce(into: Set<Date>()) { $0.insert($1) } ?? []

        let tags: Set<Tag> = (entity.tags as? Set<TagEntity>)?
            .map { Tag(entity: $0) }
            .reduce(into: Set<Tag>()) { $0.insert($1) } ?? []

        print("🗄️ QuestCoreDataService: Mapping quest '\(entity.title ?? "Unknown")' with \(entity.taskList.count) tasks and \(tags.count) tags")

        return Quest(
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
            isFinished: entity.isFinished,
            isFinishedDate: entity.isFinishedDate,
            tasks: entity.taskList
                .sorted { $0.order < $1.order }
                .map { QuestTask(entity: $0) },
            repeatType: QuestRepeatType(rawValue: entity.repeatType) ?? .oneTime,
            completions: completions,
            tags: tags
        )
    }

    // MARK: - Delete
    func deleteQuest(withId id: UUID, completion: @escaping (Error?) -> Void) {
        let context = persistentContainer.viewContext
        do {
            if let questEntity = try fetchQuestEntity(by: id, in: context) {
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

    // MARK: - Update Completion
    func updateQuestCompletion(forId id: UUID, to isCompleted: Bool, completion: @escaping (Error?) -> Void) {
        let context = persistentContainer.viewContext
        do {
            if let questEntity = try fetchQuestEntity(by: id, in: context) {
                questEntity.isCompleted = isCompleted
                if isCompleted {
                    questEntity.completionDate = Date()
                    // Log completion
                    let log = QuestCompletionEntity(context: context)
                    log.id = UUID()
                    log.date = calendar.startOfDay(for: Date())
                    log.quest = questEntity
                } else {
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

    // MARK: - Update Progress
    func updateQuestProgress(withId id: UUID, progress: Int, completion: @escaping (Error?) -> Void) {
        let context = persistentContainer.viewContext
        do {
            if let questEntity = try fetchQuestEntity(by: id, in: context) {
                questEntity.progress = Int16(progress)
                try context.save()
                completion(nil)
            } else {
                completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Quest not found"]))
            }
        } catch {
            completion(error)
        }
    }

    // MARK: - Mark as Finished
    func markQuestAsFinished(forId id: UUID, completion: @escaping (Error?) -> Void) {
        let context = persistentContainer.viewContext
        do {
            if let questEntity = try fetchQuestEntity(by: id, in: context) {
                questEntity.isFinished = true
                questEntity.isFinishedDate = Date()
                questEntity.isActive = false
                try context.save()

                // Post notification to update UI
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .questUpdated, object: nil)
                }

                completion(nil)
            } else {
                completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Quest not found"]))
            }
        } catch {
            completion(error)
        }
    }

    // MARK: - Helper
    private func fetchQuestEntity(by id: UUID, in context: NSManagedObjectContext) throws -> QuestEntity? {
        let request: NSFetchRequest<QuestEntity> = QuestEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try context.fetch(request).first
    }
}


extension QuestCoreDataService {
    // MARK: - Quest Completion Logging
    func markQuestCompleted(forId id: UUID, on date: Date, completion: @escaping (Error?) -> Void) {
        let context = persistentContainer.viewContext
        let logService = QuestLogService(context: context)
        do {
            if let quest = try fetchQuestEntity(by: id, in: context) {
                try logService.markCompleted(quest, on: date)
                completion(nil)
            } else {
                completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Quest not found"]))
            }
        } catch {
            completion(error)
        }
    }

    func unmarkQuestCompleted(forId id: UUID, on date: Date, completion: @escaping (Error?) -> Void) {
        let context = persistentContainer.viewContext
        let logService = QuestLogService(context: context)
        do {
            if let quest = try fetchQuestEntity(by: id, in: context) {
                try logService.unmarkCompleted(quest, on: date)
                completion(nil)
            } else {
                completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Quest not found"]))
            }
        } catch {
            completion(error)
        }
    }

    func isQuestCompleted(forId id: UUID, on date: Date, completion: @escaping (Bool, Error?) -> Void) {
        let context = persistentContainer.viewContext
        let logService = QuestLogService(context: context)
        do {
            if let quest = try fetchQuestEntity(by: id, in: context) {
                let result = try logService.isCompleted(quest, on: date)
                completion(result, nil)
            } else {
                completion(false, NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Quest not found"]))
            }
        } catch {
            completion(false, error)
        }
    }

    func questCompletionCount(forId id: UUID, from startDate: Date, to endDate: Date, completion: @escaping (Int, Error?) -> Void) {
        let context = persistentContainer.viewContext
        let logService = QuestLogService(context: context)
        do {
            if let quest = try fetchQuestEntity(by: id, in: context) {
                let count = try logService.completedCount(quest, from: startDate, to: endDate)
                completion(count, nil)
            } else {
                completion(0, NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Quest not found"]))
            }
        } catch {
            completion(0, error)
        }
    }

    func questCompletionDates(forId id: UUID, from startDate: Date, to endDate: Date, completion: @escaping ([Date], Error?) -> Void) {
        let context = persistentContainer.viewContext
        let logService = QuestLogService(context: context)
        do {
            if let quest = try fetchQuestEntity(by: id, in: context) {
                let dates = try logService.completionDates(quest, from: startDate, to: endDate)
                completion(dates, nil)
            } else {
                completion([], NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Quest not found"]))
            }
        } catch {
            completion([], error)
        }
    }

    func questCurrentStreak(forId id: UUID, asOf date: Date, completion: @escaping (Int, Error?) -> Void) {
        let context = persistentContainer.viewContext
        let logService = QuestLogService(context: context)
        do {
            if let quest = try fetchQuestEntity(by: id, in: context) {
                let streak = try logService.currentStreak(quest, asOf: date)
                completion(streak, nil)
            } else {
                completion(0, NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Quest not found"]))
            }
        } catch {
            completion(0, error)
        }
    }

    func refreshQuestState(forId id: UUID, on date: Date, completion: @escaping (Error?) -> Void) {
        let context = persistentContainer.viewContext
        let logService = QuestLogService(context: context)
        do {
            if let quest = try fetchQuestEntity(by: id, in: context) {
                try logService.refreshState(for: quest, on: date)
                completion(nil)
            } else {
                completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Quest not found"]))
            }
        } catch {
            completion(error)
        }
    }

    func refreshAllQuests(on date: Date, completion: @escaping (Error?) -> Void) {
        let context = persistentContainer.viewContext
        let logService = QuestLogService(context: context)
        do {
            try logService.refreshAll(on: date)
            completion(nil)
        } catch {
            completion(error)
        }
    }
}
