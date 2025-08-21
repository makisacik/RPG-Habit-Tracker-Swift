//
//  Item.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import Foundation
import SwiftUI

// MARK: - Item Rarity

enum ItemRarity: String, CaseIterable, Codable {
    case common = "Common"
    case uncommon = "Uncommon"
    case rare = "Rare"
    case epic = "Epic"
    case legendary = "Legendary"

    var color: String {
        switch self {
        case .common: return "gray"
        case .uncommon: return "green"
        case .rare: return "blue"
        case .epic: return "purple"
        case .legendary: return "orange"
        }
    }
    
    var uiColor: Color {
        switch self {
        case .common: return .gray
        case .uncommon: return .green
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .orange
        }
    }
    
    var borderColor: Color {
        switch self {
        case .common: return .gray.opacity(0.8)
        case .uncommon: return .green.opacity(0.8)
        case .rare: return .blue.opacity(0.8)
        case .epic: return .purple.opacity(0.8)
        case .legendary: return .orange.opacity(0.8)
        }
    }
    
    var glowColor: Color {
        switch self {
        case .common: return .clear
        case .uncommon: return .green.opacity(0.3)
        case .rare: return .blue.opacity(0.3)
        case .epic: return .purple.opacity(0.3)
        case .legendary: return .orange.opacity(0.5)
        }
    }
}

// MARK: - Item Types

enum ItemType: String, CaseIterable, Codable {
    case collectible = "Collectible"
    case consumable = "Consumable"
    case equipable = "Equipable"
    case booster = "Booster"

    var description: String {
        switch self {
        case .collectible:
            return "Visual items for display and collection"
        case .consumable:
            return "Used once and consumed"
        case .equipable:
            return "Persistent until changed"
        case .booster:
            return "Provides temporary bonuses"
        }
    }
}

// MARK: - Base Item Protocol

protocol GameItem: Identifiable, Equatable, Codable {
    var id: UUID { get }
    var name: String { get }
    var description: String { get }
    var iconName: String { get }
    var rarity: ItemRarity { get }
    var itemType: ItemType { get }
    var value: Int { get }
    var collectionCategory: String? { get }
    var isRare: Bool { get }
}

// MARK: - Unified Item Model

struct Item: GameItem {
    let id: UUID
    let name: String
    let description: String
    let iconName: String
    let rarity: ItemRarity
    let itemType: ItemType
    let value: Int
    let collectionCategory: String?
    let isRare: Bool
    let effects: [ItemEffect]?
    let usageData: ItemUsageData?

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        iconName: String,
        rarity: ItemRarity = .common,
        itemType: ItemType = .collectible,
        value: Int = 0,
        collectionCategory: String? = nil,
        isRare: Bool = false,
        effects: [ItemEffect]? = nil,
        usageData: ItemUsageData? = nil
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
        self.effects = effects
        self.usageData = usageData
    }
    
    // MARK: - Convenience Initializers
    
    static func healthPotion(
        name: String,
        description: String,
        healAmount: Int16,
        rarity: ItemRarity = .common,
        value: Int = 0
    ) -> Item {
        return Item(
            name: name,
            description: description,
            iconName: "icon_flask_red",
            rarity: rarity,
            itemType: .consumable,
            value: value,
            usageData: .healthPotion(healAmount: healAmount)
        )
    }
    
    static func xpBoost(
        name: String,
        description: String,
        multiplier: Double,
        duration: TimeInterval,
        rarity: ItemRarity = .common,
        value: Int = 0
    ) -> Item {
        return Item(
            name: name,
            description: description,
            iconName: "icon_lightning",
            rarity: rarity,
            itemType: .booster,
            value: value,
            usageData: .xpBoost(multiplier: multiplier, duration: duration)
        )
    }
    
    static func coinBoost(
        name: String,
        description: String,
        multiplier: Double,
        duration: TimeInterval,
        rarity: ItemRarity = .common,
        value: Int = 0
    ) -> Item {
        return Item(
            name: name,
            description: description,
            iconName: "icon_flask_purple",
            rarity: rarity,
            itemType: .booster,
            value: value,
            usageData: .coinBoost(multiplier: multiplier, duration: duration)
        )
    }
    
    static func collectible(
        name: String,
        description: String,
        iconName: String,
        rarity: ItemRarity = .common,
        collectionCategory: String? = nil,
        isRare: Bool = false
    ) -> Item {
        return Item(
            name: name,
            description: description,
            iconName: iconName,
            rarity: rarity,
            itemType: .collectible,
            collectionCategory: collectionCategory,
            isRare: isRare
        )
    }
}

// MARK: - Item Usage Data

enum ItemUsageData: Codable, Equatable {
    case healthPotion(healAmount: Int16)
    case xpBoost(multiplier: Double, duration: TimeInterval)
    case coinBoost(multiplier: Double, duration: TimeInterval)
    
    var isConsumable: Bool {
        switch self {
        case .healthPotion, .xpBoost, .coinBoost:
            return true
        }
    }
}

// MARK: - Item Effects

struct ItemEffect: Equatable, Codable {
    let type: EffectType
    let value: Int
    let duration: TimeInterval?
    let isPercentage: Bool

    enum EffectType: String, CaseIterable, Codable {
        case attack = "Attack"
        case defense = "Defense"
        case health = "Health"
        case focus = "Focus"
        case experience = "Experience"
        case luck = "Luck"
        case speed = "Speed"
        case criticalChance = "Critical Chance"
        case criticalDamage = "Critical Damage"
        case xpBoost = "XP Boost"
        case coinBoost = "Coin Boost"
        case healthRegeneration = "Health Regeneration"
        case focusRegeneration = "Focus Regeneration"

        var description: String {
            switch self {
            case .attack: return "Increases attack power"
            case .defense: return "Increases defense"
            case .health: return "Restores or increases health"
            case .focus: return "Restores or increases focus"
            case .experience: return "Grants experience points"
            case .luck: return "Increases luck"
            case .speed: return "Increases movement/action speed"
            case .criticalChance: return "Increases critical hit chance"
            case .criticalDamage: return "Increases critical hit damage"
            case .xpBoost: return "Multiplies experience gain"
            case .coinBoost: return "Multiplies coin gain"
            case .healthRegeneration: return "Regenerates health over time"
            case .focusRegeneration: return "Regenerates focus over time"
            }
        }

        var icon: String {
            switch self {
            case .attack: return "sword.fill"
            case .defense: return "shield.fill"
            case .health: return "heart.fill"
            case .focus: return "brain.head.profile"
            case .experience: return "star.fill"
            case .luck: return "dice.fill"
            case .speed: return "bolt.fill"
            case .criticalChance: return "target"
            case .criticalDamage: return "burst.fill"
            case .xpBoost: return "arrow.up.circle.fill"
            case .coinBoost: return "icon_gold"
            case .healthRegeneration: return "heart.circle.fill"
            case .focusRegeneration: return "brain.head.profile.circle.fill"
            }
        }
    }

    init(type: EffectType, value: Int, duration: TimeInterval? = nil, isPercentage: Bool = false) {
        self.type = type
        self.value = value
        self.duration = duration
        self.isPercentage = isPercentage
    }

    var displayValue: String {
        if isPercentage {
            return "\(value)%"
        } else {
            return "\(value)"
        }
    }
}

// MARK: - Active Effect Tracking

struct ActiveEffect: Identifiable, Codable {
    let id: UUID
    let effect: ItemEffect
    let startTime: Date
    let endTime: Date?
    let sourceItemId: UUID

    var isActive: Bool {
        guard let endTime = endTime else { return true }
        return Date() < endTime
    }

    var remainingTime: TimeInterval? {
        guard let endTime = endTime else { return nil }
        return max(0, endTime.timeIntervalSince(Date()))
    }

    var progress: Double {
        guard let endTime = endTime else { return 1.0 }
        let totalDuration = endTime.timeIntervalSince(startTime)
        let elapsed = Date().timeIntervalSince(startTime)
        return min(1.0, max(0.0, elapsed / totalDuration))
    }

    init(effect: ItemEffect, sourceItemId: UUID, duration: TimeInterval? = nil) {
        self.id = UUID()
        self.effect = effect
        self.startTime = Date()
        self.sourceItemId = sourceItemId

        if let duration = duration {
            self.endTime = Date().addingTimeInterval(duration)
        } else {
            self.endTime = nil
        }
    }
    
    // Initializer for loading from persistence
    init(id: UUID, effect: ItemEffect, startTime: Date, endTime: Date?, sourceItemId: UUID) {
        self.id = id
        self.effect = effect
        self.startTime = startTime
        self.endTime = endTime
        self.sourceItemId = sourceItemId
    }
}

// MARK: - Item Database

struct ItemDatabase {
    static let shared = ItemDatabase()
    
    private init() {}
    
    // MARK: - Health Potions
    static let minorHealthPotion = Item.healthPotion(
        name: "Minor Health Potion",
        description: "Restores 15 HP. A basic healing potion made from common herbs.",
        healAmount: 15,
        rarity: .common,
        value: 25
    )
    
    static let healthPotion = Item.healthPotion(
        name: "Health Potion",
        description: "Restores 30 HP. A reliable healing potion for adventurers.",
        healAmount: 30,
        rarity: .uncommon,
        value: 50
    )
    
    static let greaterHealthPotion = Item.healthPotion(
        name: "Greater Health Potion",
        description: "Restores 50 HP. A powerful healing potion that can save your life.",
        healAmount: 50,
        rarity: .rare,
        value: 100
    )
    
    static let superiorHealthPotion = Item.healthPotion(
        name: "Superior Health Potion",
        description: "Restores 75 HP. An exceptional healing potion with rare ingredients.",
        healAmount: 75,
        rarity: .epic,
        value: 200
    )
    
    static let legendaryHealthPotion = Item.healthPotion(
        name: "Legendary Health Potion",
        description: "Fully restores health. A legendary potion that brings you back from the brink of death.",
        healAmount: 999,
        rarity: .legendary,
        value: 500
    )
    
    // MARK: - XP Boosts
    static let minorXPBoost = Item.xpBoost(
        name: "Minor XP Boost",
        description: "Increases XP gain by 25% for 30 minutes",
        multiplier: 1.25,
        duration: 30 * 60,
        rarity: .common,
        value: 50
    )
    
    static let xpBoost = Item.xpBoost(
        name: "XP Boost",
        description: "Increases XP gain by 50% for 1 hour",
        multiplier: 1.5,
        duration: 60 * 60,
        rarity: .uncommon,
        value: 100
    )
    
    static let greaterXPBoost = Item.xpBoost(
        name: "Greater XP Boost",
        description: "Increases XP gain by 100% for 2 hours",
        multiplier: 2.0,
        duration: 2 * 60 * 60,
        rarity: .rare,
        value: 250
    )
    
    static let legendaryXPBoost = Item.xpBoost(
        name: "Legendary XP Boost",
        description: "Increases XP gain by 200% for 4 hours",
        multiplier: 3.0,
        duration: 4 * 60 * 60,
        rarity: .legendary,
        value: 500
    )
    
    // MARK: - Coin Boosts
    static let minorCoinBoost = Item.coinBoost(
        name: "Minor Coin Boost",
        description: "Increases coin gain by 25% for 30 minutes",
        multiplier: 1.25,
        duration: 30 * 60,
        rarity: .common,
        value: 50
    )
    
    static let coinBoost = Item.coinBoost(
        name: "Coin Boost",
        description: "Increases coin gain by 50% for 1 hour",
        multiplier: 1.5,
        duration: 60 * 60,
        rarity: .uncommon,
        value: 100
    )
    
    static let greaterCoinBoost = Item.coinBoost(
        name: "Greater Coin Boost",
        description: "Increases coin gain by 100% for 2 hours",
        multiplier: 2.0,
        duration: 2 * 60 * 60,
        rarity: .rare,
        value: 250
    )
    
    static let legendaryCoinBoost = Item.coinBoost(
        name: "Legendary Coin Boost",
        description: "Increases coin gain by 200% for 4 hours",
        multiplier: 3.0,
        duration: 4 * 60 * 60,
        rarity: .legendary,
        value: 500
    )
    
    // MARK: - Collectible Items
    static let allCollectibles: [Item] = [
        Item.collectible(name: "Armor", description: "Protective armor to increase defense", iconName: "icon_armor", collectionCategory: "Armor"),
        Item.collectible(name: "Arrows", description: "A bundle of arrows for ranged attacks", iconName: "icon_arrows", collectionCategory: "Weapons"),
        Item.collectible(name: "Axe Spear", description: "Dual weapon for melee combat", iconName: "icon_axe_spear", collectionCategory: "Weapons"),
        Item.collectible(name: "Axe", description: "Heavy axe for chopping or battle", iconName: "icon_axe", collectionCategory: "Weapons"),
        Item.collectible(name: "Bow", description: "Ranged weapon for precision attacks", iconName: "icon_bow", collectionCategory: "Weapons"),
        Item.collectible(name: "Crown", description: "Symbol of royalty", iconName: "icon_crown", rarity: .legendary, collectionCategory: "Royalty", isRare: true),
        Item.collectible(name: "Egg", description: "Mysterious egg, what's inside?", iconName: "icon_egg", collectionCategory: "General"),
        Item.collectible(name: "Gold", description: "Precious gold coin", iconName: "icon_gold", rarity: .epic, collectionCategory: "Treasure", isRare: true),
        Item.collectible(name: "Hammer", description: "Tool or weapon for strong strikes", iconName: "icon_hammer", collectionCategory: "Weapons"),
        Item.collectible(name: "Helmet", description: "Protective headgear", iconName: "icon_helmet", collectionCategory: "Armor"),
        Item.collectible(name: "Helmet Witch", description: "Magical witch's hat", iconName: "icon_helmet_witch", collectionCategory: "Armor"),
        Item.collectible(name: "Key Gold", description: "Opens golden locks", iconName: "icon_key_gold", rarity: .epic, collectionCategory: "Treasure", isRare: true),
        Item.collectible(name: "Key Silver", description: "Opens silver locks", iconName: "icon_key_silver", rarity: .rare, collectionCategory: "Treasure", isRare: true),
        Item.collectible(name: "Meat", description: "Cooked meat to restore health", iconName: "icon_meat", collectionCategory: "General"),
        Item.collectible(name: "Medal", description: "Award for great achievements", iconName: "icon_medal", rarity: .legendary, collectionCategory: "Royalty", isRare: true),
        Item.collectible(name: "Pouch", description: "Small pouch for coins or trinkets", iconName: "icon_pouch", collectionCategory: "General"),
        Item.collectible(name: "Pumpkin", description: "Festive pumpkin", iconName: "icon_pumpkin", collectionCategory: "General"),
        Item.collectible(name: "Shield", description: "Protective shield for defense", iconName: "icon_shield", collectionCategory: "Armor"),
        Item.collectible(name: "Shield Blue", description: "Magical blue shield", iconName: "icon_shield_blue", rarity: .rare, collectionCategory: "Armor", isRare: true),
        Item.collectible(name: "Sword", description: "Sharp sword for combat", iconName: "icon_sword", collectionCategory: "Weapons"),
        Item.collectible(name: "Sword Double", description: "Dual-wielded swords", iconName: "icon_sword_double", rarity: .epic, collectionCategory: "Weapons", isRare: true),
        Item.collectible(name: "Ring", description: "Magical ring with special properties", iconName: "icon_ring", rarity: .rare, collectionCategory: "Accessories", isRare: true),
        Item.collectible(name: "Chest", description: "Treasure chest", iconName: "icon_chest", collectionCategory: "Treasure"),
        Item.collectible(name: "Chest Blue", description: "Rare blue treasure chest", iconName: "icon_chest_blue", rarity: .rare, collectionCategory: "Treasure", isRare: true),
        Item.collectible(name: "Chest Open", description: "Opened treasure chest", iconName: "icon_chest_open", collectionCategory: "Treasure"),
        Item.collectible(name: "Trophy Bronze", description: "Bronze trophy for achievements", iconName: "icon_trophy_bronze", collectionCategory: "Trophies"),
        Item.collectible(name: "Trophy Silver", description: "Silver trophy for achievements", iconName: "icon_trophy_silver", rarity: .rare, collectionCategory: "Trophies", isRare: true),
        Item.collectible(name: "Trophy Gold", description: "Gold trophy for achievements", iconName: "icon_trophy_gold", rarity: .epic, collectionCategory: "Trophies", isRare: true),
        Item.collectible(name: "Scroll 1", description: "Ancient scroll with knowledge", iconName: "icon_scroll_1", collectionCategory: "Scrolls"),
        Item.collectible(name: "Scroll 2", description: "Ancient scroll with knowledge", iconName: "icon_scroll_2", rarity: .rare, collectionCategory: "Scrolls", isRare: true),
        Item.collectible(name: "Scroll 3", description: "Ancient scroll with knowledge", iconName: "icon_scroll_3", rarity: .epic, collectionCategory: "Scrolls", isRare: true),
        Item.collectible(name: "Bell", description: "Magical bell", iconName: "icon_bell", collectionCategory: "General"),
        Item.collectible(name: "Calendar", description: "Calendar for tracking time", iconName: "icon_calendar", collectionCategory: "General"),
        Item.collectible(name: "Clover", description: "Lucky four-leaf clover", iconName: "icon_clover", rarity: .rare, collectionCategory: "General", isRare: true),
        Item.collectible(name: "Cross", description: "Holy cross", iconName: "icon_cross", collectionCategory: "General"),
        Item.collectible(name: "Feather", description: "Light as a feather", iconName: "icon_feather", collectionCategory: "General"),
        Item.collectible(name: "Fire", description: "Element of fire", iconName: "icon_fire", collectionCategory: "Elements"),
        Item.collectible(name: "Lightning", description: "Element of lightning", iconName: "icon_lightning", collectionCategory: "Elements"),
        Item.collectible(name: "Muscle", description: "Symbol of strength", iconName: "icon_muscle", collectionCategory: "General"),
        Item.collectible(name: "Star Fill", description: "Bright star", iconName: "icon_star_fill", collectionCategory: "General"),
        Item.collectible(name: "Skull", description: "Mysterious skull", iconName: "icon_skull", collectionCategory: "General"),
        Item.collectible(name: "Skull Side", description: "Side view of a skull", iconName: "icon_skull_side", collectionCategory: "General"),
        Item.collectible(name: "Viking Helmet", description: "Viking warrior helmet", iconName: "icon_viking_helmet", rarity: .epic, collectionCategory: "Armor", isRare: true),
        Item.collectible(name: "Witch Helmet", description: "Witch's magical hat", iconName: "icon_helmet_witch", rarity: .rare, collectionCategory: "Armor", isRare: true),
        Item.collectible(name: "Level Wings", description: "Wings of experience", iconName: "icon_level_wings", rarity: .epic, collectionCategory: "General", isRare: true),
        Item.collectible(name: "Level", description: "Symbol of leveling up", iconName: "icon_level", collectionCategory: "General"),
        Item.collectible(name: "Castle", description: "Mighty castle", iconName: "icon_castle", rarity: .legendary, collectionCategory: "General", isRare: true),
        Item.collectible(name: "Gear", description: "Mechanical gear", iconName: "icon_gear", collectionCategory: "General"),
        Item.collectible(name: "Bag", description: "Storage bag", iconName: "icon_bag", collectionCategory: "General"),
        Item.collectible(name: "Item Pouch Green", description: "Green item pouch", iconName: "item_pouch_green", collectionCategory: "General")
    ]
    
    // MARK: - All Items
    static var allItems: [Item] {
        return allHealthPotions + allXPBoosts + allCoinBoosts + allCollectibles
    }
    
    static var allHealthPotions: [Item] {
        return [minorHealthPotion, healthPotion, greaterHealthPotion, superiorHealthPotion, legendaryHealthPotion]
    }
    
    static var allXPBoosts: [Item] {
        return [minorXPBoost, xpBoost, greaterXPBoost, legendaryXPBoost]
    }
    
    static var allCoinBoosts: [Item] {
        return [minorCoinBoost, coinBoost, greaterCoinBoost, legendaryCoinBoost]
    }
    
    // MARK: - Helper Methods
    func findItem(by name: String) -> Item? {
        return ItemDatabase.allItems.first { $0.name == name }
    }
    
    func getRandomItem() -> Item {
        return ItemDatabase.allItems.randomElement() ?? ItemDatabase.healthPotion
    }
    
    func getItems(of type: ItemType) -> [Item] {
        return ItemDatabase.allItems.filter { $0.itemType == type }
    }
    
    func getItems(of rarity: ItemRarity) -> [Item] {
        return ItemDatabase.allItems.filter { $0.rarity == rarity }
    }
}
