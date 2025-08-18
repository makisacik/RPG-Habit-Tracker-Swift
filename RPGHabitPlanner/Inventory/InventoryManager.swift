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
    private let itemDatabase = ItemDatabase.shared
    private lazy var usageHandler: ItemUsageHandler = {
        return DefaultItemUsageHandler(inventoryManager: self)
    }()
    
    // MARK: - Initialization
    
    private init() {
        self.service = InventoryService(container: PersistenceController.shared.container)
        refreshInventory()
    }
    
    // MARK: - Inventory Management
    
    /// Refreshes the inventory from the data service
    func refreshInventory() {
        inventoryItems = service.fetchInventory()
    }
    
    /// Adds an item to the inventory
    /// - Parameter item: The item to add
    func addToInventory(_ item: Item) {
        service.addItem(name: item.name, info: item.description, iconName: item.iconName)
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
        guard let name = item.name,
              let itemDefinition = itemDatabase.findItem(by: name) else {
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
    
    // MARK: - Item Type Detection
    
    /// Gets the type of an item
    /// - Parameter item: The item to check
    /// - Returns: The item type if found
    func getItemType(_ item: ItemEntity) -> ItemType? {
        guard let name = item.name,
              let itemDefinition = itemDatabase.findItem(by: name) else {
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
    
    /// Adds an active effect to the inventory
    /// - Parameter effect: The effect to add
    func addActiveEffect(_ effect: ActiveEffect) {
        activeEffects.append(effect)
        NotificationCenter.default.post(name: .activeEffectsChanged, object: nil)
    }
    
    /// Removes an active effect from the inventory
    /// - Parameter effect: The effect to remove
    func removeActiveEffect(_ effect: ActiveEffect) {
        activeEffects.removeAll { $0.id == effect.id }
        NotificationCenter.default.post(name: .activeEffectsChanged, object: nil)
    }
    
    /// Clears all expired effects from the inventory
    func clearExpiredEffects() {
        activeEffects.removeAll { !$0.isActive }
        NotificationCenter.default.post(name: .activeEffectsChanged, object: nil)
    }
    
    // MARK: - Helper Methods
    
    /// Gets a random reward item
    /// - Returns: A random item from the database
    func getRandomReward() -> Item {
        return itemDatabase.getRandomItem()
    }
    
    /// Adds starter items to the inventory
    func addStarterItems() {
        addToInventory(ItemDatabase.minorHealthPotion)
        addToInventory(ItemDatabase.healthPotion)
        addToInventory(ItemDatabase.minorXPBoost)
        addToInventory(ItemDatabase.minorCoinBoost)
    }
    
    /// Gets all items of a specific type
    /// - Parameter type: The item type to filter by
    /// - Returns: Array of items of the specified type
    func getItems(of type: ItemType) -> [Item] {
        return itemDatabase.getItems(of: type)
    }
    
    /// Gets all items of a specific rarity
    /// - Parameter rarity: The item rarity to filter by
    /// - Returns: Array of items of the specified rarity
    func getItems(of rarity: ItemRarity) -> [Item] {
        return itemDatabase.getItems(of: rarity)
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
        inventoryManager?.addActiveEffect(activeEffect)
        
        // Also add to booster manager for consistency
        boosterManager.addTemporaryBooster(
            type: .experience,
            multiplier: multiplier,
            flatBonus: 0,
            duration: duration,
            sourceName: sourceName
        )
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
        inventoryManager?.addActiveEffect(activeEffect)
        
        // Also add to booster manager for consistency
        boosterManager.addTemporaryBooster(
            type: .coins,
            multiplier: multiplier,
            flatBonus: 0,
            duration: duration,
            sourceName: sourceName
        )
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
            return "Invalid item"
        case .itemNotFound:
            return "Item not found in inventory"
        case .insufficientQuantity:
            return "Not enough items"
        case .itemNotUsable:
            return "This item cannot be used"
        }
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let activeEffectsChanged = Notification.Name("activeEffectsChanged")
}
