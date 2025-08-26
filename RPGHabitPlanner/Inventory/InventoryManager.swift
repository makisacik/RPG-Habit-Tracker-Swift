//
//  InventoryManager.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import Foundation
import Combine

// MARK: - Item Usage Protocol

/// Protocol defining how items should be used
protocol ItemUsageHandler {
    func useItem(_ item: Item, completion: @escaping (Bool, Error?) -> Void)
}

// MARK: - Inventory Manager

/// Manages the player's inventory, including items, active effects, and item usage
class InventoryManager: ObservableObject {
    // MARK: - Singleton Implementation

    private static var _shared: InventoryManager?
    private static let lock = NSLock()

    static var shared: InventoryManager {
        lock.lock()
        defer { lock.unlock() }

        if _shared == nil {
            _shared = InventoryManager()
        }
        return _shared!
    }

    // MARK: - Published Properties

    @Published var inventoryItems: [ItemEntity] = []
    @Published var activeEffects: [ActiveEffect] = []

    // MARK: - Private Properties

    private let service: InventoryServiceProtocol
    private let activeEffectsService: ActiveEffectsServiceProtocol
    private let itemDatabase = ItemDatabase.shared
    private let userManager = UserManager()
    private lazy var usageHandler: ItemUsageHandler = {
        return DefaultItemUsageHandler(inventoryManager: self)
    }()

    // MARK: - Initialization

    private init() {
        self.service = InventoryService(container: PersistenceController.shared.container)
        self.activeEffectsService = ActiveEffectsCoreDataService(container: PersistenceController.shared.container)
        refreshInventory()
        loadActiveEffectsFromPersistence()
    }

    // MARK: - Inventory Management

    /// Refreshes the inventory from the data service
    func refreshInventory() {
        inventoryItems = service.fetchInventory()
        NotificationCenter.default.post(name: .inventoryUpdated, object: nil)
    }

    /// Adds an item to the inventory
    /// - Parameter item: The item to add
    func addToInventory(_ item: Item) {
        service.addItem(
            name: item.name,
            info: item.description,
            iconName: item.iconName,
            previewImage: item.previewImage,
            itemType: item.itemType.rawValue,
            gearCategory: item.gearCategory?.rawValue,
            accessoryCategory: item.accessoryCategory?.rawValue,
            rarity: item.rarity?.rawValue,
            value: Int32(item.value),
            collectionCategory: item.collectionCategory,
            isRare: item.isRare
        )
        refreshInventory()
    }

    /// Removes an item from the inventory
    /// - Parameter item: The item to remove
    func removeFromInventory(_ item: ItemEntity) {
        service.removeItem(item)
        refreshInventory()
    }

    /// Clears all items from the inventory
    func clearInventory() {
        service.clearInventory()
        refreshInventory()
    }

    // MARK: - Item Usage

    /// Uses an item from the inventory
    /// - Parameters:
    ///   - item: The item entity to use
    ///   - completion: Completion handler with success status and error
    func useItem(_ item: ItemEntity, completion: @escaping (Bool, Error?) -> Void) {
        guard let iconName = item.iconName,
              let itemDefinition = itemDatabase.findItem(byIconName: iconName) else {
            completion(false, InventoryError.invalidItem)
            return
        }

        usageHandler.useItem(itemDefinition) { [weak self] success, error in
            if success {
                self?.removeFromInventory(item)
            }
            completion(success, error)
        }
    }

    /// Equips a gear item from the inventory
    /// - Parameters:
    ///   - item: The item entity to equip
    ///   - completion: Completion handler with success status and error
    func equipItem(_ item: ItemEntity, completion: @escaping (Bool, Error?) -> Void) {
        guard isGear(item) else {
            completion(false, InventoryError.itemNotUsable)
            return
        }
        
        guard let gearCategory = getGearCategory(item) else {
            completion(false, InventoryError.invalidItem)
            return
        }
        
        // Get the current user
        userManager.fetchUser { [weak self] user, error in
            guard let user = user, error == nil else {
                completion(false, error ?? InventoryError.invalidItem)
                return
            }
            
            // Use GearManager to equip the item
            let gearManager = GearManager.shared
            gearManager.equipItem(item, to: gearCategory, for: user)
            
            completion(true, nil)
        }
    }

    // MARK: - Item Type Detection

    /// Gets the type of an item
    /// - Parameter item: The item to check
    /// - Returns: The item type if found
    func getItemType(_ item: ItemEntity) -> ItemType? {
        // First try to get from Core Data
        if let itemTypeString = item.itemType {
            return ItemType(rawValue: itemTypeString)
        }
        
        // Fallback to database lookup using icon name
        guard let iconName = item.iconName,
              let itemDefinition = itemDatabase.findItem(byIconName: iconName) else {
            return nil
        }
        return itemDefinition.itemType
    }

    /// Checks if an item is consumable
    /// - Parameter item: The item to check
    /// - Returns: True if the item is consumable
    func isConsumable(_ item: ItemEntity) -> Bool {
        return getItemType(item) == .consumable
    }

    /// Checks if an item is an accessory
    /// - Parameter item: The item to check
    /// - Returns: True if the item is an accessory
    func isAccessory(_ item: ItemEntity) -> Bool {
        return getItemType(item) == .accessory
    }

    /// Checks if an item is gear
    /// - Parameter item: The item to check
    /// - Returns: True if the item is gear
    func isGear(_ item: ItemEntity) -> Bool {
        return getItemType(item) == .gear
    }

    /// Checks if an item is a booster
    /// - Parameter item: The item to check
    /// - Returns: True if the item is a booster
    func isBooster(_ item: ItemEntity) -> Bool {
        return getItemType(item) == .booster
    }

    /// Checks if an item is a collectible
    /// - Parameter item: The item to check
    /// - Returns: True if the item is a collectible
    func isCollectible(_ item: ItemEntity) -> Bool {
        return getItemType(item) == .collectible
    }

    // MARK: - Active Effects Management

    /// Loads active effects from persistence
    func loadActiveEffectsFromPersistence() {
        let effects = activeEffectsService.fetchActiveEffects()
        DispatchQueue.main.async { [weak self] in
            self?.activeEffects = effects
            print("💾 InventoryManager: Loaded \(effects.count) active effects from persistence")

            // Refresh boosters after loading effects from persistence
            BoosterManager.shared.refreshBoostersFromPersistence()
        }
    }

    /// Adds an active effect to the inventory and persists it
    /// - Parameter effect: The effect to add
    func addActiveEffect(_ effect: ActiveEffect) {
        // Add to Core Data
        activeEffectsService.saveActiveEffect(effect)

        // Update local array
        activeEffects.append(effect)

        // Post notification for UI updates
        NotificationCenter.default.post(name: .activeEffectsChanged, object: nil)

        print("💾 InventoryManager: Added and persisted active effect \(effect.effect.type.rawValue)")
    }

    /// Removes an active effect from the inventory and persistence
    /// - Parameter effect: The effect to remove
    func removeActiveEffect(_ effect: ActiveEffect) {
        // Remove from Core Data
        activeEffectsService.removeActiveEffect(effect)

        // Update local array
        activeEffects.removeAll { $0.id == effect.id }

        // Post notification for UI updates
        NotificationCenter.default.post(name: .activeEffectsChanged, object: nil)

        print("💾 InventoryManager: Removed active effect from persistence")
    }

    /// Clears all expired effects from the inventory and persistence
    func clearExpiredEffects() {
        // Clear from Core Data
        activeEffectsService.clearExpiredEffects()

        // Update local array
        activeEffects.removeAll { !$0.isActive }

        // Post notification for UI updates
        NotificationCenter.default.post(name: .activeEffectsChanged, object: nil)

        print("💾 InventoryManager: Cleared expired effects from persistence")
    }

    /// Clears all active effects from the inventory and persistence
    func clearAllEffects() {
        // Clear from Core Data
        activeEffectsService.clearAllEffects()

        // Update local array
        activeEffects.removeAll()

        // Post notification for UI updates
        NotificationCenter.default.post(name: .activeEffectsChanged, object: nil)

        print("💾 InventoryManager: Cleared all effects from persistence")
    }

    // MARK: - Helper Methods

    /// Gets a random reward item
    /// - Returns: A random item from the database
    func getRandomReward() -> Item {
        return itemDatabase.getRandomItem()
    }

    /// Adds starter items to the inventory

    /// Adds specific items when onboarding is completed
    func addOnboardingCompletionItems(characterCustomization: CharacterCustomization? = nil) {
        // Add the requested weapons using icon names as IDs
        let weaponIconNames = ["char_sword_wood", "char_sword_iron"]
        for iconName in weaponIconNames {
            if let weaponItem = findItemByIconName(iconName) {
                addToInventory(weaponItem)
            }
        }
        
        // Add the requested outfits using icon names as IDs
        let outfitIconNames = ["char_outfit_villager", "char_outfit_villager_blue"]
        for iconName in outfitIconNames {
            if let outfitItem = findItemByIconName(iconName) {
                addToInventory(outfitItem)
            }
        }
        
        // Add the three eyeglasses using icon names as IDs
        let eyeglassIconNames = ["char_glass_blue", "char_glass_gray", "char_glass_red"]
        for iconName in eyeglassIconNames {
            if let eyeglassItem = findItemByIconName(iconName) {
                addToInventory(eyeglassItem)
            }
        }
        
        // Add the selected items from character customization if they're not already in the list
        if let customization = characterCustomization {
            // Add selected weapon if not already added
            let selectedWeaponIcon = customization.weapon?.rawValue ?? ""
            if !weaponIconNames.contains(selectedWeaponIcon) {
                if let weaponItem = findItemByIconName(selectedWeaponIcon) {
                    addToInventory(weaponItem)
                }
            }
            
            // Add selected outfit if not already added
            let selectedOutfitIcon = customization.outfit?.rawValue ?? ""
            if !outfitIconNames.contains(selectedOutfitIcon) {
                if let outfitItem = findItemByIconName(selectedOutfitIcon) {
                    addToInventory(outfitItem)
                }
            }
        }
        
        // Auto-equip the selected items from character customization
        autoEquipDefaultItems(characterCustomization: characterCustomization)
    }
    
    /// Automatically equips the default items selected during character creation
    private func autoEquipDefaultItems(characterCustomization: CharacterCustomization? = nil) {
        let gearManager = GearManager.shared
        
        // Get the current user
        userManager.fetchUser { [weak self] user, error in
            guard let user = user, error == nil else {
                print("❌ Failed to fetch user for auto-equipping items")
                return
            }
            
            // Ensure inventory is refreshed before trying to equip items
            DispatchQueue.main.async {
                self?.refreshInventory()
                
                // Add a small delay to ensure inventory is updated
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    // Use character customization if provided, otherwise use defaults
                    let weaponIconName = characterCustomization?.weapon?.rawValue ?? "char_sword_wood"
                    let outfitIconName = characterCustomization?.outfit?.rawValue ?? "char_outfit_villager"
                    
                    // Find and equip the selected weapon
                    if let weaponEntity = self?.inventoryItems.first(where: { $0.iconName == weaponIconName }) {
                        gearManager.equipItem(weaponEntity, to: .weapon, for: user)
                        print("✅ Auto-equipped weapon: \(weaponIconName)")
                    } else {
                        print("❌ Could not find weapon \(weaponIconName) in inventory for auto-equipping")
                    }
                    
                    // Find and equip the selected outfit
                    if let outfitEntity = self?.inventoryItems.first(where: { $0.iconName == outfitIconName }) {
                        gearManager.equipItem(outfitEntity, to: .outfit, for: user)
                        print("✅ Auto-equipped outfit: \(outfitIconName)")
                    } else {
                        print("❌ Could not find outfit \(outfitIconName) in inventory for auto-equipping")
                    }
                }
            }
        }
    }
    
    
    /// Helper method to find an item by its icon name (asset ID)
    /// - Parameter iconName: The icon name to search for
    /// - Returns: The item if found, nil otherwise
    private func findItemByIconName(_ iconName: String) -> Item? {
        return itemDatabase.findItem(byIconName: iconName)
    }

    /// Gets all items of a specific type
    /// - Parameter type: The item type to filter by
    /// - Returns: Array of items of the specified type
    func getItems(of type: ItemType) -> [Item] {
        return itemDatabase.getItems(of: type)
    }

    /// Gets all items of a specific rarity (only for gear items)
    /// - Parameter rarity: The item rarity to filter by
    /// - Returns: Array of items of the specified rarity
    func getItems(of rarity: ItemRarity) -> [Item] {
        return itemDatabase.getItems(of: rarity)
    }

    /// Gets all gear items of a specific category
    /// - Parameter category: The gear category to filter by
    /// - Returns: Array of gear items of the specified category
    func getGearItems(of category: GearCategory) -> [Item] {
        return itemDatabase.getGearItems(of: category)
    }

    /// Gets all gear items of a specific category and rarity
    /// - Parameters:
    ///   - category: The gear category to filter by
    ///   - rarity: The item rarity to filter by
    /// - Returns: Array of gear items of the specified category and rarity
    func getGearItems(of category: GearCategory, rarity: ItemRarity) -> [Item] {
        return itemDatabase.getGearItems(of: category, rarity: rarity)
    }

    /// Gets all accessory items of a specific category
    /// - Parameter category: The accessory category to filter by
    /// - Returns: Array of accessory items of the specified category
    func getAccessoryItems(of category: AccessoryCategory) -> [Item] {
        return ItemDatabase.allAccessories.filter { $0.accessoryCategory == category }
    }

    /// Gets the gear category of an item
    /// - Parameter item: The item to check
    /// - Returns: The gear category if the item is gear
    func getGearCategory(_ item: ItemEntity) -> GearCategory? {
        if let gearCategoryString = item.gearCategory {
            return GearCategory(rawValue: gearCategoryString)
        }
        return nil
    }

    /// Gets the accessory category of an item
    /// - Parameter item: The item to check
    /// - Returns: The accessory category if the item is an accessory
    func getAccessoryCategory(_ item: ItemEntity) -> AccessoryCategory? {
        if let accessoryCategoryString = item.accessoryCategory {
            return AccessoryCategory(rawValue: accessoryCategoryString)
        }
        return nil
    }

    /// Gets the rarity of an item
    /// - Parameter item: The item to check
    /// - Returns: The rarity if the item has one
    func getRarity(_ item: ItemEntity) -> ItemRarity? {
        if let rarityString = item.rarity {
            return ItemRarity(rawValue: rarityString)
        }
        return nil
    }
}

// MARK: - Default Item Usage Handler

/// Default implementation of item usage handling
class DefaultItemUsageHandler: ItemUsageHandler {
    private lazy var healthManager = HealthManager.shared
    private lazy var boosterManager = BoosterManager.shared
    private weak var inventoryManager: InventoryManager?

    init(inventoryManager: InventoryManager? = nil) {
        self.inventoryManager = inventoryManager
    }

    func useItem(_ item: Item, completion: @escaping (Bool, Error?) -> Void) {
        guard let usageData = item.usageData else {
            // For collectible items, just return success
            completion(true, nil)
            return
        }

        switch usageData {
        case .healthPotion(let healAmount):
            useHealthPotion(healAmount: healAmount, completion: completion)

        case .xpBoost(let multiplier, let duration):
            useXPBoost(multiplier: multiplier, duration: duration, sourceName: item.name, completion: completion)

        case .coinBoost(let multiplier, let duration):
            useCoinBoost(multiplier: multiplier, duration: duration, sourceName: item.name, completion: completion)
        }
    }

    private func useHealthPotion(healAmount: Int16, completion: @escaping (Bool, Error?) -> Void) {
        if healAmount >= 999 {
            // Full heal
            healthManager.restoreFullHealth { error in
                completion(error == nil, error)
            }
        } else {
            // Partial heal
            healthManager.heal(healAmount) { error in
                completion(error == nil, error)
            }
        }
    }

    private func useXPBoost(multiplier: Double, duration: TimeInterval, sourceName: String, completion: @escaping (Bool, Error?) -> Void) {
        // Create an ActiveEffect for the inventory manager
        let itemEffect = ItemEffect(
            type: .xpBoost,
            value: Int((multiplier - 1.0) * 100), // Convert multiplier to percentage
            duration: duration,
            isPercentage: true
        )

        let activeEffect = ActiveEffect(
            effect: itemEffect,
            sourceItemId: UUID(), // Generate a unique ID for this effect
            duration: duration
        )

        // Add to inventory manager's active effects
        // The BoosterManager will automatically pick this up via calculateItemBoosters()
        inventoryManager?.addActiveEffect(activeEffect)

        completion(true, nil)
    }

    private func useCoinBoost(multiplier: Double, duration: TimeInterval, sourceName: String, completion: @escaping (Bool, Error?) -> Void) {
        // Create an ActiveEffect for the inventory manager
        let itemEffect = ItemEffect(
            type: .coinBoost,
            value: Int((multiplier - 1.0) * 100), // Convert multiplier to percentage
            duration: duration,
            isPercentage: true
        )

        let activeEffect = ActiveEffect(
            effect: itemEffect,
            sourceItemId: UUID(), // Generate a unique ID for this effect
            duration: duration
        )

        // Add to inventory manager's active effects
        // The BoosterManager will automatically pick this up via calculateItemBoosters()
        inventoryManager?.addActiveEffect(activeEffect)

        completion(true, nil)
    }
}

// MARK: - Inventory Errors

/// Errors that can occur during inventory operations
enum InventoryError: LocalizedError {
    case invalidItem
    case itemNotFound
    case insufficientQuantity
    case itemNotUsable

    var errorDescription: String? {
        switch self {
        case .invalidItem:
            return String(localized: "inventory_error_invalid_item")
        case .itemNotFound:
            return String(localized: "inventory_error_item_not_found")
        case .insufficientQuantity:
            return String(localized: "inventory_error_insufficient_quantity")
        case .itemNotUsable:
            return String(localized: "inventory_error_item_not_usable")
        }
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let activeEffectsChanged = Notification.Name("activeEffectsChanged")
    static let inventoryUpdated = Notification.Name("inventoryUpdated")
}
