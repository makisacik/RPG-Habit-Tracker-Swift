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
    @NSManaged public var skinColor: String?
    @NSManaged public var hairStyle: String?
    @NSManaged public var hairColor: String?
    @NSManaged public var eyeColor: String?
    @NSManaged public var outfit: String?
    @NSManaged public var weapon: String?
    @NSManaged public var accessories: String?
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
        guard let accessories = accessories,
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
            self.accessories = jsonString
        }
    }
    
    /// Converts to CharacterCustomization model
    func toCharacterCustomization() -> CharacterCustomization {
        var customization = CharacterCustomization()
        
        if let bodyTypeString = bodyType,
           let bodyType = BodyType(rawValue: bodyTypeString) {
            customization.bodyType = bodyType
        }
        
        if let skinColorString = skinColor,
           let skinColor = SkinColor(rawValue: skinColorString) {
            customization.skinColor = skinColor
        }
        
        if let hairStyleString = hairStyle,
           let hairStyle = HairStyle(rawValue: hairStyleString) {
            customization.hairStyle = hairStyle
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
        }
        
        if let weaponString = weapon,
           let weapon = CharacterWeapon(rawValue: weaponString) {
            customization.weapon = weapon
        }
        
        // Handle accessories (first one for now, since CharacterCustomization only supports one)
        let accessoriesArray = self.accessoriesArray
        if let firstAccessory = accessoriesArray.first,
           let accessory = Accessory(rawValue: firstAccessory) {
            customization.accessory = accessory
        }
        
        return customization
    }
    
    /// Updates from CharacterCustomization model
    func updateFrom(_ customization: CharacterCustomization) {
        bodyType = customization.bodyType.rawValue
        skinColor = customization.skinColor.rawValue
        hairStyle = customization.hairStyle.rawValue
        hairColor = customization.hairColor.rawValue
        eyeColor = customization.eyeColor.rawValue
        outfit = customization.outfit.rawValue
        weapon = customization.weapon.rawValue
        
        // Handle accessories
        var accessoriesArray: [String] = []
        if let accessory = customization.accessory {
            accessoriesArray.append(accessory.rawValue)
        }
        setAccessories(accessoriesArray)
        
        updatedAt = Date()
    }
}
