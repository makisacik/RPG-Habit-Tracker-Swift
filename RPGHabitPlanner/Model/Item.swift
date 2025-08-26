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
    case common = "common"
    case uncommon = "uncommon"
    case rare = "rare"
    case epic = "epic"
    case legendary = "legendary"

    var sortOrder: Int {
        switch self {
        case .common: return 0
        case .uncommon: return 1
        case .rare: return 2
        case .epic: return 3
        case .legendary: return 4
        }
    }

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
    
    var localizedName: String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}

// MARK: - Item Types

enum ItemType: String, CaseIterable, Codable {
    case consumable = "consumable"
    case accessory = "accessory"
    case gear = "gear"
    case booster = "booster"
    case collectible = "collectible"

    var description: String {
        switch self {
        case .consumable:
            return String(localized: "item_type_consumable_description")
        case .accessory:
            return String(localized: "item_type_accessory_description")
        case .gear:
            return String(localized: "item_type_gear_description")
        case .booster:
            return String(localized: "item_type_booster_description")
        case .collectible:
            return String(localized: "item_type_collectible_description")
        }
    }
    
    var localizedName: String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}

// MARK: - Gear Categories

enum GearCategory: String, CaseIterable, Codable {
    case head = "head"
    case outfit = "outfit"
    case weapon = "weapon"
    case shield = "shield"
    case wings = "wings"
    case pet = "pet"

    var description: String {
        switch self {
        case .head:
            return String(localized: "gear_category_head_description")
        case .outfit:
            return String(localized: "gear_category_outfit_description")
        case .weapon:
            return String(localized: "gear_category_weapon_description")
        case .shield:
            return String(localized: "gear_category_shield_description")
        case .wings:
            return String(localized: "gear_category_wings_description")
        case .pet:
            return String(localized: "gear_category_pet_description")
        }
    }
    
    var localizedName: String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}

// MARK: - Accessory Categories

enum AccessoryCategory: String, CaseIterable, Codable {
    case earrings = "earrings"
    case eyeglasses = "eyeglasses"
    case lashes = "lashes"
    case clips = "clips"

    var description: String {
        switch self {
        case .earrings:
            return String(localized: "accessory_category_earrings_description")
        case .eyeglasses:
            return String(localized: "accessory_category_eyeglasses_description")
        case .lashes:
            return String(localized: "accessory_category_lashes_description")
        case .clips:
            return String(localized: "accessory_category_clips_description")
        }
    }
    
    var localizedName: String {
        return NSLocalizedString(self.rawValue, comment: "")
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
    let previewImage: String
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
        previewImage: String? = nil,
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
        self.previewImage = previewImage ?? "\(iconName)_preview"
        self.itemType = itemType
        self.value = value
        self.collectionCategory = collectionCategory
        self.isRare = isRare
        self.effects = effects
        self.usageData = usageData
        self.gearCategory = gearCategory
        self.accessoryCategory = accessoryCategory
        
        // Only gear items should have rarity
        if itemType == .gear {
            self.rarity = rarity
        } else {
            self.rarity = nil
            if rarity != nil {
                print("⚠️ Warning: Non-gear item '\(name)' has rarity set. Rarity will be ignored.")
            }
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
            previewImage: "icon_flask_red_preview",
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
            previewImage: "icon_lightning_preview",
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
            previewImage: "icon_flask_purple_preview",
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
            previewImage: "\(iconName)_preview",
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
            previewImage: "\(iconName)_preview",
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
        case attack = "attack"
        case defense = "defense"
        case health = "health"
        case focus = "focus"
        case experience = "experience"
        case luck = "luck"
        case speed = "speed"
        case criticalChance = "critical_chance"
        case criticalDamage = "critical_damage"
        case xpBoost = "xp_boost"
        case coinBoost = "coin_boost"
        case healthRegeneration = "health_regeneration"
        case focusRegeneration = "focus_regeneration"

        var localizedName: String {
            return String(localized: String.LocalizationValue(self.rawValue))
        }

        var description: String {
            switch self {
            case .attack: return String(localized: "item_effect_attack_description")
            case .defense: return String(localized: "item_effect_defense_description")
            case .health: return String(localized: "item_effect_health_description")
            case .focus: return String(localized: "item_effect_focus_description")
            case .experience: return String(localized: "item_effect_experience_description")
            case .luck: return String(localized: "item_effect_luck_description")
            case .speed: return String(localized: "item_effect_speed_description")
            case .criticalChance: return String(localized: "item_effect_critical_chance_description")
            case .criticalDamage: return String(localized: "item_effect_critical_damage_description")
            case .xpBoost: return String(localized: "item_effect_xp_boost_description")
            case .coinBoost: return String(localized: "item_effect_coin_boost_description")
            case .healthRegeneration: return String(localized: "item_effect_health_regeneration_description")
            case .focusRegeneration: return String(localized: "item_effect_focus_regeneration_description")
            }
        }

        var icon: String {
            switch self {
            case .attack: return "icon_sword"
            case .defense: return "icon_shield"
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
        name: String(localized: "lesser_healing_elixir"),
        description: String(localized: "lesser_healing_elixir_description"),
        healAmount: 15,
        value: 25
    )

    static let healthPotion = Item.healthPotion(
        name: String(localized: "vitality_draught"),
        description: String(localized: "vitality_draught_description"),
        healAmount: 30,
        value: 50
    )

    static let greaterHealthPotion = Item.healthPotion(
        name: String(localized: "greater_restoration_tonic"),
        description: String(localized: "greater_restoration_tonic_description"),
        healAmount: 50,
        value: 100
    )

    static let superiorHealthPotion = Item.healthPotion(
        name: String(localized: "supreme_life_essence"),
        description: String(localized: "supreme_life_essence_description"),
        healAmount: 75,
        value: 200
    )

    static let legendaryHealthPotion = Item.healthPotion(
        name: String(localized: "phoenix_tears"),
        description: String(localized: "phoenix_tears_description"),
        healAmount: 999,
        value: 500
    )

    // MARK: - XP Boosts (Boosters)
    static let minorXPBoost = Item.xpBoost(
        name: String(localized: "wisdoms_breath"),
        description: String(localized: "wisdoms_breath_description"),
        multiplier: 1.25,
        duration: 12 * 60 * 60, // 12 hours
        value: 200
    )

    static let xpBoost = Item.xpBoost(
        name: String(localized: "scholars_insight"),
        description: String(localized: "scholars_insight_description"),
        multiplier: 1.5,
        duration: 24 * 60 * 60, // 24 hours (1 day)
        value: 400
    )

    static let greaterXPBoost = Item.xpBoost(
        name: String(localized: "masters_enlightenment"),
        description: String(localized: "masters_enlightenment_description"),
        multiplier: 2.0,
        duration: 3 * 24 * 60 * 60, // 3 days
        value: 800
    )

    static let legendaryXPBoost = Item.xpBoost(
        name: String(localized: "ancient_knowledge_essence"),
        description: String(localized: "ancient_knowledge_essence_description"),
        multiplier: 3.0,
        duration: 7 * 24 * 60 * 60, // 7 days
        value: 1500
    )

    // MARK: - Coin Boosts (Boosters)
    static let minorCoinBoost = Item.coinBoost(
        name: String(localized: "merchants_blessing"),
        description: String(localized: "merchants_blessing_description"),
        multiplier: 1.25,
        duration: 12 * 60 * 60, // 12 hours
        value: 200
    )

    static let coinBoost = Item.coinBoost(
        name: String(localized: "wealth_attractor"),
        description: String(localized: "wealth_attractor_description"),
        multiplier: 1.5,
        duration: 24 * 60 * 60, // 24 hours (1 day)
        value: 400
    )

    static let greaterCoinBoost = Item.coinBoost(
        name: String(localized: "golden_fortune"),
        description: String(localized: "golden_fortune_description"),
        multiplier: 2.0,
        duration: 3 * 24 * 60 * 60, // 3 days
        value: 800
    )

    static let legendaryCoinBoost = Item.coinBoost(
        name: String(localized: "dragons_hoard_essence"),
        description: String(localized: "dragons_hoard_essence_description"),
        multiplier: 3.0,
        duration: 7 * 24 * 60 * 60, // 7 days
        value: 1500
    )

    // MARK: - Accessories
    static let allAccessories: [Item] = [
        // Clips (Flowers)
        Item.accessory(name: String(localized: "azure_bloom"), description: String(localized: "azure_bloom_description"), iconName: "char_flower_blue", category: .clips),
        Item.accessory(name: String(localized: "emerald_petal"), description: String(localized: "emerald_petal_description"), iconName: "char_flower_green", category: .clips),
        Item.accessory(name: String(localized: "amethyst_blossom"), description: String(localized: "amethyst_blossom_description"), iconName: "char_flower_purple", category: .clips),
        
        // Eyeglasses
        Item.accessory(name: String(localized: "sapphire_spectacles"), description: String(localized: "sapphire_spectacles_description"), iconName: "char_glass_blue", category: .eyeglasses),
        Item.accessory(name: String(localized: "shadow_lenses"), description: String(localized: "shadow_lenses_description"), iconName: "char_glass_gray", category: .eyeglasses),
        Item.accessory(name: String(localized: "ruby_frames"), description: String(localized: "ruby_frames_description"), iconName: "char_glass_red", category: .eyeglasses),
        
        // Earrings
        Item.accessory(name: String(localized: "moonstone_stud"), description: String(localized: "moonstone_stud_description"), iconName: "char_earring_1", category: .earrings),
        Item.accessory(name: String(localized: "starlight_hoop"), description: String(localized: "starlight_hoop_description"), iconName: "char_earring_2", category: .earrings),
        
        // Lashes
        Item.accessory(name: String(localized: "rose_blush"), description: String(localized: "rose_blush_description"), iconName: "char_blush", category: .lashes)
    ]

    // MARK: - Gear Items
    static let allGear: [Item] = [
        // Head Gear
        Item.gear(name: String(localized: "shadow_veil"), description: String(localized: "shadow_veil_description"), iconName: "char_helmet_hood", category: .head, rarity: .rare, value: 250),
        Item.gear(name: String(localized: "ironclad_crown"), description: String(localized: "ironclad_crown_description"), iconName: "char_helmet_iron", category: .head, rarity: .epic, value: 500),
        Item.gear(name: String(localized: "crimson_crest"), description: String(localized: "crimson_crest_description"), iconName: "char_helmet_red", category: .head, rarity: .epic, value: 500),

        // Outfits
        Item.gear(name: String(localized: "peasants_garb"), description: String(localized: "peasants_garb_description"), iconName: "char_outfit_villager", category: .outfit, rarity: .common, value: 50),
        Item.gear(name: String(localized: "azure_tunic"), description: String(localized: "azure_tunic_description"), iconName: "char_outfit_villager_blue", category: .outfit, rarity: .common, value: 50),
        Item.gear(name: String(localized: "comfort_cloak"), description: String(localized: "comfort_cloak_description"), iconName: "char_outfit_hoodie", category: .outfit, rarity: .uncommon, value: 100),
        Item.gear(name: String(localized: "silken_grace"), description: String(localized: "silken_grace_description"), iconName: "char_outfit_dress", category: .outfit, rarity: .rare, value: 250),
        Item.gear(name: String(localized: "ironclad_plate"), description: String(localized: "ironclad_plate_description"), iconName: "char_outfit_iron", category: .outfit, rarity: .rare, value: 250),
        Item.gear(name: String(localized: "reinforced_ironclad"), description: String(localized: "reinforced_ironclad_description"), iconName: "char_outfit_iron_2", category: .outfit, rarity: .rare, value: 250),
        Item.gear(name: String(localized: "crimson_raiment"), description: String(localized: "crimson_raiment_description"), iconName: "char_outfit_red", category: .outfit, rarity: .legendary, value: 1250),
        Item.gear(name: String(localized: "arcane_robes"), description: String(localized: "arcane_robes_description"), iconName: "char_outfit_wizard", category: .outfit, rarity: .rare, value: 250),
        Item.gear(name: String(localized: "nightwing_shroud"), description: String(localized: "nightwing_shroud_description"), iconName: "char_outfit_bat", category: .outfit, rarity: .epic, value: 500),
        Item.gear(name: String(localized: "inferno_mantle"), description: String(localized: "inferno_mantle_description"), iconName: "char_outfit_fire", category: .outfit, rarity: .legendary, value: 1250),

        // Wings
        Item.gear(name: String(localized: "celestial_wings"), description: String(localized: "celestial_wings_description"), iconName: "char_wings_white", category: .wings, rarity: .epic, value: 500),
        Item.gear(name: String(localized: "phoenix_wings"), description: String(localized: "phoenix_wings_description"), iconName: "char_wings_red", category: .wings, rarity: .legendary, value: 1250),
        Item.gear(name: String(localized: "blazing_phoenix"), description: String(localized: "blazing_phoenix_description"), iconName: "char_wings_red_2", category: .wings, rarity: .legendary, value: 1250),
        Item.gear(name: String(localized: "shadow_wings"), description: String(localized: "shadow_wings_description"), iconName: "char_wings_bat", category: .wings, rarity: .legendary, value: 1250),
        
        // Weapons
        Item.gear(name: String(localized: "oakheart_blade"), description: String(localized: "oakheart_blade_description"), iconName: "char_sword_wood", category: .weapon, rarity: .common, value: 50),
        Item.gear(name: String(localized: "copper_fang"), description: String(localized: "copper_fang_description"), iconName: "char_sword_copper", category: .weapon, rarity: .uncommon, value: 100),
        Item.gear(name: String(localized: "ironclad_edge"), description: String(localized: "ironclad_edge_description"), iconName: "char_sword_iron", category: .weapon, rarity: .common, value: 50),
        Item.gear(name: String(localized: "steel_serpent"), description: String(localized: "steel_serpent_description"), iconName: "char_sword_steel", category: .weapon, rarity: .uncommon, value: 100),
        Item.gear(name: String(localized: "crimson_fang"), description: String(localized: "crimson_fang_description"), iconName: "char_sword_red", category: .weapon, rarity: .epic, value: 500),
        Item.gear(name: String(localized: "blazing_fang"), description: String(localized: "blazing_fang_description"), iconName: "char_sword_red_2", category: .weapon, rarity: .legendary, value: 1250),
        Item.gear(name: String(localized: "golden_dawn"), description: String(localized: "golden_dawn_description"), iconName: "char_sword_gold", category: .weapon, rarity: .rare, value: 250),
        Item.gear(name: String(localized: "thunder_axe"), description: String(localized: "thunder_axe_description"), iconName: "char_sword_axe", category: .weapon, rarity: .epic, value: 500),
        Item.gear(name: String(localized: "storm_hatchet"), description: String(localized: "storm_hatchet_description"), iconName: "char_sword_axe_small", category: .weapon, rarity: .uncommon, value: 100),
        Item.gear(name: String(localized: "vipers_lash"), description: String(localized: "vipers_lash_description"), iconName: "char_sword_whip", category: .weapon, rarity: .epic, value: 500),
        Item.gear(name: String(localized: "arcane_staff"), description: String(localized: "arcane_staff_description"), iconName: "char_sword_staff", category: .weapon, rarity: .legendary, value: 1250),
        Item.gear(name: String(localized: "iron_maiden"), description: String(localized: "iron_maiden_description"), iconName: "char_sword_mace", category: .weapon, rarity: .epic, value: 500),
        Item.gear(name: String(localized: "soul_reaper"), description: String(localized: "soul_reaper_description"), iconName: "char_sword_deadly", category: .weapon, rarity: .legendary, value: 1250),
        Item.gear(name: String(localized: "windseeker_bow"), description: String(localized: "windseeker_bow_description"), iconName: "char_weapon_bow_front", category: .weapon, rarity: .rare, value: 250),
        Item.gear(name: String(localized: "stormcaller_bow"), description: String(localized: "stormcaller_bow_description"), iconName: "char_weapon_bow_back", category: .weapon, rarity: .rare, value: 250),
        
        // Shields
        Item.gear(name: String(localized: "oakheart_ward"), description: String(localized: "oakheart_ward_description"), iconName: "char_shield_wood", category: .shield, rarity: .uncommon, value: 100),
        Item.gear(name: String(localized: "crimson_ward"), description: String(localized: "crimson_ward_description"), iconName: "char_shield_red", category: .shield, rarity: .rare, value: 250),
        Item.gear(name: String(localized: "ironclad_bulwark"), description: String(localized: "ironclad_bulwark_description"), iconName: "char_shield_iron", category: .shield, rarity: .rare, value: 250),
        Item.gear(name: String(localized: "golden_aegis"), description: String(localized: "golden_aegis_description"), iconName: "char_shield_gold", category: .shield, rarity: .epic, value: 500),
        
        // Pets
        Item.gear(name: String(localized: "shadowpaw"), description: String(localized: "shadowpaw_description"), iconName: "char_pet_cat", category: .pet, rarity: .epic, value: 500),
        Item.gear(name: String(localized: "whiskerwind"), description: String(localized: "whiskerwind_description"), iconName: "char_pet_cat_2", category: .pet, rarity: .epic, value: 500),
        Item.gear(name: String(localized: "golden_cluck"), description: String(localized: "golden_cluck_description"), iconName: "char_pet_chicken", category: .pet, rarity: .uncommon, value: 100)
    ]

    // MARK: - Collectible Items
    static let allCollectibles: [Item] = [
        Item.collectible(name: String(localized: "crown_of_kings"), description: String(localized: "crown_of_kings_description"), iconName: "icon_crown", collectionCategory: String(localized: "royalty"), isRare: true),
        Item.collectible(name: String(localized: "mystic_egg"), description: String(localized: "mystic_egg_description"), iconName: "icon_egg", collectionCategory: String(localized: "general")),
        Item.collectible(name: String(localized: "thunder_hammer"), description: String(localized: "thunder_hammer_description"), iconName: "icon_hammer", collectionCategory: String(localized: "weapons")),
        Item.collectible(name: String(localized: "golden_key_of_ages"), description: String(localized: "golden_key_of_ages_description"), iconName: "icon_key_gold", collectionCategory: String(localized: "treasure"), isRare: true),
        Item.collectible(name: String(localized: "silver_key_of_secrets"), description: String(localized: "silver_key_of_secrets_description"), iconName: "icon_key_silver", collectionCategory: String(localized: "treasure"), isRare: true),
        Item.collectible(name: String(localized: "medal_of_honor"), description: String(localized: "medal_of_honor_description"), iconName: "icon_medal", collectionCategory: String(localized: "royalty"), isRare: true),
        Item.collectible(name: String(localized: "harvest_pumpkin"), description: String(localized: "harvest_pumpkin_description"), iconName: "icon_pumpkin", collectionCategory: String(localized: "general")),
        Item.collectible(name: String(localized: "ring_of_power"), description: String(localized: "ring_of_power_description"), iconName: "icon_ring", collectionCategory: String(localized: "accessories"), isRare: true),
        Item.collectible(name: String(localized: "treasure_chest"), description: String(localized: "treasure_chest_description"), iconName: "icon_chest", collectionCategory: String(localized: "treasure")),
        Item.collectible(name: String(localized: "azure_treasure_chest"), description: String(localized: "azure_treasure_chest_description"), iconName: "icon_chest_blue", collectionCategory: String(localized: "treasure"), isRare: true),
        Item.collectible(name: String(localized: "opened_treasure_chest"), description: String(localized: "opened_treasure_chest_description"), iconName: "icon_chest_open", collectionCategory: String(localized: "treasure")),
        Item.collectible(name: String(localized: "bronze_trophy_of_valor"), description: String(localized: "bronze_trophy_of_valor_description"), iconName: "icon_trophy_bronze", collectionCategory: String(localized: "trophies")),
        Item.collectible(name: String(localized: "silver_trophy_of_glory"), description: String(localized: "silver_trophy_of_glory_description"), iconName: "icon_trophy_silver", collectionCategory: String(localized: "trophies"), isRare: true),
        Item.collectible(name: String(localized: "golden_trophy_of_legends"), description: String(localized: "golden_trophy_of_legends_description"), iconName: "icon_trophy_gold", collectionCategory: String(localized: "trophies"), isRare: true),
        Item.collectible(name: String(localized: "scroll_of_ancient_wisdom"), description: String(localized: "scroll_of_ancient_wisdom_description"), iconName: "icon_scroll_1", collectionCategory: String(localized: "scrolls")),
        Item.collectible(name: String(localized: "scroll_of_lost_secrets"), description: String(localized: "scroll_of_lost_secrets_description"), iconName: "icon_scroll_2", collectionCategory: String(localized: "scrolls"), isRare: true),
        Item.collectible(name: String(localized: "scroll_of_forbidden_knowledge"), description: String(localized: "scroll_of_forbidden_knowledge_description"), iconName: "icon_scroll_3", collectionCategory: String(localized: "scrolls"), isRare: true),
        Item.collectible(name: String(localized: "bell_of_awakening"), description: String(localized: "bell_of_awakening_description"), iconName: "icon_bell", collectionCategory: String(localized: "general")),
        Item.collectible(name: String(localized: "chronometer"), description: String(localized: "chronometer_description"), iconName: "icon_calendar", collectionCategory: String(localized: "general")),
        Item.collectible(name: String(localized: "lucky_four_leaf_clover"), description: String(localized: "lucky_four_leaf_clover_description"), iconName: "icon_clover", collectionCategory: String(localized: "general"), isRare: true),
        Item.collectible(name: String(localized: "holy_cross"), description: String(localized: "holy_cross_description"), iconName: "icon_cross", collectionCategory: String(localized: "general")),
        Item.collectible(name: String(localized: "phoenix_feather"), description: String(localized: "phoenix_feather_description"), iconName: "icon_feather", collectionCategory: String(localized: "general")),
        Item.collectible(name: String(localized: "essence_of_fire"), description: String(localized: "essence_of_fire_description"), iconName: "icon_fire", collectionCategory: String(localized: "elements")),
        Item.collectible(name: String(localized: "lightning_bolt"), description: String(localized: "lightning_bolt_description"), iconName: "icon_lightning", collectionCategory: String(localized: "elements")),
        Item.collectible(name: String(localized: "strength_totem"), description: String(localized: "strength_totem_description"), iconName: "icon_muscle", collectionCategory: String(localized: "general")),
        Item.collectible(name: String(localized: "starlight_fragment"), description: String(localized: "starlight_fragment_description"), iconName: "icon_star_fill", collectionCategory: String(localized: "general")),
        Item.collectible(name: String(localized: "skull_of_the_fallen"), description: String(localized: "skull_of_the_fallen_description"), iconName: "icon_skull", collectionCategory: String(localized: "general")),
        Item.collectible(name: String(localized: "skull_of_the_ancient"), description: String(localized: "skull_of_the_ancient_description"), iconName: "icon_skull_side", collectionCategory: String(localized: "general"))
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
    
    func findItem(byIconName iconName: String) -> Item? {
        print("🔧 ItemDatabase: findItem(byIconName:) called with: \(iconName)")
        let result = ItemDatabase.allItems.first { $0.iconName == iconName }
        if let result = result {
            print("✅ ItemDatabase: Found item: \(result.name) with iconName: \(result.iconName)")
        } else {
            print("❌ ItemDatabase: No item found with iconName: \(iconName)")
            print("🔧 ItemDatabase: Available items with similar names:")
            for item in ItemDatabase.allItems {
                if item.iconName.contains(iconName) || iconName.contains(item.iconName) {
                    print("  - \(item.name) (iconName: \(item.iconName))")
                }
            }
        }
        return result
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
