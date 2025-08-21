//
//  CharacterCustomizationService.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 7.01.2025.
//

import Foundation
import CoreData

// MARK: - Character Customization Service Protocol

protocol CharacterCustomizationServiceProtocol {
    func fetchCustomization(for user: UserEntity) -> CharacterCustomizationEntity?
    func createCustomization(for user: UserEntity, customization: CharacterCustomization) -> CharacterCustomizationEntity?
    func updateCustomization(_ entity: CharacterCustomizationEntity, with customization: CharacterCustomization)
    func deleteCustomization(_ entity: CharacterCustomizationEntity)
    func migrateFromUserDefaults(for user: UserEntity, manager: CharacterCustomizationManager) -> CharacterCustomizationEntity?
}

// MARK: - Character Customization Service Implementation

final class CharacterCustomizationService: CharacterCustomizationServiceProtocol {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    init(container: NSPersistentContainer = PersistenceController.shared.container) {
        self.container = container
        self.context = container.viewContext
    }
    
    // MARK: - CRUD Operations
    
    func fetchCustomization(for user: UserEntity) -> CharacterCustomizationEntity? {
        let request: NSFetchRequest<CharacterCustomizationEntity> = CharacterCustomizationEntity.fetchRequest()
        request.predicate = NSPredicate(format: "user == %@", user)
        request.fetchLimit = 1
        
        do {
            return try context.fetch(request).first
        } catch {
            print("❌ Error fetching character customization: \(error)")
            return nil
        }
    }
    
    func createCustomization(for user: UserEntity, customization: CharacterCustomization) -> CharacterCustomizationEntity? {
        let entity = CharacterCustomizationEntity(context: context)
        entity.id = UUID()
        entity.userId = user.id
        entity.user = user
        entity.createdAt = Date()
        entity.updateFrom(customization)
        
        do {
            try context.save()
            return entity
        } catch {
            print("❌ Error creating character customization: \(error)")
            return nil
        }
    }
    
    func updateCustomization(_ entity: CharacterCustomizationEntity, with customization: CharacterCustomization) {
        entity.updateFrom(customization)
        saveContext()
    }
    
    func deleteCustomization(_ entity: CharacterCustomizationEntity) {
        context.delete(entity)
        saveContext()
    }
    
    // MARK: - Migration Support
    
    func migrateFromUserDefaults(for user: UserEntity, manager: CharacterCustomizationManager) -> CharacterCustomizationEntity? {
        // Check if customization already exists
        if let existing = fetchCustomization(for: user) {
            return existing
        }
        
        // Create new customization from UserDefaults data
        return createCustomization(for: user, customization: manager.currentCustomization)
    }
    
    // MARK: - Utility Methods
    
    func getOrCreateCustomization(for user: UserEntity) -> CharacterCustomizationEntity? {
        if let existing = fetchCustomization(for: user) {
            return existing
        }
        
        // Create default customization
        let defaultCustomization = CharacterCustomization()
        return createCustomization(for: user, customization: defaultCustomization)
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("❌ Error saving character customization context: \(error)")
        }
    }
}

// MARK: - Character Customization Extensions

extension CharacterCustomizationEntity {
    /// Convenience method to check if the user owns a specific customization item
    func ownsCustomizationItem(category: CustomizationCategory, itemId: String) -> Bool {
        guard let user = user else { return false }
        
        let items = user.customizationItems?.allObjects as? [CustomizationItemEntity] ?? []
        return items.contains { item in
            item.category == category.rawValue &&
            item.name == itemId &&
            item.isUnlocked
        }
    }
    
    /// Gets all owned items for a specific category
    func getOwnedItems(for category: CustomizationCategory) -> [CustomizationItemEntity] {
        guard let user = user else { return [] }
        
        let items = user.customizationItems?.allObjects as? [CustomizationItemEntity] ?? []
        return items.filter { item in
            item.category == category.rawValue && item.isUnlocked
        }
    }
    
    /// Gets currently equipped item for a category
    func getEquippedItem(for category: CustomizationCategory) -> CustomizationItemEntity? {
        guard let user = user else { return nil }
        
        let items = user.customizationItems?.allObjects as? [CustomizationItemEntity] ?? []
        return items.first { item in
            item.category == category.rawValue && item.isEquipped
        }
    }
}
