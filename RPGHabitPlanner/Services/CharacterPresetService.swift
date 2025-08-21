//
//  CharacterPresetService.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 7.01.2025.
//

import Foundation
import CoreData

// MARK: - Character Preset Service Protocol

protocol CharacterPresetServiceProtocol {
    func fetchPresets(for user: UserEntity) -> [CharacterPresetEntity]
    func fetchDefaultPreset(for user: UserEntity) -> CharacterPresetEntity?
    func createPreset(for user: UserEntity, name: String, customization: CharacterCustomization, isDefault: Bool) -> CharacterPresetEntity?
    func updatePreset(_ preset: CharacterPresetEntity, name: String, customization: CharacterCustomization)
    func setAsDefault(_ preset: CharacterPresetEntity)
    func deletePreset(_ preset: CharacterPresetEntity)
    func duplicatePreset(_ preset: CharacterPresetEntity, newName: String) -> CharacterPresetEntity?
}

// MARK: - Character Preset Service Implementation

final class CharacterPresetService: CharacterPresetServiceProtocol {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    init(container: NSPersistentContainer = PersistenceController.shared.container) {
        self.container = container
        self.context = container.viewContext
    }
    
    // MARK: - Fetch Operations
    
    func fetchPresets(for user: UserEntity) -> [CharacterPresetEntity] {
        let request: NSFetchRequest<CharacterPresetEntity> = CharacterPresetEntity.fetchRequest()
        request.predicate = NSPredicate(format: "user == %@", user)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \CharacterPresetEntity.isDefault, ascending: false),
            NSSortDescriptor(keyPath: \CharacterPresetEntity.createdAt, ascending: true)
        ]
        
        do {
            return try context.fetch(request)
        } catch {
            print("❌ Error fetching character presets: \(error)")
            return []
        }
    }
    
    func fetchDefaultPreset(for user: UserEntity) -> CharacterPresetEntity? {
        let request: NSFetchRequest<CharacterPresetEntity> = CharacterPresetEntity.fetchRequest()
        request.predicate = NSPredicate(format: "user == %@ AND isDefault == YES", user)
        request.fetchLimit = 1
        
        do {
            return try context.fetch(request).first
        } catch {
            print("❌ Error fetching default preset: \(error)")
            return nil
        }
    }
    
    // MARK: - CRUD Operations
    
    func createPreset(for user: UserEntity, name: String, customization: CharacterCustomization, isDefault: Bool = false) -> CharacterPresetEntity? {
        // If setting as default, clear other default presets
        if isDefault {
            clearDefaultPresets(for: user)
        }
        
        let preset = CharacterPresetEntity.create(
            name: name,
            customization: customization,
            isDefault: isDefault,
            user: user,
            context: context
        )
        
        do {
            try context.save()
            return preset
        } catch {
            print("❌ Error creating character preset: \(error)")
            return nil
        }
    }
    
    func updatePreset(_ preset: CharacterPresetEntity, name: String, customization: CharacterCustomization) {
        preset.name = name
        preset.setCustomization(customization)
        saveContext()
    }
    
    func setAsDefault(_ preset: CharacterPresetEntity) {
        guard let user = preset.user else { return }
        
        // Clear other default presets
        clearDefaultPresets(for: user)
        
        // Set this as default
        preset.isDefault = true
        saveContext()
    }
    
    func deletePreset(_ preset: CharacterPresetEntity) {
        context.delete(preset)
        saveContext()
    }
    
    func duplicatePreset(_ preset: CharacterPresetEntity, newName: String) -> CharacterPresetEntity? {
        guard let user = preset.user,
              let customization = preset.characterCustomization else { return nil }
        
        return createPreset(for: user, name: newName, customization: customization, isDefault: false)
    }
    
    // MARK: - Utility Methods
    
    private func clearDefaultPresets(for user: UserEntity) {
        let presets = fetchPresets(for: user)
        presets.forEach { $0.isDefault = false }
    }
    
    func createDefaultPreset(for user: UserEntity, customization: CharacterCustomization) -> CharacterPresetEntity? {
        return createPreset(
            for: user,
            name: "Default Character",
            customization: customization,
            isDefault: true
        )
    }
    
    func getPresetNames(for user: UserEntity) -> [String] {
        return fetchPresets(for: user).compactMap { $0.name }
    }
    
    func presetExists(for user: UserEntity, name: String) -> Bool {
        let presets = fetchPresets(for: user)
        return presets.contains { $0.name?.lowercased() == name.lowercased() }
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("❌ Error saving character preset context: \(error)")
        }
    }
}

// MARK: - Preset Management Extensions

extension CharacterPresetService {
    
    /// Applies a preset to the user's current customization
    func applyPreset(_ preset: CharacterPresetEntity, to customizationEntity: CharacterCustomizationEntity) {
        guard let customization = preset.characterCustomization else { return }
        
        customizationEntity.updateFrom(customization)
        saveContext()
    }
    
    /// Creates a preset from current customization
    func createPresetFromCurrent(_ customizationEntity: CharacterCustomizationEntity, name: String) -> CharacterPresetEntity? {
        guard let user = customizationEntity.user else { return nil }
        
        let customization = customizationEntity.toCharacterCustomization()
        return createPreset(for: user, name: name, customization: customization)
    }
    
    /// Gets quick preset suggestions based on themes
    func getPresetSuggestions(for user: UserEntity) -> [CharacterPresetEntity] {
        let suggestions: [(String, CharacterCustomization)] = [
            ("Knight", createKnightPreset()),
            ("Archer", createArcherPreset()),
            ("Mage", createMagePreset()),
            ("Assassin", createAssassinPreset())
        ]
        
        var presets: [CharacterPresetEntity] = []
        for (name, customization) in suggestions {
            if let preset = createPreset(for: user, name: name, customization: customization) {
                presets.append(preset)
            }
        }
        
        return presets
    }
    
    // MARK: - Preset Templates
    
    private func createKnightPreset() -> CharacterCustomization {
        var customization = CharacterCustomization()
        customization.outfit = .iron
        customization.weapon = .swordIron
        customization.bodyType = .body1
        return customization
    }
    
    private func createArcherPreset() -> CharacterCustomization {
        var customization = CharacterCustomization()
        customization.outfit = .simple
        customization.weapon = .swordDagger
        customization.bodyType = .body2
        return customization
    }
    
    private func createMagePreset() -> CharacterCustomization {
        var customization = CharacterCustomization()
        customization.outfit = .dress
        customization.weapon = .swordDagger
        customization.accessory = .eyeglassBlue
        return customization
    }
    
    private func createAssassinPreset() -> CharacterCustomization {
        var customization = CharacterCustomization()
        customization.outfit = .assassin
        customization.weapon = .swordDeadly
        customization.hairStyle = .punk
        return customization
    }
}