//
//  Item.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import Foundation
import SwiftUI

// MARK: - Item Rarity (Only for Gear items)

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
    case consumable = "Consumable"
    case accessory = "Accessory"
    case gear = "Gear"
    case booster = "Booster"
    case collectible = "Collectible"

    var description: String {
        switch self {
        case .consumable:
            return "Used once and consumed"
        case .accessory:
            return "Cosmetic accessories for character customization"
        case .gear:
            return "Equippable items with stats and rarities"
        case .booster:
            return "Provides temporary bonuses"
        case .collectible:
            return "Visual items for display and collection"
        }
    }
}

// MARK: - Gear Categories

enum GearCategory: String, CaseIterable, Codable {
    case head = "Head"
    case outfit = "Outfit"
    case wings = "Wings"
    case weapon = "Weapon"
    case shield = "Shield"
    case pet = "Pet"

    var description: String {
        switch self {
        case .head:
            return "Headgear and helmets"
        case .outfit:
            return "Body armor and clothing"
        case .wings:
            return "Wing accessories"
        case .weapon:
            return "Weapons and tools"
        case .shield:
            return "Shields and defensive gear"
        case .pet:
            return "Pet companions"
        }
    }
}

// MARK: - Accessory Categories

enum AccessoryCategory: String, CaseIterable, Codable {
    case earrings = "Earrings"
    case eyeglasses = "Eyeglasses"
    case lashes = "Lashes"
    case clips = "Clips"

    var description: String {
        switch self {
        case .earrings:
            return "Ear accessories"
        case .eyeglasses:
            return "Eye accessories"
        case .lashes:
            return "Eyelash accessories"
        case .clips:
            return "Hair clips and flowers"
        }
    }
}

// MARK: - Base Item Protocol

protocol GameItem: Identifiable, Equatable, Codable {
    var id: UUID { get }
    var name: String { get }
    var description: String { get }
    var iconName: String { get }
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
    let itemType: ItemType
    let value: Int
    let collectionCategory: String?
    let isRare: Bool
    let effects: [ItemEffect]?
    let usageData: ItemUsageData?

    // Gear-specific properties
    let gearCategory: GearCategory?
    let rarity: ItemRarity?

    // Accessory-specific properties
    let accessoryCategory: AccessoryCategory?

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        iconName: String,
        itemType: ItemType = .collectible,
        value: Int = 0,
        collectionCategory: String? = nil,
        isRare: Bool = false,
        effects: [ItemEffect]? = nil,
        usageData: ItemUsageData? = nil,
        gearCategory: GearCategory? = nil,
        rarity: ItemRarity? = nil,
        accessoryCategory: AccessoryCategory? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.iconName = iconName
        self.itemType = itemType
        self.value = value
        self.collectionCategory = collectionCategory
        self.isRare = isRare
        self.effects = effects
        self.usageData = usageData
        self.gearCategory = gearCategory
        self.rarity = rarity
        self.accessoryCategory = accessoryCategory
        
        // Validate that only gear items have rarity
        if itemType != .gear && rarity != nil {
            print("⚠️ Warning: Non-gear item '\(name)' has rarity set. Rarity will be ignored.")
        }
    }

    // MARK: - Convenience Initializers

    static func healthPotion(
        name: String,
        description: String,
        healAmount: Int16,
        value: Int = 0
    ) -> Item {
        return Item(
            name: name,
            description: description,
            iconName: "icon_flask_red",
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
        value: Int = 0
    ) -> Item {
        return Item(
            name: name,
            description: description,
            iconName: "icon_lightning",
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
        value: Int = 0
    ) -> Item {
        return Item(
            name: name,
            description: description,
            iconName: "icon_flask_purple",
            itemType: .booster,
            value: value,
            usageData: .coinBoost(multiplier: multiplier, duration: duration)
        )
    }

    static func accessory(
        name: String,
        description: String,
        iconName: String,
        category: AccessoryCategory,
        value: Int = 0
    ) -> Item {
        return Item(
            name: name,
            description: description,
            iconName: iconName,
            itemType: .accessory,
            value: value,
            accessoryCategory: category
        )
    }

    static func gear(
        name: String,
        description: String,
        iconName: String,
        category: GearCategory,
        rarity: ItemRarity,
        value: Int = 0,
        effects: [ItemEffect]? = nil
    ) -> Item {
        return Item(
            name: name,
            description: description,
            iconName: iconName,
            itemType: .gear,
            value: value,
            effects: effects,
            gearCategory: category,
            rarity: rarity
        )
    }

    static func collectible(
        name: String,
        description: String,
        iconName: String,
        collectionCategory: String? = nil,
        isRare: Bool = false
    ) -> Item {
        return Item(
            name: name,
            description: description,
            iconName: iconName,
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

    // MARK: - Health Potions (Consumables)
    static let minorHealthPotion = Item.healthPotion(
        name: "Minor Health Potion",
        description: "Restores 15 HP. A basic healing potion made from common herbs.",
        healAmount: 15,
        value: 25
    )

    static let healthPotion = Item.healthPotion(
        name: "Health Potion",
        description: "Restores 30 HP. A reliable healing potion for adventurers.",
        healAmount: 30,
        value: 50
    )

    static let greaterHealthPotion = Item.healthPotion(
        name: "Greater Health Potion",
        description: "Restores 50 HP. A powerful healing potion that can save your life.",
        healAmount: 50,
        value: 100
    )

    static let superiorHealthPotion = Item.healthPotion(
        name: "Superior Health Potion",
        description: "Restores 75 HP. An exceptional healing potion with rare ingredients.",
        healAmount: 75,
        value: 200
    )

    static let legendaryHealthPotion = Item.healthPotion(
        name: "Legendary Health Potion",
        description: "Fully restores health. A legendary potion that brings you back from the brink of death.",
        healAmount: 999,
        value: 500
    )

    // MARK: - XP Boosts (Boosters)
    static let minorXPBoost = Item.xpBoost(
        name: "Minor XP Boost",
        description: "Increases XP gain by 25% for 30 minutes",
        multiplier: 1.25,
        duration: 30 * 60,
        value: 50
    )

    static let xpBoost = Item.xpBoost(
        name: "XP Boost",
        description: "Increases XP gain by 50% for 1 hour",
        multiplier: 1.5,
        duration: 60 * 60,
        value: 100
    )

    static let greaterXPBoost = Item.xpBoost(
        name: "Greater XP Boost",
        description: "Increases XP gain by 100% for 2 hours",
        multiplier: 2.0,
        duration: 2 * 60 * 60,
        value: 250
    )

    static let legendaryXPBoost = Item.xpBoost(
        name: "Legendary XP Boost",
        description: "Increases XP gain by 200% for 4 hours",
        multiplier: 3.0,
        duration: 4 * 60 * 60,
        value: 500
    )

    // MARK: - Coin Boosts (Boosters)
    static let minorCoinBoost = Item.coinBoost(
        name: "Minor Coin Boost",
        description: "Increases coin gain by 25% for 30 minutes",
        multiplier: 1.25,
        duration: 30 * 60,
        value: 50
    )

    static let coinBoost = Item.coinBoost(
        name: "Coin Boost",
        description: "Increases coin gain by 50% for 1 hour",
        multiplier: 1.5,
        duration: 60 * 60,
        value: 100
    )

    static let greaterCoinBoost = Item.coinBoost(
        name: "Greater Coin Boost",
        description: "Increases coin gain by 100% for 2 hours",
        multiplier: 2.0,
        duration: 2 * 60 * 60,
        value: 250
    )

    static let legendaryCoinBoost = Item.coinBoost(
        name: "Legendary Coin Boost",
        description: "Increases coin gain by 200% for 4 hours",
        multiplier: 3.0,
        duration: 4 * 60 * 60,
        value: 500
    )

    // MARK: - Accessories
    static let allAccessories: [Item] = [
        // Clips (Flowers)
        Item.accessory(name: "Blue Flower", description: "A beautiful blue flower accessory", iconName: "char_flower_blue", category: .clips),
        Item.accessory(name: "Green Flower", description: "A lovely green flower accessory", iconName: "char_flower_green", category: .clips),
        Item.accessory(name: "Purple Flower", description: "An elegant purple flower accessory", iconName: "char_flower_purple", category: .clips),
        
        // Eyeglasses
        Item.accessory(name: "Blue Glasses", description: "Stylish blue glasses", iconName: "char_glass_blue", category: .eyeglasses),
        Item.accessory(name: "Gray Glasses", description: "Classic gray glasses", iconName: "char_glass_gray", category: .eyeglasses),
        Item.accessory(name: "Red Glasses", description: "Bold red glasses", iconName: "char_glass_red", category: .eyeglasses),
        
        // Earrings
        Item.accessory(name: "Earring 1", description: "A simple earring", iconName: "char_earring_1", category: .earrings),
        Item.accessory(name: "Earring 2", description: "An elegant earring", iconName: "char_earring_2", category: .earrings),
        
        // Lashes
        Item.accessory(name: "Blush", description: "A touch of blush for your cheeks", iconName: "char_blush", category: .lashes)
    ]

    // MARK: - Gear Items
    static let allGear: [Item] = [
        // Head Gear
        Item.gear(name: "Hood", description: "A simple hood for protection", iconName: "char_helmet_hood", category: .head, rarity: .common),
        Item.gear(name: "Iron Helmet", description: "A sturdy iron helmet", iconName: "char_helmet_iron", category: .head, rarity: .uncommon),
        Item.gear(name: "Red Helmet", description: "A striking red helmet", iconName: "char_helmet_red", category: .head, rarity: .rare),

        // Outfits
        Item.gear(name: "Villager Outfit", description: "Simple villager clothing", iconName: "char_outfit_villager", category: .outfit, rarity: .common),
        Item.gear(name: "Blue Villager Outfit", description: "Blue villager clothing", iconName: "char_outfit_villager_blue", category: .outfit, rarity: .common),
        Item.gear(name: "Hoodie", description: "A comfortable hoodie", iconName: "char_outfit_hoodie", category: .outfit, rarity: .uncommon),
        Item.gear(name: "Dress", description: "An elegant dress", iconName: "char_outfit_dress", category: .outfit, rarity: .uncommon),
        Item.gear(name: "Iron Armor", description: "Sturdy iron armor", iconName: "char_outfit_iron", category: .outfit, rarity: .rare),
        Item.gear(name: "Iron Armor 2", description: "Enhanced iron armor", iconName: "char_outfit_iron_2", category: .outfit, rarity: .rare),
        Item.gear(name: "Red Outfit", description: "A bold red outfit", iconName: "char_outfit_red", category: .outfit, rarity: .epic),
        Item.gear(name: "Wizard Robe", description: "A magical wizard robe", iconName: "char_outfit_wizard", category: .outfit, rarity: .epic),
        Item.gear(name: "Bat Outfit", description: "A mysterious bat-themed outfit", iconName: "char_outfit_bat", category: .outfit, rarity: .legendary),
        Item.gear(name: "Fire Outfit", description: "A blazing fire-themed outfit", iconName: "char_outfit_fire", category: .outfit, rarity: .legendary),

        // Wings
        Item.gear(name: "White Wings", description: "Pure white angelic wings", iconName: "char_wings_white", category: .wings, rarity: .rare),
        Item.gear(name: "Red Wings", description: "Fiery red wings", iconName: "char_wings_red", category: .wings, rarity: .epic),
        Item.gear(name: "Red Wings 2", description: "Enhanced red wings", iconName: "char_wings_red_2", category: .wings, rarity: .epic),
        Item.gear(name: "Bat Wings", description: "Dark bat wings", iconName: "char_wings_bat", category: .wings, rarity: .legendary),
        
        // Weapons
        Item.gear(name: "Wooden Sword", description: "A basic wooden sword", iconName: "char_sword_wood", category: .weapon, rarity: .common),
        Item.gear(name: "Copper Sword", description: "A copper sword", iconName: "char_sword_copper", category: .weapon, rarity: .common),
        Item.gear(name: "Iron Sword", description: "A reliable iron sword", iconName: "char_sword_iron", category: .weapon, rarity: .uncommon),
        Item.gear(name: "Steel Sword", description: "A sharp steel sword", iconName: "char_sword_steel", category: .weapon, rarity: .rare),
        Item.gear(name: "Red Sword", description: "A fiery red sword", iconName: "char_sword_red", category: .weapon, rarity: .epic),
        Item.gear(name: "Red Sword 2", description: "An enhanced red sword", iconName: "char_sword_red_2", category: .weapon, rarity: .epic),
        Item.gear(name: "Gold Sword", description: "A golden sword", iconName: "char_sword_gold", category: .weapon, rarity: .legendary),
        Item.gear(name: "Gold Sword 2", description: "An enhanced golden sword", iconName: "char_sword_gold_2", category: .weapon, rarity: .legendary),
        Item.gear(name: "Axe", description: "A heavy axe", iconName: "char_sword_axe", category: .weapon, rarity: .rare),
        Item.gear(name: "Small Axe", description: "A smaller axe", iconName: "char_sword_axe_small", category: .weapon, rarity: .uncommon),
        Item.gear(name: "Whip", description: "A flexible whip", iconName: "char_sword_whip", category: .weapon, rarity: .epic),
        Item.gear(name: "Staff", description: "A magical staff", iconName: "char_sword_staff", category: .weapon, rarity: .epic),
        Item.gear(name: "Mace", description: "A heavy mace", iconName: "char_sword_mace", category: .weapon, rarity: .rare),
        Item.gear(name: "Deadly Sword", description: "A deadly weapon", iconName: "char_sword_deadly", category: .weapon, rarity: .legendary),
        Item.gear(name: "Bow Front", description: "A bow for ranged combat", iconName: "char_weapon_bow_front", category: .weapon, rarity: .rare),
        Item.gear(name: "Bow Back", description: "A bow carried on the back", iconName: "char_weapon_bow_back", category: .weapon, rarity: .rare),
        
        // Shields
        Item.gear(name: "Wooden Shield", description: "A basic wooden shield", iconName: "char_shield_wood", category: .shield, rarity: .common),
        Item.gear(name: "Red Shield", description: "A red shield", iconName: "char_shield_red", category: .shield, rarity: .uncommon),
        Item.gear(name: "Iron Shield", description: "A sturdy iron shield", iconName: "char_shield_iron", category: .shield, rarity: .rare),
        Item.gear(name: "Gold Shield", description: "A golden shield", iconName: "char_shield_gold", category: .shield, rarity: .epic),
        
        // Pets
        Item.gear(name: "Cat Pet", description: "A friendly cat companion", iconName: "char_pet_cat", category: .pet, rarity: .rare),
        Item.gear(name: "Cat Pet 2", description: "Another friendly cat companion", iconName: "char_pet_cat_2", category: .pet, rarity: .rare),
        Item.gear(name: "Chicken Pet", description: "A loyal chicken companion", iconName: "char_pet_chicken", category: .pet, rarity: .epic)
    ]

    // MARK: - Collectible Items
    static let allCollectibles: [Item] = [
        Item.collectible(name: "Crown", description: "Symbol of royalty", iconName: "icon_crown", collectionCategory: "Royalty", isRare: true),
        Item.collectible(name: "Egg", description: "Mysterious egg, what's inside?", iconName: "icon_egg", collectionCategory: "General"),
        Item.collectible(name: "Hammer", description: "Tool or weapon for strong strikes", iconName: "icon_hammer", collectionCategory: "Weapons"),
        Item.collectible(name: "Key Gold", description: "Opens golden locks", iconName: "icon_key_gold", collectionCategory: "Treasure", isRare: true),
        Item.collectible(name: "Key Silver", description: "Opens silver locks", iconName: "icon_key_silver", collectionCategory: "Treasure", isRare: true),
        Item.collectible(name: "Medal", description: "Award for great achievements", iconName: "icon_medal", collectionCategory: "Royalty", isRare: true),
        Item.collectible(name: "Pumpkin", description: "Festive pumpkin", iconName: "icon_pumpkin", collectionCategory: "General"),
        Item.collectible(name: "Ring", description: "Magical ring with special properties", iconName: "icon_ring", collectionCategory: "Accessories", isRare: true),
        Item.collectible(name: "Chest", description: "Treasure chest", iconName: "icon_chest", collectionCategory: "Treasure"),
        Item.collectible(name: "Chest Blue", description: "Rare blue treasure chest", iconName: "icon_chest_blue", collectionCategory: "Treasure", isRare: true),
        Item.collectible(name: "Chest Open", description: "Opened treasure chest", iconName: "icon_chest_open", collectionCategory: "Treasure"),
        Item.collectible(name: "Trophy Bronze", description: "Bronze trophy for achievements", iconName: "icon_trophy_bronze", collectionCategory: "Trophies"),
        Item.collectible(name: "Trophy Silver", description: "Silver trophy for achievements", iconName: "icon_trophy_silver", collectionCategory: "Trophies", isRare: true),
        Item.collectible(name: "Trophy Gold", description: "Gold trophy for achievements", iconName: "icon_trophy_gold", collectionCategory: "Trophies", isRare: true),
        Item.collectible(name: "Scroll 1", description: "Ancient scroll with knowledge", iconName: "icon_scroll_1", collectionCategory: "Scrolls"),
        Item.collectible(name: "Scroll 2", description: "Ancient scroll with knowledge", iconName: "icon_scroll_2", collectionCategory: "Scrolls", isRare: true),
        Item.collectible(name: "Scroll 3", description: "Ancient scroll with knowledge", iconName: "icon_scroll_3", collectionCategory: "Scrolls", isRare: true),
        Item.collectible(name: "Bell", description: "Magical bell", iconName: "icon_bell", collectionCategory: "General"),
        Item.collectible(name: "Calendar", description: "Calendar for tracking time", iconName: "icon_calendar", collectionCategory: "General"),
        Item.collectible(name: "Clover", description: "Lucky four-leaf clover", iconName: "icon_clover", collectionCategory: "General", isRare: true),
        Item.collectible(name: "Cross", description: "Holy cross", iconName: "icon_cross", collectionCategory: "General"),
        Item.collectible(name: "Feather", description: "Light as a feather", iconName: "icon_feather", collectionCategory: "General"),
        Item.collectible(name: "Fire", description: "Element of fire", iconName: "icon_fire", collectionCategory: "Elements"),
        Item.collectible(name: "Lightning", description: "Element of lightning", iconName: "icon_lightning", collectionCategory: "Elements"),
        Item.collectible(name: "Muscle", description: "Symbol of strength", iconName: "icon_muscle", collectionCategory: "General"),
        Item.collectible(name: "Star Fill", description: "Bright star", iconName: "icon_star_fill", collectionCategory: "General"),
        Item.collectible(name: "Skull", description: "Mysterious skull", iconName: "icon_skull", collectionCategory: "General"),
        Item.collectible(name: "Skull Side", description: "Side view of a skull", iconName: "icon_skull_side", collectionCategory: "General")
    ]

    // MARK: - All Items
    static var allItems: [Item] {
        return allHealthPotions + allXPBoosts + allCoinBoosts + allAccessories + allGear + allCollectibles
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

    func getGearItems(of category: GearCategory) -> [Item] {
        return ItemDatabase.allGear.filter { $0.gearCategory == category }
    }

    func getGearItems(of category: GearCategory, rarity: ItemRarity) -> [Item] {
        return ItemDatabase.allGear.filter { $0.gearCategory == category && $0.rarity == rarity }
    }
}
