//
//  InventoryCoreDataService.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import Foundation
import CoreData

protocol InventoryServiceProtocol {
    func fetchInventory() -> [ItemEntity]
    func addItem(name: String, info: String, iconName: String, previewImage: String?, itemType: String?, gearCategory: String?, accessoryCategory: String?, rarity: String?, value: Int32, collectionCategory: String?, isRare: Bool)
    func removeItem(_ item: ItemEntity)
    func clearInventory()
}

final class InventoryService: InventoryServiceProtocol {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext

    init(container: NSPersistentContainer = PersistenceController.shared.container) {
        self.container = container
        self.context = container.viewContext
    }

    func fetchInventory() -> [ItemEntity] {
        let request: NSFetchRequest<ItemEntity> = ItemEntity.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("❌ Error fetching inventory: \(error)")
            return []
        }
    }

    func addItem(name: String, info: String, iconName: String, previewImage: String?, itemType: String?, gearCategory: String?, accessoryCategory: String?, rarity: String?, value: Int32, collectionCategory: String?, isRare: Bool) {
        print("🔧 InventoryService: Adding item - name: \(name), iconName: \(iconName)")
        let entity = ItemEntity(context: context)
        entity.name = name
        entity.info = info
        entity.iconName = iconName
        entity.previewImage = previewImage ?? "\(iconName)_preview"
        entity.itemType = itemType
        entity.gearCategory = gearCategory
        entity.accessoryCategory = accessoryCategory
        entity.rarity = rarity
        entity.value = value
        entity.collectionCategory = collectionCategory
        entity.isRare = isRare
        saveContext()
        print("✅ InventoryService: Item entity created and saved - name: \(name), iconName: \(iconName)")
    }

    func removeItem(_ item: ItemEntity) {
        context.delete(item)
        saveContext()
    }

    func clearInventory() {
        let request: NSFetchRequest<NSFetchRequestResult> = ItemEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try context.execute(deleteRequest)
            saveContext()
        } catch {
            print("❌ Error clearing inventory: \(error)")
        }
    }

    private func saveContext() {
        do {
            try context.save()
            print("✅ InventoryService: Context saved successfully")
        } catch {
            print("❌ Error saving context: \(error)")
        }
    }
}
