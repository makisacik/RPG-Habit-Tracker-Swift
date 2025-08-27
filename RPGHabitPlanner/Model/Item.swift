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
            return "item_type_consumable_description".localized
        case .accessory:
            return "item_type_accessory_description".localized
        case .gear:
            return "item_type_gear_description".localized
        case .booster:
            return "item_type_booster_description".localized
        case .collectible:
            return "item_type_collectible_description".localized
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
            return "gear_category_head_description".localized
        case .outfit:
            return "gear_category_outfit_description".localized
        case .weapon:
            return "gear_category_weapon_description".localized
        case .shield:
            return "gear_category_shield_description".localized
        case .wings:
            return "gear_category_wings_description".localized
        case .pet:
            return "gear_category_pet_description".localized
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
            return "accessory_category_earrings_description".localized
        case .eyeglasses:
            return "accessory_category_eyeglasses_description".localized
        case .lashes:
            return "accessory_category_lashes_description".localized
        case .clips:
            return "accessory_category_clips_description".localized
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

    // MARK: - Computed Properties
    
    /// Gets the localized name for this item
    var localizedName: String {
        return name
    }
    
    /// Gets the localized description for this item
    var localizedDescription: String {
        return description
    }

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
            return self.rawValue.localized
        }

        var description: String {
            switch self {
            case .attack: return "item_effect_attack_description".localized
            case .defense: return "item_effect_defense_description".localized
            case .health: return "item_effect_health_description".localized
            case .focus: return "item_effect_focus_description".localized
            case .experience: return "item_effect_experience_description".localized
            case .luck: return "item_effect_luck_description".localized
            case .speed: return "item_effect_speed_description".localized
            case .criticalChance: return "item_effect_critical_chance_description".localized
            case .criticalDamage: return "item_effect_critical_damage_description".localized
            case .xpBoost: return "item_effect_xp_boost_description".localized
            case .coinBoost: return "item_effect_coin_boost_description".localized
            case .healthRegeneration: return "item_effect_health_regeneration_description".localized
            case .focusRegeneration: return "item_effect_focus_regeneration_description".localized
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
        name: "lesser_healing_elixir".localized,
        description: "lesser_healing_elixir_description".localized,
        healAmount: 15,
        value: 25
    )

    static let healthPotion = Item.healthPotion(
        name: "vitality_draught".localized,
        description: "vitality_draught_description".localized,
        healAmount: 30,
        value: 50
    )

    static let greaterHealthPotion = Item.healthPotion(
        name: "greater_restoration_tonic".localized,
        description: "greater_restoration_tonic_description".localized,
        healAmount: 50,
        value: 100
    )

    static let superiorHealthPotion = Item.healthPotion(
        name: "supreme_life_essence".localized,
        description: "supreme_life_essence_description".localized,
        healAmount: 75,
        value: 200
    )

    static let legendaryHealthPotion = Item.healthPotion(
        name: "phoenix_tears".localized,
        description: "phoenix_tears_description".localized,
        healAmount: 999,
        value: 500
    )

    // MARK: - XP Boosts (Boosters)
    static let minorXPBoost = Item.xpBoost(
        name: "wisdoms_breath".localized,
        description: "wisdoms_breath_description".localized,
        multiplier: 1.25,
        duration: 12 * 60 * 60, // 12 hours
        value: 200
    )

    static let xpBoost = Item.xpBoost(
        name: "scholars_insight".localized,
        description: "scholars_insight_description".localized,
        multiplier: 1.5,
        duration: 24 * 60 * 60, // 24 hours (1 day)
        value: 400
    )

    static let greaterXPBoost = Item.xpBoost(
        name: "masters_enlightenment".localized,
        description: "masters_enlightenment_description".localized,
        multiplier: 2.0,
        duration: 3 * 24 * 60 * 60, // 3 days
        value: 800
    )

    static let legendaryXPBoost = Item.xpBoost(
        name: "ancient_knowledge_essence".localized,
        description: "ancient_knowledge_essence_description".localized,
        multiplier: 3.0,
        duration: 7 * 24 * 60 * 60, // 7 days
        value: 1500
    )

    // MARK: - Coin Boosts (Boosters)
    static let minorCoinBoost = Item.coinBoost(
        name: "merchants_blessing".localized,
        description: "merchants_blessing_description".localized,
        multiplier: 1.25,
        duration: 12 * 60 * 60, // 12 hours
        value: 200
    )

    static let coinBoost = Item.coinBoost(
        name: "wealth_attractor".localized,
        description: "wealth_attractor_description".localized,
        multiplier: 1.5,
        duration: 24 * 60 * 60, // 24 hours (1 day)
        value: 400
    )

    static let greaterCoinBoost = Item.coinBoost(
        name: "golden_fortune".localized,
        description: "golden_fortune_description".localized,
        multiplier: 2.0,
        duration: 3 * 24 * 60 * 60, // 3 days
        value: 800
    )

    static let legendaryCoinBoost = Item.coinBoost(
        name: "dragons_hoard_essence".localized,
        description: "dragons_hoard_essence_description".localized,
        multiplier: 3.0,
        duration: 7 * 24 * 60 * 60, // 7 days
        value: 1500
    )

    // MARK: - Accessories
    static let allAccessories: [Item] = [
        // Clips (Flowers)
        Item.accessory(name: "azure_bloom".localized, description: "azure_bloom_description".localized, iconName: "char_flower_blue", category: .clips),
        Item.accessory(name: "emerald_petal".localized, description: "emerald_petal_description".localized, iconName: "char_flower_green", category: .clips),
        Item.accessory(name: "amethyst_blossom".localized, description: "amethyst_blossom_description".localized, iconName: "char_flower_purple", category: .clips),
        
        // Eyeglasses
        Item.accessory(name: "sapphire_spectacles".localized, description: "sapphire_spectacles_description".localized, iconName: "char_glass_blue", category: .eyeglasses),
        Item.accessory(name: "shadow_lenses".localized, description: "shadow_lenses_description".localized, iconName: "char_glass_gray", category: .eyeglasses),
        Item.accessory(name: "ruby_frames".localized, description: "ruby_frames_description".localized, iconName: "char_glass_red", category: .eyeglasses),
        
        // Earrings
        Item.accessory(name: "moonstone_stud".localized, description: "moonstone_stud_description".localized, iconName: "char_earring_1", category: .earrings),
        Item.accessory(name: "starlight_hoop".localized, description: "starlight_hoop_description".localized, iconName: "char_earring_2", category: .earrings),
        
        // Lashes
        Item.accessory(name: "rose_blush".localized, description: "rose_blush_description".localized, iconName: "char_blush", category: .lashes)
    ]

    // MARK: - Gear Items
    static let allGear: [Item] = [
        // Head Gear
        Item.gear(name: "shadow_veil".localized, description: "shadow_veil_description".localized, iconName: "char_helmet_hood", category: .head, rarity: .rare, value: 250),
        Item.gear(name: "ironclad_crown".localized, description: "ironclad_crown_description".localized, iconName: "char_helmet_iron", category: .head, rarity: .epic, value: 500),
        Item.gear(name: "crimson_crest".localized, description: "crimson_crest_description".localized, iconName: "char_helmet_red", category: .head, rarity: .epic, value: 500),

        // Outfits
        Item.gear(name: "peasants_garb".localized, description: "peasants_garb_description".localized, iconName: "char_outfit_villager", category: .outfit, rarity: .common, value: 50),
        Item.gear(name: "azure_tunic".localized, description: "azure_tunic_description".localized, iconName: "char_outfit_villager_blue", category: .outfit, rarity: .common, value: 50),
        Item.gear(name: "comfort_cloak".localized, description: "comfort_cloak_description".localized, iconName: "char_outfit_hoodie", category: .outfit, rarity: .uncommon, value: 100),
        Item.gear(name: "silken_grace".localized, description: "silken_grace_description".localized, iconName: "char_outfit_dress", category: .outfit, rarity: .rare, value: 250),
        Item.gear(name: "ironclad_plate".localized, description: "ironclad_plate_description".localized, iconName: "char_outfit_iron", category: .outfit, rarity: .rare, value: 250),
        Item.gear(name: "reinforced_ironclad".localized, description: "reinforced_ironclad_description".localized, iconName: "char_outfit_iron_2", category: .outfit, rarity: .rare, value: 250),
        Item.gear(name: "crimson_raiment".localized, description: "crimson_raiment_description".localized, iconName: "char_outfit_red", category: .outfit, rarity: .legendary, value: 1250),
        Item.gear(name: "arcane_robes".localized, description: "arcane_robes_description".localized, iconName: "char_outfit_wizard", category: .outfit, rarity: .rare, value: 250),
        Item.gear(name: "nightwing_shroud".localized, description: "nightwing_shroud_description".localized, iconName: "char_outfit_bat", category: .outfit, rarity: .epic, value: 500),
        Item.gear(name: "inferno_mantle".localized, description: "inferno_mantle_description".localized, iconName: "char_outfit_fire", category: .outfit, rarity: .legendary, value: 1250),

        // Wings
        Item.gear(name: "celestial_wings".localized, description: "celestial_wings_description".localized, iconName: "char_wings_white", category: .wings, rarity: .epic, value: 500),
        Item.gear(name: "phoenix_wings".localized, description: "phoenix_wings_description".localized, iconName: "char_wings_red", category: .wings, rarity: .legendary, value: 1250),
        Item.gear(name: "blazing_phoenix".localized, description: "blazing_phoenix_description".localized, iconName: "char_wings_red_2", category: .wings, rarity: .legendary, value: 1250),
        Item.gear(name: "shadow_wings".localized, description: "shadow_wings_description".localized, iconName: "char_wings_bat", category: .wings, rarity: .legendary, value: 1250),
        
        // Weapons
        Item.gear(name: "oakheart_blade".localized, description: "oakheart_blade_description".localized, iconName: "char_sword_wood", category: .weapon, rarity: .common, value: 50),
        Item.gear(name: "copper_fang".localized, description: "copper_fang_description".localized, iconName: "char_sword_copper", category: .weapon, rarity: .uncommon, value: 100),
        Item.gear(name: "ironclad_edge".localized, description: "ironclad_edge_description".localized, iconName: "char_sword_iron", category: .weapon, rarity: .common, value: 50),
        Item.gear(name: "steel_serpent".localized, description: "steel_serpent_description".localized, iconName: "char_sword_steel", category: .weapon, rarity: .uncommon, value: 100),
        Item.gear(name: "crimson_fang".localized, description: "crimson_fang_description".localized, iconName: "char_sword_red", category: .weapon, rarity: .epic, value: 500),
        Item.gear(name: "blazing_fang".localized, description: "blazing_fang_description".localized, iconName: "char_sword_red_2", category: .weapon, rarity: .legendary, value: 1250),
        Item.gear(name: "golden_dawn".localized, description: "golden_dawn_description".localized, iconName: "char_sword_gold", category: .weapon, rarity: .rare, value: 250),
        Item.gear(name: "thunder_axe".localized, description: "thunder_axe_description".localized, iconName: "char_sword_axe", category: .weapon, rarity: .epic, value: 500),
        Item.gear(name: "storm_hatchet".localized, description: "storm_hatchet_description".localized, iconName: "char_sword_axe_small", category: .weapon, rarity: .uncommon, value: 100),
        Item.gear(name: "vipers_lash".localized, description: "vipers_lash_description".localized, iconName: "char_sword_whip", category: .weapon, rarity: .epic, value: 500),
        Item.gear(name: "arcane_staff".localized, description: "arcane_staff_description".localized, iconName: "char_sword_staff", category: .weapon, rarity: .legendary, value: 1250),
        Item.gear(name: "iron_maiden".localized, description: "iron_maiden_description".localized, iconName: "char_sword_mace", category: .weapon, rarity: .epic, value: 500),
        Item.gear(name: "soul_reaper".localized, description: "soul_reaper_description".localized, iconName: "char_sword_deadly", category: .weapon, rarity: .legendary, value: 1250),
        Item.gear(name: "windseeker_bow".localized, description: "windseeker_bow_description".localized, iconName: "char_weapon_bow_front", category: .weapon, rarity: .rare, value: 250),
        Item.gear(name: "stormcaller_bow".localized, description: "stormcaller_bow_description".localized, iconName: "char_weapon_bow_back", category: .weapon, rarity: .rare, value: 250),
        
        // Shields
        Item.gear(name: "oakheart_ward".localized, description: "oakheart_ward_description".localized, iconName: "char_shield_wood", category: .shield, rarity: .uncommon, value: 100),
        Item.gear(name: "crimson_ward".localized, description: "crimson_ward_description".localized, iconName: "char_shield_red", category: .shield, rarity: .rare, value: 250),
        Item.gear(name: "ironclad_bulwark".localized, description: "ironclad_bulwark_description".localized, iconName: "char_shield_iron", category: .shield, rarity: .rare, value: 250),
        Item.gear(name: "golden_aegis".localized, description: "golden_aegis_description".localized, iconName: "char_shield_gold", category: .shield, rarity: .epic, value: 500),
        
        // Pets
        Item.gear(name: "shadowpaw".localized, description: "shadowpaw_description".localized, iconName: "char_pet_cat", category: .pet, rarity: .epic, value: 500),
        Item.gear(name: "whiskerwind".localized, description: "whiskerwind_description".localized, iconName: "char_pet_cat_2", category: .pet, rarity: .epic, value: 500),
        Item.gear(name: "golden_cluck".localized, description: "golden_cluck_description".localized, iconName: "char_pet_chicken", category: .pet, rarity: .uncommon, value: 100)
    ]

    // MARK: - Collectible Items
    static let allCollectibles: [Item] = [
        Item.collectible(name: "crown_of_kings".localized, description: "crown_of_kings_description".localized, iconName: "icon_crown", collectionCategory: "royalty".localized, isRare: true),
        Item.collectible(name: "mystic_egg".localized, description: "mystic_egg_description".localized, iconName: "icon_egg", collectionCategory: "general".localized),
        Item.collectible(name: "thunder_hammer".localized, description: "thunder_hammer_description".localized, iconName: "icon_hammer", collectionCategory: "weapons".localized),
        Item.collectible(name: "golden_key_of_ages".localized, description: "golden_key_of_ages_description".localized, iconName: "icon_key_gold", collectionCategory: "treasure".localized, isRare: true),
        Item.collectible(name: "silver_key_of_secrets".localized, description: "silver_key_of_secrets_description".localized, iconName: "icon_key_silver", collectionCategory: "treasure".localized, isRare: true),
        Item.collectible(name: "medal_of_honor".localized, description: "medal_of_honor_description".localized, iconName: "icon_medal", collectionCategory: "royalty".localized, isRare: true),
        Item.collectible(name: "harvest_pumpkin".localized, description: "harvest_pumpkin_description".localized, iconName: "icon_pumpkin", collectionCategory: "general".localized),
        Item.collectible(name: "ring_of_power".localized, description: "ring_of_power_description".localized, iconName: "icon_ring", collectionCategory: "accessories".localized, isRare: true),
        Item.collectible(name: "treasure_chest".localized, description: "treasure_chest_description".localized, iconName: "icon_chest", collectionCategory: "treasure".localized),
        Item.collectible(name: "azure_treasure_chest".localized, description: "azure_treasure_chest_description".localized, iconName: "icon_chest_blue", collectionCategory: "treasure".localized, isRare: true),
        Item.collectible(name: "opened_treasure_chest".localized, description: "opened_treasure_chest_description".localized, iconName: "icon_chest_open", collectionCategory: "treasure".localized),
        Item.collectible(name: "bronze_trophy_of_valor".localized, description: "bronze_trophy_of_valor_description".localized, iconName: "icon_trophy_bronze", collectionCategory: "trophies".localized),
        Item.collectible(name: "silver_trophy_of_glory".localized, description: "silver_trophy_of_glory_description".localized, iconName: "icon_trophy_silver", collectionCategory: "trophies".localized, isRare: true),
        Item.collectible(name: "golden_trophy_of_legends".localized, description: "golden_trophy_of_legends_description".localized, iconName: "icon_trophy_gold", collectionCategory: "trophies".localized, isRare: true),
        Item.collectible(name: "scroll_of_ancient_wisdom".localized, description: "scroll_of_ancient_wisdom_description".localized, iconName: "icon_scroll_1", collectionCategory: "scrolls".localized),
        Item.collectible(name: "scroll_of_lost_secrets".localized, description: "scroll_of_lost_secrets_description".localized, iconName: "icon_scroll_2", collectionCategory: "scrolls".localized, isRare: true),
        Item.collectible(name: "scroll_of_forbidden_knowledge".localized, description: "scroll_of_forbidden_knowledge_description".localized, iconName: "icon_scroll_3", collectionCategory: "scrolls".localized, isRare: true),
        Item.collectible(name: "bell_of_awakening".localized, description: "bell_of_awakening_description".localized, iconName: "icon_bell", collectionCategory: "general".localized),
        Item.collectible(name: "chronometer".localized, description: "chronometer_description".localized, iconName: "icon_calendar", collectionCategory: "general".localized),
        Item.collectible(name: "lucky_four_leaf_clover".localized, description: "lucky_four_leaf_clover_description".localized, iconName: "icon_clover", collectionCategory: "general".localized, isRare: true),
        Item.collectible(name: "holy_cross".localized, description: "holy_cross_description".localized, iconName: "icon_cross", collectionCategory: "general".localized),
        Item.collectible(name: "phoenix_feather".localized, description: "phoenix_feather_description".localized, iconName: "icon_feather", collectionCategory: "general".localized),
        Item.collectible(name: "essence_of_fire".localized, description: "essence_of_fire_description".localized, iconName: "icon_fire", collectionCategory: "elements".localized),
        Item.collectible(name: "lightning_bolt".localized, description: "lightning_bolt_description".localized, iconName: "icon_lightning", collectionCategory: "elements".localized),
        Item.collectible(name: "strength_totem".localized, description: "strength_totem_description".localized, iconName: "icon_muscle", collectionCategory: "general".localized),
        Item.collectible(name: "starlight_fragment".localized, description: "starlight_fragment_description".localized, iconName: "icon_star_fill", collectionCategory: "general".localized),
        Item.collectible(name: "skull_of_the_fallen".localized, description: "skull_of_the_fallen_description".localized, iconName: "icon_skull", collectionCategory: "general".localized),
        Item.collectible(name: "skull_of_the_ancient".localized, description: "skull_of_the_ancient_description".localized, iconName: "icon_skull_side", collectionCategory: "general".localized)
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
