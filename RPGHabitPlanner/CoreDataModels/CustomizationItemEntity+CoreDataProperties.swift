//
//  CustomizationItemEntity+CoreDataProperties.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 7.01.2025.
//
//

import Foundation
import CoreData

extension CustomizationItemEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CustomizationItemEntity> {
        return NSFetchRequest<CustomizationItemEntity>(entityName: "CustomizationItemEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var category: String?
    @NSManaged public var rarity: String?
    @NSManaged public var price: Int32
    @NSManaged public var imageName: String?
    @NSManaged public var isUnlocked: Bool
    @NSManaged public var isEquipped: Bool
    @NSManaged public var createdAt: Date?
    @NSManaged public var itemData: String?
    @NSManaged public var owner: UserEntity?
}

extension CustomizationItemEntity: Identifiable {
}

// MARK: - Convenience Methods
extension CustomizationItemEntity {
    /// Computed property for item rarity enum
    var itemRarity: ItemRarity? {
        guard let rarity = rarity else { return nil }
        return ItemRarity(rawValue: rarity)
    }
    
    /// Sets the item rarity
    func setRarity(_ rarity: ItemRarity) {
        self.rarity = rarity.rawValue
    }
    
    /// Computed property for customization category
    var customizationCategory: CustomizationCategory? {
        guard let category = category else { return nil }
        return CustomizationCategory(rawValue: category)
    }
    
    /// Sets the customization category
    func setCategory(_ category: CustomizationCategory) {
        self.category = category.rawValue
    }
    
    /// Parses item data JSON
    var itemDataDictionary: [String: Any]? {
        guard let itemData = itemData,
              let data = itemData.data(using: .utf8) else { return nil }
        return try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    }
    
    /// Sets item data from dictionary
    func setItemData(_ data: [String: Any]) {
        if let jsonData = try? JSONSerialization.data(withJSONObject: data),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            self.itemData = jsonString
        }
    }
}

// Note: CustomizationCategory enum is defined in CharacterCustomizationView.swift
