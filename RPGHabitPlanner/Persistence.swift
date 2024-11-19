//
//  Persistence.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 26.10.2024.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = QuestEntity(context: viewContext)
            newItem.dueDate = Date()
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "RPGHabitPlanner")

        if let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.makisacik.RPGHabitPlanner") {
            let storeURL = appGroupURL.appendingPathComponent("RPGHabitPlanner.sqlite")
            let description = NSPersistentStoreDescription(url: storeURL)
            container.persistentStoreDescriptions = [description]
        } else {
            fatalError("Failed to locate App Group container.")
        }

        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
