//
//  ItemEntity+CoreDataProperties.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 7.01.2025.
//

import Foundation
import CoreData

extension ItemEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ItemEntity> {
        return NSFetchRequest<ItemEntity>(entityName: "ItemEntity")
    }

    @NSManaged public var iconName: String?
    @NSManaged public var info: String?
    @NSManaged public var itemType: String?
    @NSManaged public var gearCategory: String?
    @NSManaged public var accessoryCategory: String?
    @NSManaged public var previewImage: String?
    @NSManaged public var rarity: String?
    @NSManaged public var value: Int32
    @NSManaged public var collectionCategory: String?
    @NSManaged public var isRare: Bool
    @NSManaged public var name: String?
}

extension ItemEntity: Identifiable {
}

// MARK: - Convenience Methods
extension ItemEntity {
    /// Gets the localized name for this item using the icon name as identifier
    var localizedName: String {
        guard let iconName = self.iconName else {
            return self.name ?? "unknown_item".localized
        }

        // Try to find the item in the ItemDatabase to get the current localized name
        if let itemDefinition = ItemDatabase.findItem(byIconName: iconName) {
            return itemDefinition.localizedName
        }

        // Fallback to stored name if not found in database
        return self.name ?? "unknown_item".localized
    }

    /// Gets the localized description for this item using the icon name as identifier
    var localizedDescription: String {
        guard let iconName = self.iconName else {
            return self.info ?? "unknown_item_description".localized
        }

        // Try to find the item in the ItemDatabase to get the current localized description
        if let itemDefinition = ItemDatabase.findItem(byIconName: iconName) {
            return itemDefinition.localizedDescription
        }

        // Fallback to stored info if not found in database
        return self.info ?? "unknown_item_description".localized
    }

    /// Computed property for item rarity enum
    var itemRarity: ItemRarity? {
        guard let rarity = rarity else { return nil }
        return ItemRarity(rawValue: rarity)
    }

    /// Sets the item rarity
    func setRarity(_ rarity: ItemRarity) {
        self.rarity = rarity.rawValue
    }

    /// Computed property for item type enum
    var itemTypeEnum: ItemType? {
        guard let itemType = itemType else { return nil }
        return ItemType(rawValue: itemType)
    }

    /// Sets the item type
    func setItemType(_ itemType: ItemType) {
        self.itemType = itemType.rawValue
    }

    /// Computed property for gear category enum
    var gearCategoryEnum: GearCategory? {
        guard let gearCategory = gearCategory else { return nil }
        return GearCategory(rawValue: gearCategory)
    }

    /// Sets the gear category
    func setGearCategory(_ gearCategory: GearCategory) {
        self.gearCategory = gearCategory.rawValue
    }

    /// Computed property for accessory category enum
    var accessoryCategoryEnum: AccessoryCategory? {
        guard let accessoryCategory = accessoryCategory else { return nil }
        return AccessoryCategory(rawValue: accessoryCategory)
    }

    /// Sets the accessory category
    func setAccessoryCategory(_ accessoryCategory: AccessoryCategory) {
        self.accessoryCategory = accessoryCategory.rawValue
    }
}
