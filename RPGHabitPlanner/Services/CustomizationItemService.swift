//
//  CustomizationItemService.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 7.01.2025.
//

import Foundation
import CoreData

// MARK: - Customization Item Service Protocol

protocol CustomizationItemServiceProtocol {
    func fetchItems(for user: UserEntity) -> [CustomizationItemEntity]
    func fetchItems(for user: UserEntity, category: CustomizationCategory) -> [CustomizationItemEntity]
    func fetchEquippedItems(for user: UserEntity) -> [CustomizationItemEntity]
    func addItem(to user: UserEntity, assetName: String, category: CustomizationCategory, rarity: ItemRarity, imageName: String, price: Int32) -> CustomizationItemEntity?
    func unlockItem(_ item: CustomizationItemEntity)
    func equipItem(_ item: CustomizationItemEntity)
    func unequipItem(_ item: CustomizationItemEntity)
    func unequipAllItems(for user: UserEntity, in category: CustomizationCategory)
    func deleteItem(_ item: CustomizationItemEntity)
    func migrateOwnedItems(for user: UserEntity, ownedItems: Set<String>)
}

// MARK: - Customization Item Service Implementation

final class CustomizationItemService: CustomizationItemServiceProtocol {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext

    init(container: NSPersistentContainer = PersistenceController.shared.container) {
        self.container = container
        self.context = container.viewContext
    }

    // MARK: - Fetch Operations

    func fetchItems(for user: UserEntity) -> [CustomizationItemEntity] {
        let request: NSFetchRequest<CustomizationItemEntity> = CustomizationItemEntity.fetchRequest()
        request.predicate = NSPredicate(format: "owner == %@", user)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \CustomizationItemEntity.category, ascending: true),
            NSSortDescriptor(keyPath: \CustomizationItemEntity.rarity, ascending: false),
            NSSortDescriptor(keyPath: \CustomizationItemEntity.assetName, ascending: true)
        ]

        do {
            return try context.fetch(request)
        } catch {
            print("❌ Error fetching customization items: \(error)")
            return []
        }
    }

    func fetchItems(for user: UserEntity, category: CustomizationCategory) -> [CustomizationItemEntity] {
        let request: NSFetchRequest<CustomizationItemEntity> = CustomizationItemEntity.fetchRequest()
        request.predicate = NSPredicate(format: "owner == %@ AND category == %@", user, category.rawValue)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \CustomizationItemEntity.rarity, ascending: false),
            NSSortDescriptor(keyPath: \CustomizationItemEntity.assetName, ascending: true)
        ]

        do {
            return try context.fetch(request)
        } catch {
            print("❌ Error fetching customization items for category \(category): \(error)")
            return []
        }
    }

    func fetchEquippedItems(for user: UserEntity) -> [CustomizationItemEntity] {
        let request: NSFetchRequest<CustomizationItemEntity> = CustomizationItemEntity.fetchRequest()
        request.predicate = NSPredicate(format: "owner == %@ AND isEquipped == YES", user)

        do {
            return try context.fetch(request)
        } catch {
            print("❌ Error fetching equipped items: \(error)")
            return []
        }
    }

    // MARK: - Item Management

    func addItem(to user: UserEntity, assetName: String, category: CustomizationCategory, rarity: ItemRarity, imageName: String, price: Int32 = 0) -> CustomizationItemEntity? {
        let item = CustomizationItemEntity(context: context)
        item.id = UUID()
        item.assetName = assetName
        item.setCategory(category)
        item.setRarity(rarity)
        item.imageName = imageName
        item.price = price
        item.isUnlocked = true // Default to unlocked when added
        item.isEquipped = false
        item.createdAt = Date()
        item.owner = user

        do {
            try context.save()
            return item
        } catch {
            print("❌ Error adding customization item: \(error)")
            return nil
        }
    }

    func unlockItem(_ item: CustomizationItemEntity) {
        item.isUnlocked = true
        saveContext()
    }

    func equipItem(_ item: CustomizationItemEntity) {
        guard item.isUnlocked, let category = item.customizationCategory, let user = item.owner else {
            print("❌ Cannot equip item: not unlocked or invalid data")
            return
        }

        // Unequip all other items in this category first
        unequipAllItems(for: user, in: category)

        // Equip this item
        item.isEquipped = true
        saveContext()
    }

    func unequipItem(_ item: CustomizationItemEntity) {
        item.isEquipped = false
        saveContext()
    }

    func unequipAllItems(for user: UserEntity, in category: CustomizationCategory) {
        let items = fetchItems(for: user, category: category)
        items.forEach { $0.isEquipped = false }
        saveContext()
    }

    func deleteItem(_ item: CustomizationItemEntity) {
        context.delete(item)
        saveContext()
    }

    // MARK: - Migration Support

    func migrateOwnedItems(for user: UserEntity, ownedItems: Set<String>) {
        // Clear existing items to avoid duplicates
        let existingItems = fetchItems(for: user)
        existingItems.forEach { context.delete($0) }

        // Create items from owned items set
        for itemId in ownedItems {
            if let category = determineCategory(for: itemId) {
                let rarity = determineRarity(for: itemId)
                _ = addItem(
                    to: user,
                    assetName: itemId,
                    category: category,
                    rarity: rarity,
                    imageName: itemId
                )
            }
        }
    }

    // MARK: - Utility Methods

    private func determineCategory(for itemId: String) -> CustomizationCategory? {
        if BodyType.allCases.contains(where: { $0.rawValue == itemId }) {
            return .bodyType
        } else if HairStyle.allCases.contains(where: { $0.rawValue == itemId }) {
            return .hairStyle
        } else if EyeColor.allCases.contains(where: { $0.rawValue == itemId }) {
            return .eyeColor
        } else if Outfit.allCases.contains(where: { $0.rawValue == itemId }) {
            return .outfit
        } else if CharacterWeapon.allCases.contains(where: { $0.rawValue == itemId }) {
            return .weapon
        } else if Accessory.allCases.contains(where: { $0.rawValue == itemId }) {
            return .accessory
        }
        return nil
    }

    private func determineRarity(for itemId: String) -> ItemRarity {
        // Default rarity logic - can be enhanced later
        if itemId.contains("legendary") || itemId.contains("firelord") || itemId.contains("deadly") {
            return .legendary
        } else if itemId.contains("epic") || itemId.contains("fire") || itemId.contains("iron") {
            return .epic
        } else if itemId.contains("rare") || itemId.contains("copper") || itemId.contains("assassin") {
            return .rare
        } else if itemId.contains("uncommon") || itemId.contains("hoodie") || itemId.contains("wings") {
            return .uncommon
        }
        return .common
    }

    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("❌ Error saving customization item context: \(error)")
        }
    }
}

// MARK: - Default Items Helper

extension CustomizationItemService {
    /// Populates default items for a user
    func populateDefaultItems(for user: UserEntity) {
        // Add all basic items as owned
        let defaultItems: [(String, CustomizationCategory, ItemRarity)] = [
            // Body types (skin colors)
            (BodyType.bodyWhite.rawValue, .bodyType, .common),
            (BodyType.bodyBlue.rawValue, .bodyType, .common),
            (BodyType.bodyTan.rawValue, .bodyType, .uncommon),

            // Hair styles
            (HairStyle.hair1Brown.rawValue, .hairStyle, .common),
            (HairStyle.hair1Black.rawValue, .hairStyle, .uncommon),

            // Eye colors
            (EyeColor.eyeBlack.rawValue, .eyeColor, .common),
            (EyeColor.eyeBlue.rawValue, .eyeColor, .uncommon),

            // Outfits
            (Outfit.outfitVillager.rawValue, .outfit, .common),
            (Outfit.outfitVillagerBlue.rawValue, .outfit, .uncommon),

            // Weapons
            (CharacterWeapon.swordWood.rawValue, .weapon, .common),
            (CharacterWeapon.swordIron.rawValue, .weapon, .uncommon)
        ]

        for (itemName, category, rarity) in defaultItems {
            _ = addItem(
                to: user,
                assetName: itemName,
                category: category,
                rarity: rarity,
                imageName: itemName,
                price: 0
            )
        }
    }
}
