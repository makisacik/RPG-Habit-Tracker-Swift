//
//  CharacterCustomizationEntity+CoreDataProperties.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 7.01.2025.
//
//

import Foundation
import CoreData

extension CharacterCustomizationEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CharacterCustomizationEntity> {
        return NSFetchRequest<CharacterCustomizationEntity>(entityName: "CharacterCustomizationEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var userId: UUID?
    @NSManaged public var bodyType: String?
    @NSManaged public var hairStyle: String?
    @NSManaged public var hairBackStyle: String?
    @NSManaged public var hairColor: String?
    @NSManaged public var eyeColor: String?
    @NSManaged public var outfit: String?
    @NSManaged public var weapon: String?
    @NSManaged public var accessory: String?
    @NSManaged public var headGear: String?
    @NSManaged public var mustache: String?
    @NSManaged public var flower: String?
    @NSManaged public var pet: String?
    @NSManaged public var shield: String?
    @NSManaged public var wings: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var user: UserEntity?
}

extension CharacterCustomizationEntity: Identifiable {
}

// MARK: - Convenience Methods
extension CharacterCustomizationEntity {
    /// Converts accessories JSON string to array
    var accessoriesArray: [String] {
        guard let accessories = accessory,
              let data = accessories.data(using: .utf8),
              let array = try? JSONSerialization.jsonObject(with: data) as? [String] else {
            return []
        }
        return array
    }

    /// Sets accessories from array
    func setAccessories(_ accessories: [String]) {
        if let data = try? JSONSerialization.data(withJSONObject: accessories),
           let jsonString = String(data: data, encoding: .utf8) {
            self.accessory = jsonString
        }
    }

    // MARK: - Conversion Methods

    func toCharacterCustomization() -> CharacterCustomization {
        print("🔧 CharacterCustomizationEntity: toCharacterCustomization called")
        print("🔧 CharacterCustomizationEntity: Raw outfit value in entity: \(outfit ?? "nil")")
        
        var customization = CharacterCustomization()

        if let bodyTypeString = bodyType,
           let bodyType = BodyType(rawValue: bodyTypeString) {
            customization.bodyType = bodyType
        }

        if let hairStyleString = hairStyle,
           let hairStyle = HairStyle(rawValue: hairStyleString) {
            customization.hairStyle = hairStyle
        }

        if let hairBackStyleString = hairBackStyle,
           let hairBackStyle = HairBackStyle(rawValue: hairBackStyleString) {
            customization.hairBackStyle = hairBackStyle
        }

        if let hairColorString = hairColor,
           let hairColor = HairColor(rawValue: hairColorString) {
            customization.hairColor = hairColor
        }

        if let eyeColorString = eyeColor,
           let eyeColor = EyeColor(rawValue: eyeColorString) {
            customization.eyeColor = eyeColor
        }

        if let outfitString = outfit,
           let outfit = Outfit(rawValue: outfitString) {
            customization.outfit = outfit
            print("✅ CharacterCustomizationEntity: Successfully loaded outfit: \(outfit.rawValue)")
        } else {
            print("❌ CharacterCustomizationEntity: Failed to load outfit from string: \(outfit ?? "nil")")
        }

        if let weaponString = weapon,
           let weapon = CharacterWeapon(rawValue: weaponString) {
            customization.weapon = weapon
        }

        if let accessoryString = accessory,
           let accessory = Accessory(rawValue: accessoryString) {
            customization.accessory = accessory
        }

        if let headGearString = headGear,
           let headGear = HeadGear(rawValue: headGearString) {
            customization.headGear = headGear
        }

        if let mustacheString = mustache,
           let mustache = Mustache(rawValue: mustacheString) {
            customization.mustache = mustache
        }

        if let flowerString = flower,
           let flower = Flower(rawValue: flowerString) {
            customization.flower = flower
        }

        if let petString = pet,
           let pet = Pet(rawValue: petString) {
            customization.pet = pet
        }

        if let shieldString = shield,
           let shield = Shield(rawValue: shieldString) {
            customization.shield = shield
        }

        if let wingsString = wings,
           let wings = Wings(rawValue: wingsString) {
            customization.wings = wings
        }

        print("🔧 CharacterCustomizationEntity: Final customization outfit: \(customization.outfit.rawValue)")
        return customization
    }

    func updateFrom(_ customization: CharacterCustomization) {
        print("🔧 CharacterCustomizationEntity: updateFrom called")
        print("🔧 CharacterCustomizationEntity: Setting outfit from '\(outfit ?? "nil")' to '\(customization.outfit.rawValue)'")
        
        bodyType = customization.bodyType.rawValue
        hairStyle = customization.hairStyle.rawValue
        hairBackStyle = customization.hairBackStyle?.rawValue
        hairColor = customization.hairColor.rawValue
        eyeColor = customization.eyeColor.rawValue
        outfit = customization.outfit.rawValue
        weapon = customization.weapon.rawValue
        accessory = customization.accessory?.rawValue
        headGear = customization.headGear?.rawValue
        mustache = customization.mustache?.rawValue
        flower = customization.flower?.rawValue
        pet = customization.pet?.rawValue
        shield = customization.shield?.rawValue
        wings = customization.wings?.rawValue
        
        print("🔧 CharacterCustomizationEntity: outfit field set to: \(outfit ?? "nil")")
    }
}
