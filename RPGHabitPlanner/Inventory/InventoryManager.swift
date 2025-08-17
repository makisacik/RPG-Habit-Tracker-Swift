//
//  InventoryManager.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import Foundation
import Combine

// MARK: - Enhanced Item Model

struct Item: GameItem, Codable, Equatable {
    let id: UUID
    let name: String
    let description: String
    let iconName: String
    let rarity: ItemRarity
    let itemType: ItemType
    let value: Int
    let collectionCategory: String?
    let isRare: Bool

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        iconName: String,
        rarity: ItemRarity = .common,
        itemType: ItemType = .collectible,
        value: Int = 0,
        collectionCategory: String? = nil,
        isRare: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.iconName = iconName
        self.rarity = rarity
        self.itemType = itemType
        self.value = value
        self.collectionCategory = collectionCategory
        self.isRare = isRare
    }
    
    // Legacy initializer for backward compatibility
    init(name: String, info: String, iconName: String) {
        self.id = UUID()
        self.name = name
        self.description = info
        self.iconName = iconName
        self.rarity = .common
        self.itemType = .collectible
        self.value = 0
        self.collectionCategory = nil
        self.isRare = false
    }
}

// MARK: - Enhanced Inventory Manager

final class InventoryManager: ObservableObject {
    static let shared = InventoryManager()
    private let service: InventoryServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    // Published properties for UI updates
    @Published var activeEffects: [ActiveEffect] = []
    @Published var inventoryItems: [ItemEntity] = []

    private init(service: InventoryServiceProtocol = InventoryService()) {
        self.service = service
        setupActiveEffectsTimer()
        loadActiveEffects()
    }

    // MARK: - Timer for Active Effects

    private func setupActiveEffectsTimer() {
        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateActiveEffects()
            }
            .store(in: &cancellables)
    }

    func updateActiveEffects() {
        let now = Date()
        activeEffects = activeEffects.filter { effect in
            guard let endTime = effect.endTime else { return true }
            return now < endTime
        }

        // Save updated effects
        saveActiveEffects()

        // Notify observers if effects changed
        objectWillChange.send()
    }

    // MARK: - Active Effects Management

    private func loadActiveEffects() {
        if let data = UserDefaults.standard.data(forKey: "ActiveEffects"),
           let effects = try? JSONDecoder().decode([ActiveEffect].self, from: data) {
            activeEffects = effects.filter { $0.isActive }
        }
    }

    private func saveActiveEffects() {
        if let data = try? JSONEncoder().encode(activeEffects) {
            UserDefaults.standard.set(data, forKey: "ActiveEffects")
        }
    }

    func addActiveEffect(_ effect: ActiveEffect) {
        activeEffects.append(effect)
        saveActiveEffects()
        objectWillChange.send()
    }

    func removeActiveEffect(_ effect: ActiveEffect) {
        activeEffects.removeAll { $0.id == effect.id }
        saveActiveEffects()
        objectWillChange.send()
    }

    func getActiveEffect(for type: ItemEffect.EffectType) -> ActiveEffect? {
        return activeEffects.first { $0.effect.type == type && $0.isActive }
    }

    func hasActiveEffect(for type: ItemEffect.EffectType) -> Bool {
        return getActiveEffect(for: type) != nil
    }

    // MARK: - XP Boost Management

    func getActiveXPBoost() -> ActiveEffect? {
        return getActiveEffect(for: .xpBoost)
    }

    func getXPBoostMultiplier() -> Double {
        guard let activeEffect = getActiveXPBoost() else { return 1.0 }
        return Double(activeEffect.effect.value) / 100.0
    }

    func applyXPBoost(_ xpBoost: XPBoostItem) {
        // Remove any existing XP boost
        if let existingBoost = getActiveXPBoost() {
            removeActiveEffect(existingBoost)
        }

        // Add new XP boost effect
        let effect = ItemEffect(
            type: .xpBoost,
            value: Int(xpBoost.boostMultiplier * 100),
            duration: xpBoost.boostDuration,
            isPercentage: true
        )

        let activeEffect = ActiveEffect(
            effect: effect,
            sourceItemId: xpBoost.id,
            duration: xpBoost.boostDuration
        )

        addActiveEffect(activeEffect)
    }

    // MARK: - Item Usage

    func useFunctionalItem(_ item: ItemEntity, completion: @escaping (Bool, Error?) -> Void) {
        guard let itemName = item.name else {
            completion(false, NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid item"]))
            return
        }

        // Check if it's a health potion (legacy support)
        if isHealthPotion(item) {
            useHealthPotion(item, completion: completion)
            return
        }

        // Check if it's an XP boost
        if let xpBoost = getXPBoostFromItem(item) {
            useXPBoost(xpBoost, item: item, completion: completion)
            return
        }

        // Check if it's a functional item
        if let functionalItem = getFunctionalItemFromEntity(item) {
            useFunctionalItem(functionalItem, item: item, completion: completion)
            return
        }

        completion(false, NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Item cannot be used"]))
    }

    private func useXPBoost(_ xpBoost: XPBoostItem, item: ItemEntity, completion: @escaping (Bool, Error?) -> Void) {
        applyXPBoost(xpBoost)
        removeFromInventory(item)
        completion(true, nil)
    }

    private func useFunctionalItem(_ functionalItem: FunctionalItem, item: ItemEntity, completion: @escaping (Bool, Error?) -> Void) {
        // Apply effects
        for effect in functionalItem.effects {
            let activeEffect = ActiveEffect(
                effect: effect,
                sourceItemId: functionalItem.id,
                duration: effect.duration
            )
            addActiveEffect(activeEffect)
        }

        // Remove item if it's consumable
        if functionalItem.functionalType == .consumable {
            removeFromInventory(item)
        }

        completion(true, nil)
    }

    // MARK: - Item Conversion Helpers

    func getXPBoostFromItem(_ item: ItemEntity) -> XPBoostItem? {
        guard let name = item.name else { return nil }

        return XPBoostItem.allXPBoosts.first { xpBoost in
            xpBoost.name == name
        }
    }

    private func getFunctionalItemFromEntity(_ item: ItemEntity) -> FunctionalItem? {
        // This would need to be implemented based on your item database
        // For now, return nil
        return nil
    }

    // MARK: - Item Database

    let allItems: [Item] = [
        // Collectible Items
        Item(name: "Armor", description: "Protective armor to increase defense", iconName: "icon_armor", itemType: .collectible, collectionCategory: "Armor"),
        Item(name: "Arrows", description: "A bundle of arrows for ranged attacks", iconName: "icon_arrows", itemType: .collectible, collectionCategory: "Weapons"),
        Item(name: "Axe Spear", description: "Dual weapon for melee combat", iconName: "icon_axe_spear", itemType: .collectible, collectionCategory: "Weapons"),
        Item(name: "Axe", description: "Heavy axe for chopping or battle", iconName: "icon_axe", itemType: .collectible, collectionCategory: "Weapons"),
        Item(name: "Bow", description: "Ranged weapon for precision attacks", iconName: "icon_bow", itemType: .collectible, collectionCategory: "Weapons"),
        Item(name: "Crown", description: "Symbol of royalty", iconName: "icon_crown", rarity: .legendary, itemType: .collectible, collectionCategory: "Royalty", isRare: true),
        Item(name: "Egg", description: "Mysterious egg, what's inside?", iconName: "icon_egg", itemType: .collectible, collectionCategory: "General"),
        Item(name: "Gold", description: "Precious gold coin", iconName: "icon_gold", rarity: .epic, itemType: .collectible, collectionCategory: "Treasure", isRare: true),
        Item(name: "Hammer", description: "Tool or weapon for strong strikes", iconName: "icon_hammer", itemType: .collectible, collectionCategory: "Weapons"),
        Item(name: "Helmet", description: "Protective headgear", iconName: "icon_helmet", itemType: .collectible, collectionCategory: "Armor"),
        Item(name: "Helmet Witch", description: "Magical witch's hat", iconName: "icon_helmet_witch", itemType: .collectible, collectionCategory: "Armor"),
        Item(name: "Key Gold", description: "Opens golden locks", iconName: "icon_key_gold", rarity: .epic, itemType: .collectible, collectionCategory: "Treasure", isRare: true),
        Item(name: "Key Silver", description: "Opens silver locks", iconName: "icon_key_silver", rarity: .rare, itemType: .collectible, collectionCategory: "Treasure", isRare: true),
        Item(name: "Meat", description: "Cooked meat to restore health", iconName: "icon_meat", itemType: .collectible, collectionCategory: "General"),
        Item(name: "Medal", description: "Award for great achievements", iconName: "icon_medal", rarity: .legendary, itemType: .collectible, collectionCategory: "Royalty", isRare: true),
        Item(name: "Pouch", description: "Small pouch for coins or trinkets", iconName: "icon_pouch", itemType: .collectible, collectionCategory: "General"),
        Item(name: "Pumpkin", description: "Festive pumpkin", iconName: "icon_pumpkin", itemType: .collectible, collectionCategory: "General"),
        
        // Functional Items (Potions & Flasks)
        Item(name: "Flask Blue", description: "Magical blue potion", iconName: "icon_flask_blue", itemType: .functional),
        Item(name: "Flask Purple", description: "Magical purple potion", iconName: "icon_flask_purple", itemType: .functional),
        Item(name: "Flash Green", description: "Instant energy boost", iconName: "icon_flash_green", itemType: .functional),
        Item(name: "Flash Red", description: "Health regeneration potion", iconName: "icon_flash_red", itemType: .functional),
        
        // Health Potions (Functional)
        Item(name: "Minor Health Potion", description: "Restores 15 HP. A basic healing potion.", iconName: "potion_health_minor", itemType: .functional),
        Item(name: "Health Potion", description: "Restores 30 HP. A reliable healing potion.", iconName: "potion_health", itemType: .functional),
        Item(name: "Greater Health Potion", description: "Restores 50 HP. A powerful healing potion.", iconName: "potion_health_greater", itemType: .functional),
        Item(name: "Superior Health Potion", description: "Restores 75 HP. An exceptional healing potion.", iconName: "potion_health_superior", itemType: .functional),
        Item(name: "Legendary Health Potion", description: "Fully restores health. A legendary potion.", iconName: "potion_health_legendary", rarity: .legendary, itemType: .functional, isRare: true),
        
        // XP Boosts (Functional)
        Item(name: "Minor XP Boost", description: "Increases XP gain by 25% for 30 minutes", iconName: "icon_xp_boost_minor", itemType: .functional),
        Item(name: "XP Boost", description: "Increases XP gain by 50% for 1 hour", iconName: "icon_xp_boost", itemType: .functional),
        Item(name: "Greater XP Boost", description: "Increases XP gain by 100% for 2 hours", iconName: "icon_xp_boost_greater", itemType: .functional),
        Item(name: "Legendary XP Boost", description: "Increases XP gain by 200% for 4 hours", iconName: "icon_xp_boost_legendary", rarity: .legendary, itemType: .functional, isRare: true)
    ]

    func getRandomReward() -> Item {
        return allItems.randomElement()!
    }

    func addToInventory(_ item: Item) {
        service.addItem(name: item.name, info: item.description, iconName: item.iconName)
        refreshInventory()
    }

    func fetchInventory() -> [ItemEntity] {
        return service.fetchInventory()
    }

    func refreshInventory() {
        inventoryItems = service.fetchInventory()
    }

    func removeFromInventory(_ item: ItemEntity) {
        service.removeItem(item)
        refreshInventory()
    }

    func clearInventory() {
        service.clearInventory()
        refreshInventory()
    }

    // MARK: - Health Potion Methods (Legacy Support)

    func isHealthPotion(_ item: ItemEntity) -> Bool {
        guard let name = item.name else { return false }
        return name.contains("Health Potion")
    }

    func getHealthPotionFromItem(_ item: ItemEntity) -> HealthPotion? {
        guard let name = item.name else { return nil }

        switch name {
        case "Minor Health Potion":
            return HealthPotion.minorHealthPotion
        case "Health Potion":
            return HealthPotion.healthPotion
        case "Greater Health Potion":
            return HealthPotion.greaterHealthPotion
        case "Superior Health Potion":
            return HealthPotion.superiorHealthPotion
        case "Legendary Health Potion":
            return HealthPotion.legendaryHealthPotion
        default:
            return nil
        }
    }

    func useHealthPotion(_ item: ItemEntity, completion: @escaping (Bool, Error?) -> Void) {
        guard let healthPotion = getHealthPotionFromItem(item) else {
            completion(false, NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Not a health potion"]))
            return
        }

        // Use the potion
        healthPotion.use(on: HealthManager.shared) { error in
            if error == nil {
                // Remove the potion from inventory after use
                self.removeFromInventory(item)
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }

    func addHealthPotionToInventory(_ potion: HealthPotion) {
        service.addItem(name: potion.name, info: potion.description, iconName: potion.iconName)
        refreshInventory()
    }

    func getRandomHealthPotion() -> HealthPotion {
        return HealthPotion.allHealthPotions.randomElement() ?? HealthPotion.healthPotion
    }

    func addStarterHealthPotions() {
        // Add some starter health potions for testing
        addHealthPotionToInventory(HealthPotion.minorHealthPotion)
        addHealthPotionToInventory(HealthPotion.healthPotion)
        addHealthPotionToInventory(HealthPotion.greaterHealthPotion)
    }

    // MARK: - XP Boost Methods

    func isXPBoost(_ item: ItemEntity) -> Bool {
        guard let name = item.name else { return false }
        return name.contains("XP Boost")
    }

    func addXPBoostToInventory(_ xpBoost: XPBoostItem) {
        service.addItem(name: xpBoost.name, info: xpBoost.description, iconName: xpBoost.iconName)
        refreshInventory()
    }

    func addStarterXPBoosts() {
        // Add some starter XP boosts for testing
        addXPBoostToInventory(XPBoostItem.minorXPBoost)
        addXPBoostToInventory(XPBoostItem.xpBoost)
    }

    // MARK: - Item Type Detection

    func getItemType(_ item: ItemEntity) -> ItemType? {
        guard let name = item.name else { return nil }

        if isHealthPotion(item) || isXPBoost(item) {
            return .functional
        }

        // Default to collectible for other items
        return .collectible
    }

    func isFunctionalItem(_ item: ItemEntity) -> Bool {
        return getItemType(item) == .functional
    }

    func isCollectibleItem(_ item: ItemEntity) -> Bool {
        return getItemType(item) == .collectible
    }
    
    // MARK: - Item Conversion Methods
    
    func getItemFromEntity(_ item: ItemEntity) -> Item? {
        guard let name = item.name,
              let info = item.info,
              let iconName = item.iconName else {
            return nil
        }
        
        // Determine item type based on name
        let itemType: ItemType = {
            if name.contains("Health Potion") || name.contains("XP Boost") || name.contains("Flask") {
                return .functional
            } else {
                return .collectible
            }
        }()
        
        // Determine rarity based on name or other criteria
        let rarity: ItemRarity = {
            if name.contains("Legendary") || name.contains("Crown") || name.contains("Medal") {
                return .legendary
            } else if name.contains("Epic") || name.contains("Gold") {
                return .epic
            } else if name.contains("Rare") || name.contains("Silver") {
                return .rare
            } else if name.contains("Uncommon") || name.contains("Blue") {
                return .uncommon
            } else {
                return .common
            }
        }()
        
        // Determine if it's rare based on rarity
        let isRare = rarity == .rare || rarity == .epic || rarity == .legendary
        
        // Determine collection category (only for collectibles)
        let collectionCategory: String? = {
            guard itemType == .collectible else { return nil }
            
            if name.contains("Crown") || name.contains("Medal") {
                return "Royalty"
            } else if name.contains("Gold") || name.contains("Silver") {
                return "Treasure"
            } else if name.contains("Weapon") || name.contains("Sword") || name.contains("Axe") || name.contains("Bow") {
                return "Weapons"
            } else if name.contains("Armor") || name.contains("Helmet") {
                return "Armor"
            } else {
                return "General"
            }
        }()
        
        return Item(
            id: UUID(), // Generate new ID since ItemEntity doesn't have one
            name: name,
            description: info,
            iconName: iconName,
            rarity: rarity,
            itemType: itemType,
            value: 0, // Default value
            collectionCategory: collectionCategory,
            isRare: isRare
        )
    }
}
