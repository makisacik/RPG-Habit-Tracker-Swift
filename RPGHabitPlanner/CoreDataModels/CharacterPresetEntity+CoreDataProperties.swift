//
//  CharacterPresetEntity+CoreDataProperties.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 7.01.2025.
//
//

import Foundation
import CoreData

extension CharacterPresetEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CharacterPresetEntity> {
        return NSFetchRequest<CharacterPresetEntity>(entityName: "CharacterPresetEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var customizationData: String?
    @NSManaged public var isDefault: Bool
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var user: UserEntity?

}

extension CharacterPresetEntity : Identifiable {

}

// MARK: - Convenience Methods
extension CharacterPresetEntity {
    
    /// Converts customization data JSON to CharacterCustomization
    var characterCustomization: CharacterCustomization? {
        guard let customizationData = customizationData,
              let data = customizationData.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(CharacterCustomization.self, from: data)
    }
    
    /// Sets customization data from CharacterCustomization
    func setCustomization(_ customization: CharacterCustomization) {
        if let data = try? JSONEncoder().encode(customization),
           let jsonString = String(data: data, encoding: .utf8) {
            self.customizationData = jsonString
        }
        updatedAt = Date()
    }
    
    /// Creates a new preset with the given customization
    static func create(
        name: String,
        customization: CharacterCustomization,
        isDefault: Bool = false,
        user: UserEntity,
        context: NSManagedObjectContext
    ) -> CharacterPresetEntity {
        let preset = CharacterPresetEntity(context: context)
        preset.id = UUID()
        preset.name = name
        preset.isDefault = isDefault
        preset.user = user
        preset.createdAt = Date()
        preset.updatedAt = Date()
        preset.setCustomization(customization)
        return preset
    }
}