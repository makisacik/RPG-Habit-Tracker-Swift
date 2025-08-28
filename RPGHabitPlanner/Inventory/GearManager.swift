//
//  GearManager.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 5.08.2025.
//

import Foundation
import Combine
import CoreData

// MARK: - Gear Manager

/// Manages equipped gear items and their effects on character appearance and stats
class GearManager: ObservableObject {
    // MARK: - Singleton Implementation
    
    private static var _shared: GearManager?
    private static let lock = NSLock()
    
    static var shared: GearManager {
        lock.lock()
        defer { lock.unlock() }
        
        if _shared == nil {
            _shared = GearManager()
        }
        return _shared!
    }
    
    // MARK: - Published Properties
    
    @Published var equippedItems: [GearCategory: ItemEntity] = [:]
    @Published var characterStats = CharacterStats()
    
    // MARK: - Private Properties
    
    private let customizationService = CharacterCustomizationService()
    private let inventoryManager = InventoryManager.shared
    private var cancellables = Set<AnyCancellable>()

    
    // MARK: - Initialization
    
    private init() {
        loadEquippedItems()
        calculateStats()
        
        // Listen for inventory changes to refresh equipped items
        NotificationCenter.default.publisher(for: .inventoryUpdated)
            .sink { [weak self] _ in
                self?.loadEquippedItems()
                self?.calculateStats()
            }
            .store(in: &cancellables)
        
        // Listen for language changes to refresh item names
        NotificationCenter.default.publisher(for: .languageChanged)
            .sink { [weak self] _ in
                print("🔄 GearManager: Language changed, refreshing gear display")
                DispatchQueue.main.async {
                    self?.objectWillChange.send()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Equipment Management
    
    /// Equips an item to the specified gear slot
    /// - Parameters:
    ///   - item: The item to equip
    ///   - category: The gear category to equip to
    ///   - user: The user entity
    func equipItem(_ item: ItemEntity, to category: GearCategory, for user: UserEntity) {
        print("🔧 GearManager: Attempting to equip \(item.name ?? "Unknown") to \(category.rawValue)")
        
        
        // Unequip current item if any
        unequipItem(from: category, for: user)
        
        // Equip new item
        equippedItems[category] = item
        
        // Update character customization if applicable
        updateCharacterCustomization(for: user)
        
        // Calculate new stats
        calculateStats()
        
        // Save equipped items
        saveEquippedItems()
        
        // Post notification for UI updates
        NotificationCenter.default.post(name: .gearUpdated, object: nil)
        
        print("✅ GearManager: Successfully equipped \(item.name ?? "Unknown") to \(category.rawValue)")
    }
    
    /// Unequips an item from the specified gear slot
    /// - Parameters:
    ///   - category: The gear category to unequip from
    ///   - user: The user entity
    func unequipItem(from category: GearCategory, for user: UserEntity) {
        guard let equippedItem = equippedItems[category] else { return }
        
        // Remove from equipped items
        equippedItems.removeValue(forKey: category)
        
        // Update character customization if applicable
        updateCharacterCustomization(for: user)
        
        // Calculate new stats
        calculateStats()
        
        // Save equipped items
        saveEquippedItems()
        
        // Post notification for UI updates
        NotificationCenter.default.post(name: .gearUpdated, object: nil)
        
        print("✅ GearManager: Unequipped \(equippedItem.name ?? "Unknown") from \(category.rawValue)")
    }
    
    /// Gets the currently equipped item for a gear category
    /// - Parameter category: The gear category
    /// - Returns: The equipped item, if any
    func getEquippedItem(for category: GearCategory) -> ItemEntity? {
        return equippedItems[category]
    }
    
    /// Checks if an item is currently equipped
    /// - Parameter item: The item to check
    /// - Returns: True if the item is equipped
    func isItemEquipped(_ item: ItemEntity) -> Bool {
        return equippedItems.values.contains { $0.objectID == item.objectID }
    }
    
    /// Refreshes character customization from currently equipped gear
    /// - Parameter user: The user entity
    func refreshCharacterCustomizationFromGear(for user: UserEntity) {
        print("🔄 GearManager: Refreshing character customization from equipped gear")
        updateCharacterCustomization(for: user)
    }
    
    // MARK: - Character Customization Updates
    
    private func updateCharacterCustomization(for user: UserEntity) {
        guard let customization = getCurrentCustomization(for: user) else { return }
        
        print("🔧 GearManager: Current equipped items: \(equippedItems.keys.map { $0.rawValue })")
        for (category, item) in equippedItems {
            print("🔧 GearManager: \(category.rawValue): \(item.name ?? "Unknown")")
        }
        
        var updatedCustomization = customization
        
        // Update outfit if equipped
        if let outfitItem = equippedItems[.outfit] {
            print("🔧 GearManager: Attempting to map outfit: \(outfitItem.name ?? "Unknown")")
            if let outfit = mapItemToOutfit(outfitItem) {
                updatedCustomization.outfit = outfit
                print("✅ GearManager: Successfully mapped outfit to: \(outfit.rawValue)")
                print("🔧 GearManager: Updated customization outfit field to: \(updatedCustomization.outfit?.rawValue ?? "nil")")
            } else {
                print("❌ GearManager: Failed to map outfit item: \(outfitItem.name ?? "Unknown")")
            }
        } else {
            // Clear outfit if no outfit is equipped
            updatedCustomization.outfit = nil
            print("🔧 GearManager: Cleared outfit (no outfit equipped)")
        }
        
        // Update weapon if equipped
        if let weaponItem = equippedItems[.weapon] {
            print("🔧 GearManager: Attempting to map weapon: \(weaponItem.name ?? "Unknown")")
            if let weapon = mapItemToWeapon(weaponItem) {
                updatedCustomization.weapon = weapon
                print("✅ GearManager: Successfully mapped weapon to: \(weapon.rawValue)")
            }
        } else {
            // Clear weapon if no weapon is equipped
            updatedCustomization.weapon = nil
            print("🔧 GearManager: Cleared weapon (no weapon equipped)")
        }
        
        // Update shield if equipped
        if let shieldItem = equippedItems[.shield] {
            print("🔧 GearManager: Attempting to map shield: \(shieldItem.name ?? "Unknown")")
            if let shield = mapItemToShield(shieldItem) {
                updatedCustomization.shield = shield
                print("✅ GearManager: Successfully mapped shield to: \(shield.rawValue)")
            } else {
                print("❌ GearManager: Failed to map shield item: \(shieldItem.name ?? "Unknown")")
            }
        } else {
            // Clear shield if no shield item is equipped
            updatedCustomization.shield = nil
            print("🔧 GearManager: Cleared shield (no shield equipped)")
        }
        
        // Update head gear if equipped
        if let headItem = equippedItems[.head] {
            print("🔧 GearManager: Attempting to map head item: \(headItem.name ?? "Unknown")")
            if let headGear = mapItemToHeadGear(headItem) {
                updatedCustomization.headGear = headGear
                print("✅ GearManager: Successfully mapped head item to headGear: \(headGear.rawValue)")
            }
        } else {
            // Clear headGear if no head item is equipped
            updatedCustomization.headGear = nil
            print("🔧 GearManager: Cleared headGear (no head item equipped)")
        }
        
        // Update wings if equipped
        if let wingsItem = equippedItems[.wings] {
            print("🔧 GearManager: Attempting to map wings item: \(wingsItem.name ?? "Unknown")")
            if let wings = mapItemToWings(wingsItem) {
                updatedCustomization.wings = wings
                print("✅ GearManager: Successfully mapped wings item to wings: \(wings.rawValue)")
            }
        } else {
            // Clear wings if no wings are equipped
            updatedCustomization.wings = nil
            print("🔧 GearManager: Cleared wings (no wings equipped)")
        }
        
        // Update pet if equipped
        if let petItem = equippedItems[.pet] {
            print("🔧 GearManager: Attempting to map pet item: \(petItem.name ?? "Unknown")")
            if let pet = mapItemToPet(petItem) {
                updatedCustomization.pet = pet
                print("✅ GearManager: Successfully mapped pet item to pet: \(pet.rawValue)")
            } else {
                print("❌ GearManager: Failed to map pet item: \(petItem.name ?? "Unknown")")
            }
        } else {
            // Clear pet if no pet is equipped
            updatedCustomization.pet = nil
            print("🔧 GearManager: Cleared pet (no pet equipped)")
        }
        
        // Note: Shield gear is not part of character customization
        // It would be handled separately in the character display system
        
        // Save the updated customization
        print("🔧 GearManager: About to save customization with outfit: \(updatedCustomization.outfit?.rawValue ?? "nil")")
        print("🔧 GearManager: Calling customizationService.updateCustomization...")
        
        let result = customizationService.updateCustomization(for: user, customization: updatedCustomization)
        
        if let _ = result {
            print("✅ GearManager: Successfully saved updated customization")
            print("🔧 GearManager: Final saved outfit: \(updatedCustomization.outfit?.rawValue ?? "nil")")
        } else {
            print("❌ GearManager: Failed to save updated customization - updateCustomization returned nil")
        }
        
        // Post notification to refresh character view
        NotificationCenter.default.post(name: .characterCustomizationUpdated, object: nil)
    }
    
    private func getCurrentCustomization(for user: UserEntity) -> CharacterCustomization? {
        if let entity = customizationService.fetchCustomization(for: user) {
            return entity.toCharacterCustomization()
        }
        return nil
    }
    
    
    // MARK: - Asset Name Mapping
    
    private func getActualAssetName(from iconName: String) -> String {
        // Convert preview asset names to actual asset names using the String extension
        return iconName.actualAssetName
    }
    
    // MARK: - Item Mapping
    
    private func mapItemToOutfit(_ item: ItemEntity) -> Outfit? {
        // Map item icon names to outfit enums based on actual asset names
        guard let iconName = item.iconName else { return nil }
        
        let actualAssetName = getActualAssetName(from: iconName)
        print("🔧 GearManager: Attempting to map outfit item: \(item.name ?? "unknown") with icon: \(iconName) -> actual: \(actualAssetName)")
        
        switch actualAssetName {
        case "char_outfit_villager":
            print("✅ GearManager: Mapped '\(iconName)' to .outfitVillager")
            return .outfitVillager
        case "char_outfit_villager_blue":
            print("✅ GearManager: Mapped '\(iconName)' to .outfitVillagerBlue")
            return .outfitVillagerBlue
        case "char_outfit_iron":
            print("✅ GearManager: Mapped '\(iconName)' to .outfitIron")
            return .outfitIron
        case "char_outfit_iron_2":
            print("✅ GearManager: Mapped '\(iconName)' to .outfitIron2")
            return .outfitIron2
        case "char_outfit_wizard":
            print("✅ GearManager: Mapped '\(iconName)' to .outfitWizard")
            return .outfitWizard
        case "char_outfit_dress":
            print("✅ GearManager: Mapped '\(iconName)' to .outfitDress")
            return .outfitDress
        case "char_outfit_fire":
            print("✅ GearManager: Mapped '\(iconName)' to .outfitFire")
            return .outfitFire
        case "char_outfit_bat":
            print("✅ GearManager: Mapped '\(iconName)' to .outfitBat")
            return .outfitBat
        case "char_outfit_red":
            print("✅ GearManager: Mapped '\(iconName)' to .outfitRed")
            return .outfitRed
        case "char_outfit_hoodie":
            print("✅ GearManager: Mapped '\(iconName)' to .outfitHoodie")
            return .outfitHoodie
        default:
            print("❌ GearManager: No outfit mapping found for item: \(item.name ?? "unknown") with icon: \(iconName) -> actual: \(actualAssetName)")
            return nil
        }
    }
    
    private func mapItemToWeapon(_ item: ItemEntity) -> CharacterWeapon? {
        // Map item icon names to weapon enums based on actual asset names
        guard let iconName = item.iconName else { return nil }
        
        let actualAssetName = getActualAssetName(from: iconName)
        print("🔧 GearManager: Attempting to map weapon: \(item.name ?? "unknown") with icon: \(iconName) -> actual: \(actualAssetName)")
        
        switch actualAssetName {
        case "char_sword_wood":
            return .swordWood
        case "char_sword_copper":
            return .swordCopper
        case "char_sword_iron":
            return .swordIron
        case "char_sword_steel":
            return .swordSteel
        case "char_sword_gold":
            return .swordGold
        case "char_sword_red":
            return .swordRed
        case "char_sword_red_2":
            return .swordRed2
        case "char_sword_deadly":
            return .swordDeadly
        case "char_sword_axe":
            return .swordAxe
        case "char_sword_axe_small":
            return .swordAxeSmall
        case "char_sword_whip":
            return .swordWhip
        case "char_sword_staff":
            return .swordStaff
        case "char_sword_mace":
            return .swordMace
        default:
            print("⚠️ GearManager: No weapon mapping found for item: \(item.name ?? "unknown") with icon: \(iconName) -> actual: \(actualAssetName)")
            return nil
        }
    }
    
    private func mapItemToHeadGear(_ item: ItemEntity) -> HeadGear? {
        // Map item icon names to headGear enums based on actual asset names
        guard let iconName = item.iconName else { return nil }
        
        let actualAssetName = getActualAssetName(from: iconName)
        
        switch actualAssetName {
        case "char_helmet_hood":
            return .helmetHood
        case "char_helmet_iron":
            return .helmetIron
        case "char_helmet_red":
            return .helmetRed
        default:
            print("⚠️ GearManager: No headGear mapping found for item: \(item.name ?? "unknown") with icon: \(iconName) -> actual: \(actualAssetName)")
            return nil
        }
    }
    
    private func mapItemToShield(_ item: ItemEntity) -> Shield? {
        // Map item icon names to shield enums based on actual asset names
        guard let iconName = item.iconName else { return nil }
        
        let actualAssetName = getActualAssetName(from: iconName)
        
        switch actualAssetName {
        case "char_shield_wood":
            return .shieldWood
        case "char_shield_red":
            return .shieldRed
        case "char_shield_iron":
            return .shieldIron
        case "char_shield_gold":
            return .shieldGold
        default:
            print("⚠️ GearManager: No shield mapping found for item: \(item.name ?? "unknown") with icon: \(iconName) -> actual: \(actualAssetName)")
            return nil
        }
    }
    
    private func mapItemToWings(_ item: ItemEntity) -> Wings? {
        // Map item icon names to wings based on actual asset names
        guard let iconName = item.iconName else { return nil }
        
        let actualAssetName = getActualAssetName(from: iconName)
        
        switch actualAssetName {
        case "char_wings_white":
            return .wingsWhite
        case "char_wings_red":
            return .wingsRed
        case "char_wings_red_2":
            return .wingsRed2
        case "char_wings_bat":
            return .wingsBat
        default:
            print("⚠️ GearManager: No wings mapping found for item: \(item.name ?? "unknown") with icon: \(iconName) -> actual: \(actualAssetName)")
            return nil
        }
    }
    
    private func mapItemToPet(_ item: ItemEntity) -> Pet? {
        // Map item icon names to pet enums based on actual asset names
        guard let iconName = item.iconName else { return nil }
        
        let actualAssetName = getActualAssetName(from: iconName)
        
        switch actualAssetName {
        case "char_pet_cat":
            return .petCat
        case "char_pet_cat_2":
            return .petCat2
        case "char_pet_chicken":
            return .petChicken
        default:
            print("⚠️ GearManager: No pet mapping found for item: \(item.name ?? "unknown") with icon: \(iconName) -> actual: \(actualAssetName)")
            return nil
        }
    }
    
    
    // MARK: - Stats Calculation
    
    private func calculateStats() {
        var newStats = CharacterStats()
        
        for (_, item) in equippedItems {
            // Add item stats to character stats
            if let rarity = getItemRarity(item) {
                let rarityMultiplier = getRarityMultiplier(rarity)
                newStats.damage += Int(Double(getItemDamage(item)) * rarityMultiplier)
                newStats.armor += Int(Double(getItemArmor(item)) * rarityMultiplier)
            }
        }
        
        characterStats = newStats
    }
    
    private func getItemRarity(_ item: ItemEntity) -> ItemRarity? {
        guard let rarityString = item.rarity else { return nil }
        return ItemRarity(rawValue: rarityString)
    }
    
    private func getRarityMultiplier(_ rarity: ItemRarity) -> Double {
        switch rarity {
        case .common: return 1.0
        case .uncommon: return 1.2
        case .rare: return 1.5
        case .epic: return 2.0
        case .legendary: return 3.0
        }
    }
    
    private func getItemDamage(_ item: ItemEntity) -> Int {
        // This is a simplified calculation - you might need a more sophisticated system
        guard let itemName = item.name?.lowercased() else { return 0 }
        
        if itemName.contains("sword") {
            return 10
        } else if itemName.contains("axe") {
            return 15
        } else if itemName.contains("bow") {
            return 8
        }
        
        return 0
    }
    
    private func getItemArmor(_ item: ItemEntity) -> Int {
        // This is a simplified calculation - you might need a more sophisticated system
        guard let itemName = item.name?.lowercased() else { return 0 }
        
        if itemName.contains("helmet") {
            return 5
        } else if itemName.contains("armor") {
            return 15
        } else if itemName.contains("shield") {
            return 10
        }
        
        return 0
    }
    
    // MARK: - Persistence
    
    private func saveEquippedItems() {
        // Save equipped items to UserDefaults using only the object ID URIs as strings
        var equippedItemIds: [String: String] = [:]
        
        for (category, item) in equippedItems {
            equippedItemIds[category.rawValue] = item.objectID.uriRepresentation().absoluteString
        }
        
        UserDefaults.standard.set(equippedItemIds, forKey: "equippedGearItems")
    }
    
    private func loadEquippedItems() {
        // Load equipped items from UserDefaults or Core Data
        // This is a simplified implementation
        guard let equippedItemIds = UserDefaults.standard.dictionary(forKey: "equippedGearItems") as? [String: String] else { return }
        
        for (categoryString, itemUriString) in equippedItemIds {
            guard let category = GearCategory(rawValue: categoryString),
                  let itemUri = URL(string: itemUriString),
                  let itemObjectID = PersistenceController.shared.container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: itemUri),
                  let item = try? PersistenceController.shared.container.viewContext.existingObject(with: itemObjectID) as? ItemEntity else { continue }
            
            // Only add the item if it still exists in the inventory
            if inventoryManager.inventoryItems.contains(where: { $0.objectID == item.objectID }) {
                equippedItems[category] = item
            }
        }
    }
}

// MARK: - Character Stats

struct CharacterStats {
    var damage: Int = 0
    var armor: Int = 0
    
    // Base stats
    var baseDamage: Int = 10
    var baseArmor: Int = 5
    
    var totalDamage: Int {
        return baseDamage + damage
    }
    
    var totalArmor: Int {
        return baseArmor + armor
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let gearUpdated = Notification.Name("gearUpdated")
}
