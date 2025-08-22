//
//  TagService.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 14.08.2025.
//

import Foundation
import CoreData

protocol TagServiceProtocol {
    func fetchAllTags(completion: @escaping ([Tag], Error?) -> Void)
    func createTag(name: String, icon: String?, color: String?, completion: @escaping (Tag?, Error?) -> Void)
    func updateTag(id: UUID, name: String?, icon: String?, color: String?, completion: @escaping (Tag?, Error?) -> Void)
    func deleteTag(id: UUID, completion: @escaping (Error?) -> Void)
    func searchTags(query: String, completion: @escaping ([Tag], Error?) -> Void)
    func assignTagsToQuest(questId: UUID, tagIds: [UUID], completion: @escaping (Error?) -> Void)
    func removeTagsFromQuest(questId: UUID, tagIds: [UUID], completion: @escaping (Error?) -> Void)
    func getTagsForQuest(questId: UUID, completion: @escaping ([Tag], Error?) -> Void)
    func getQuestsWithTags(tagIds: [UUID], matchMode: TagMatchMode, completion: @escaping ([Quest], Error?) -> Void)
}

enum TagMatchMode {
    case any    // Quest has ANY of the selected tags
    case all    // Quest has ALL of the selected tags
}

final class TagService: TagServiceProtocol {
    private let persistentContainer: NSPersistentContainer

    init(container: NSPersistentContainer = PersistenceController.shared.container) {
        self.persistentContainer = container
    }

    // MARK: - Tag CRUD Operations

    func fetchAllTags(completion: @escaping ([Tag], Error?) -> Void) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TagEntity> = TagEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        do {
            let tagEntities = try context.fetch(fetchRequest)

            // Check if any tags need migration
            var needsMigration = false
            for tagEntity in tagEntities {
                if tagEntity.nameNormalized == nil || tagEntity.nameNormalized?.isEmpty == true {
                    needsMigration = true
                    break
                }
            }

            // Perform migration if needed
            if needsMigration {
                migrateExistingTags { [weak self] error in
                    if let error = error {
                        completion([], error)
                    } else {
                        // Fetch again after migration
                        self?.fetchAllTags(completion: completion)
                    }
                }
                return
            }

            // Check if default tags need to be created
            if tagEntities.isEmpty {
                createDefaultTags { [weak self] error in
                    if let error = error {
                        completion([], error)
                    } else {
                        // Fetch again after creating default tags
                        self?.fetchAllTags(completion: completion)
                    }
                }
                return
            }

            let tags = tagEntities.map { Tag(entity: $0) }
            completion(tags, nil)
        } catch {
            completion([], error)
        }
    }

    func createTag(name: String, icon: String?, color: String?, completion: @escaping (Tag?, Error?) -> Void) {
        let context = persistentContainer.viewContext

        // Normalize name for uniqueness check
        let normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        // Check for existing tag with same normalized name
        let fetchRequest: NSFetchRequest<TagEntity> = TagEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "nameNormalized == %@", normalizedName)

        do {
            let existingTags = try context.fetch(fetchRequest)
            if !existingTags.isEmpty {
                completion(nil, NSError(domain: "TagService", code: 409, userInfo: [NSLocalizedDescriptionKey: "A tag with this name already exists"]))
                return
            }

            let tagEntity = TagEntity(context: context)
            tagEntity.id = UUID()
            tagEntity.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
            tagEntity.nameNormalized = normalizedName
            tagEntity.icon = icon
            tagEntity.color = color

            try context.save()

            let tag = Tag(entity: tagEntity)
            completion(tag, nil)
        } catch {
            completion(nil, error)
        }
    }

    func updateTag(id: UUID, name: String?, icon: String?, color: String?, completion: @escaping (Tag?, Error?) -> Void) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TagEntity> = TagEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            guard let tagEntity = try context.fetch(fetchRequest).first else {
                completion(nil, NSError(domain: "TagService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Tag not found"]))
                return
            }

            if let name = name {
                let normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

                // Check for conflicts if name is being changed
                if normalizedName != tagEntity.nameNormalized {
                    let conflictFetchRequest: NSFetchRequest<TagEntity> = TagEntity.fetchRequest()
                    conflictFetchRequest.predicate = NSPredicate(format: "nameNormalized == %@ AND id != %@", normalizedName, id as CVarArg)

                    let conflictingTags = try context.fetch(conflictFetchRequest)
                    if !conflictingTags.isEmpty {
                        completion(nil, NSError(domain: "TagService", code: 409, userInfo: [NSLocalizedDescriptionKey: "A tag with this name already exists"]))
                        return
                    }

                    tagEntity.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
                    tagEntity.nameNormalized = normalizedName
                }
            }

            if let icon = icon {
                tagEntity.icon = icon
            }

            if let color = color {
                tagEntity.color = color
            }

            try context.save()

            let tag = Tag(entity: tagEntity)
            completion(tag, nil)
        } catch {
            completion(nil, error)
        }
    }

    func deleteTag(id: UUID, completion: @escaping (Error?) -> Void) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TagEntity> = TagEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            guard let tagEntity = try context.fetch(fetchRequest).first else {
                completion(NSError(domain: "TagService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Tag not found"]))
                return
            }

            context.delete(tagEntity)
            try context.save()
            completion(nil)
        } catch {
            completion(error)
        }
    }

    func searchTags(query: String, completion: @escaping ([Tag], Error?) -> Void) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TagEntity> = TagEntity.fetchRequest()

        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        fetchRequest.predicate = NSPredicate(format: "nameNormalized CONTAINS %@", normalizedQuery)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        do {
            let tagEntities = try context.fetch(fetchRequest)
            let tags = tagEntities.map { Tag(entity: $0) }
            completion(tags, nil)
        } catch {
            completion([], error)
        }
    }

    // MARK: - Tag-Quest Relationship Operations

    func assignTagsToQuest(questId: UUID, tagIds: [UUID], completion: @escaping (Error?) -> Void) {
        let context = persistentContainer.viewContext

        // Fetch quest
        let questFetchRequest: NSFetchRequest<QuestEntity> = QuestEntity.fetchRequest()
        questFetchRequest.predicate = NSPredicate(format: "id == %@", questId.uuidString)

        // Fetch tags
        let tagFetchRequest: NSFetchRequest<TagEntity> = TagEntity.fetchRequest()
        let tagIdStrings = tagIds.map { $0.uuidString }
        tagFetchRequest.predicate = NSPredicate(format: "id IN %@", tagIdStrings)

        do {
            guard let questEntity = try context.fetch(questFetchRequest).first else {
                completion(NSError(domain: "TagService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Quest not found"]))
                return
            }

            let tagEntities = try context.fetch(tagFetchRequest)

            for tagEntity in tagEntities {
                questEntity.addToTags(tagEntity)
            }

            try context.save()
            completion(nil)
        } catch {
            completion(error)
        }
    }

    func removeTagsFromQuest(questId: UUID, tagIds: [UUID], completion: @escaping (Error?) -> Void) {
        let context = persistentContainer.viewContext

        // Fetch quest
        let questFetchRequest: NSFetchRequest<QuestEntity> = QuestEntity.fetchRequest()
        questFetchRequest.predicate = NSPredicate(format: "id == %@", questId.uuidString)

        // Fetch tags
        let tagFetchRequest: NSFetchRequest<TagEntity> = TagEntity.fetchRequest()
        let tagIdStrings = tagIds.map { $0.uuidString }
        tagFetchRequest.predicate = NSPredicate(format: "id IN %@", tagIdStrings)

        do {
            guard let questEntity = try context.fetch(questFetchRequest).first else {
                completion(NSError(domain: "TagService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Quest not found"]))
                return
            }

            let tagEntities = try context.fetch(tagFetchRequest)

            for tagEntity in tagEntities {
                questEntity.removeFromTags(tagEntity)
            }

            try context.save()
            completion(nil)
        } catch {
            completion(error)
        }
    }

    func getTagsForQuest(questId: UUID, completion: @escaping ([Tag], Error?) -> Void) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<QuestEntity> = QuestEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", questId.uuidString)

        do {
            guard let questEntity = try context.fetch(fetchRequest).first else {
                completion([], NSError(domain: "TagService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Quest not found"]))
                return
            }

            let tagEntities = questEntity.tags?.allObjects as? [TagEntity] ?? []
            let tags = tagEntities.map { Tag(entity: $0) }
            completion(tags, nil)
        } catch {
            completion([], error)
        }
    }

    func getQuestsWithTags(tagIds: [UUID], matchMode: TagMatchMode, completion: @escaping ([Quest], Error?) -> Void) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<QuestEntity> = QuestEntity.fetchRequest()

        // Build predicate based on match mode
        let predicate: NSPredicate
        let tagIdStrings = tagIds.map { $0.uuidString }
        switch matchMode {
        case .any:
            predicate = NSPredicate(format: "ANY tags.id IN %@", tagIdStrings)
        case .all:
            // For "all" mode, we need to check that the quest has all the specified tags
            let subpredicates = tagIds.map { tagId in
                NSPredicate(format: "ANY tags.id == %@", tagId.uuidString)
            }
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: subpredicates)
        }

        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dueDate", ascending: true)]

        do {
            let questEntities = try context.fetch(fetchRequest)
            let quests = questEntities.map { mapQuestEntityToQuest($0) }
            completion(quests, nil)
        } catch {
            completion([], error)
        }
    }

    // MARK: - Default Tags

    func createDefaultTags(completion: @escaping (Error?) -> Void) {
        let context = persistentContainer.viewContext

        let defaultTags = [
            (name: "Project", icon: "folder.fill", color: "#4ECDC4"), // Teal
            (name: "Work", icon: "briefcase.fill", color: "#45B7D1"), // Blue
            (name: "Gym", icon: "dumbbell.fill", color: "#FF6B6B")   // Red
        ]

        for (name, icon, color) in defaultTags {
            let tagEntity = TagEntity(context: context)
            tagEntity.id = UUID()
            tagEntity.name = name
            tagEntity.nameNormalized = name.lowercased()
            tagEntity.icon = icon
            tagEntity.color = color
        }

        do {
            try context.save()
            completion(nil)
        } catch {
            completion(error)
        }
    }

    // MARK: - Migration Helper

    func migrateExistingTags(completion: @escaping (Error?) -> Void) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TagEntity> = TagEntity.fetchRequest()

        do {
            let tagEntities = try context.fetch(fetchRequest)
            var needsSave = false

            for tagEntity in tagEntities {
                if tagEntity.nameNormalized == nil || tagEntity.nameNormalized?.isEmpty == true {
                    tagEntity.nameNormalized = tagEntity.name?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                    needsSave = true
                }
            }

            if needsSave {
                try context.save()
            }

            completion(nil)
        } catch {
            completion(error)
        }
    }

    // MARK: - Helper Methods

    private func mapQuestEntityToQuest(_ entity: QuestEntity) -> Quest {
        let completions: Set<Date> = (entity.completions as? Set<QuestCompletionEntity>)?
            .compactMap { $0.date }
            .map { Calendar.current.startOfDay(for: $0) }
            .reduce(into: Set<Date>()) { $0.insert($1) } ?? []

        let tags: Set<Tag> = (entity.tags as? Set<TagEntity>)?
            .map { Tag(entity: $0) }
            .reduce(into: Set<Tag>()) { $0.insert($1) } ?? []

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
}
