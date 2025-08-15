//
//  InventoryManager.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import Foundation
import Combine

// MARK: - Legacy Item (keeping for compatibility)

struct Item: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let info: String
    let iconName: String

    init(name: String, info: String, iconName: String) {
        self.id = UUID()
        self.name = name
        self.info = info
        self.iconName = iconName
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

    private func updateActiveEffects() {
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

    // MARK: - Legacy Support

    private let allItems: [Item] = [
        Item(name: "Armor", info: "Protective armor to increase defense", iconName: "icon_armor"),
        Item(name: "Arrows", info: "A bundle of arrows for ranged attacks", iconName: "icon_arrows"),
        Item(name: "Axe Spear", info: "Dual weapon for melee combat", iconName: "icon_axe_spear"),
        Item(name: "Axe", info: "Heavy axe for chopping or battle", iconName: "icon_axe"),
        Item(name: "Bow", info: "Ranged weapon for precision attacks", iconName: "icon_bow"),
        Item(name: "Crown", info: "Symbol of royalty", iconName: "icon_crown"),
        Item(name: "Egg", info: "Mysterious egg, what's inside?", iconName: "icon_egg"),
        Item(name: "Flask Blue", info: "Magical blue potion", iconName: "icon_flask_blue"),
        Item(name: "Flask Purple", info: "Magical purple potion", iconName: "icon_flask_purple"),
        Item(name: "Flash Green", info: "Instant energy boost", iconName: "icon_flash_green"),
        Item(name: "Flash Red", info: "Health regeneration potion", iconName: "icon_flash_red"),
        Item(name: "Gold", info: "Precious gold coin", iconName: "icon_gold"),
        Item(name: "Hammer", info: "Tool or weapon for strong strikes", iconName: "icon_hammer"),
        Item(name: "Helmet", info: "Protective headgear", iconName: "icon_helmet"),
        Item(name: "Helmet Witch", info: "Magical witch's hat", iconName: "icon_helmet_witch"),
        Item(name: "Key Gold", info: "Opens golden locks", iconName: "icon_key_gold"),
        Item(name: "Key Silver", info: "Opens silver locks", iconName: "icon_key_silver"),
        Item(name: "Meat", info: "Cooked meat to restore health", iconName: "icon_meat"),
        Item(name: "Medal", info: "Award for great achievements", iconName: "icon_medal"),
        Item(name: "Pouch", info: "Small pouch for coins or trinkets", iconName: "icon_pouch"),
        Item(name: "Pumpkin", info: "Festive pumpkin", iconName: "icon_pumpkin"),
        // Health Potions
        Item(name: "Minor Health Potion", info: "Restores 15 HP. A basic healing potion.", iconName: "potion_health_minor"),
        Item(name: "Health Potion", info: "Restores 30 HP. A reliable healing potion.", iconName: "potion_health"),
        Item(name: "Greater Health Potion", info: "Restores 50 HP. A powerful healing potion.", iconName: "potion_health_greater"),
        Item(name: "Superior Health Potion", info: "Restores 75 HP. An exceptional healing potion.", iconName: "potion_health_superior"),
        Item(name: "Legendary Health Potion", info: "Fully restores health. A legendary potion.", iconName: "potion_health_legendary"),
        // XP Boosts
        Item(name: "Minor XP Boost", info: "Increases XP gain by 25% for 30 minutes", iconName: "icon_xp_boost_minor"),
        Item(name: "XP Boost", info: "Increases XP gain by 50% for 1 hour", iconName: "icon_xp_boost"),
        Item(name: "Greater XP Boost", info: "Increases XP gain by 100% for 2 hours", iconName: "icon_xp_boost_greater"),
        Item(name: "Legendary XP Boost", info: "Increases XP gain by 200% for 4 hours", iconName: "icon_xp_boost_legendary")
    ]

    func getRandomReward() -> Item {
        return allItems.randomElement()!
    }

    func addToInventory(_ item: Item) {
        service.addItem(name: item.name, info: item.info, iconName: item.iconName)
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
}
