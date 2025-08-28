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
        return self.rawValue.localized
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
        return self.rawValue.localized
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
        return self.rawValue.localized
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
        return self.rawValue.localized
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
        return name.localized
    }

    /// Gets the localized description for this item
    var localizedDescription: String {
        return description.localized
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
            previewImage: "icon_flask_red", // Use iconName since preview image doesn't exist
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
            previewImage: "icon_lightning", // Use iconName since preview image doesn't exist
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
            previewImage: "icon_flask_purple", // Use iconName since preview image doesn't exist
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
    static var minorHealthPotion: Item {
        return Item.healthPotion(
            name: "lesser_healing_elixir",
            description: "lesser_healing_elixir_description",
            healAmount: 15,
            value: 25
        )
    }

    static var healthPotion: Item {
        return Item.healthPotion(
            name: "vitality_draught",
            description: "vitality_draught_description",
            healAmount: 30,
            value: 50
        )
    }

    static var greaterHealthPotion: Item {
        return Item.healthPotion(
            name: "greater_restoration_tonic",
            description: "greater_restoration_tonic_description",
            healAmount: 50,
            value: 100
        )
    }

    static var superiorHealthPotion: Item {
        return Item.healthPotion(
            name: "supreme_life_essence",
            description: "supreme_life_essence_description",
            healAmount: 75,
            value: 200
        )
    }

    static var legendaryHealthPotion: Item {
        return Item.healthPotion(
            name: "phoenix_tears",
            description: "phoenix_tears_description",
            healAmount: 999,
            value: 500
        )
    }

    // MARK: - XP Boosts (Boosters)
    static var minorXPBoost: Item {
        return Item.xpBoost(
            name: "wisdoms_breath",
            description: "wisdoms_breath_description",
            multiplier: 1.25,
            duration: 12 * 60 * 60, // 12 hours
            value: 200
        )
    }

    static var xpBoost: Item {
        return Item.xpBoost(
            name: "scholars_insight",
            description: "scholars_insight_description",
            multiplier: 1.5,
            duration: 24 * 60 * 60, // 24 hours (1 day)
            value: 400
        )
    }

    static var greaterXPBoost: Item {
        return Item.xpBoost(
            name: "masters_enlightenment",
            description: "masters_enlightenment_description",
            multiplier: 2.0,
            duration: 3 * 24 * 60 * 60, // 3 days
            value: 800
        )
    }

    static var legendaryXPBoost: Item {
        return Item.xpBoost(
            name: "ancient_knowledge_essence",
            description: "ancient_knowledge_essence_description",
            multiplier: 3.0,
            duration: 7 * 24 * 60 * 60, // 7 days
            value: 1500
        )
    }

    // MARK: - Coin Boosts (Boosters)
    static var minorCoinBoost: Item {
        return Item.coinBoost(
            name: "merchants_blessing",
            description: "merchants_blessing_description",
            multiplier: 1.25,
            duration: 12 * 60 * 60, // 12 hours
            value: 200
        )
    }

    static var coinBoost: Item {
        return Item.coinBoost(
            name: "wealth_attractor",
            description: "wealth_attractor_description",
            multiplier: 1.5,
            duration: 24 * 60 * 60, // 24 hours (1 day)
            value: 400
        )
    }

    static var greaterCoinBoost: Item {
        return Item.coinBoost(
            name: "golden_fortune",
            description: "golden_fortune_description",
            multiplier: 2.0,
            duration: 3 * 24 * 60 * 60, // 3 days
            value: 800
        )
    }

    static var legendaryCoinBoost: Item {
        return Item.coinBoost(
            name: "dragons_hoard_essence",
            description: "dragons_hoard_essence_description",
            multiplier: 3.0,
            duration: 7 * 24 * 60 * 60, // 7 days
            value: 1500
        )
    }

    // MARK: - Accessories
    static var allAccessories: [Item] {
        return [
            // Flowers/Clips
            Item.accessory(name: "rose_petal", description: "rose_petal_description", iconName: "char_flower_red", category: .clips),
            Item.accessory(name: "emerald_petal", description: "emerald_petal_description", iconName: "char_flower_green", category: .clips),
            Item.accessory(name: "amethyst_blossom", description: "amethyst_blossom_description", iconName: "char_flower_purple", category: .clips),

            // Eyeglasses
            Item.accessory(name: "sapphire_spectacles", description: "sapphire_spectacles_description", iconName: "char_glass_blue", category: .eyeglasses),
            Item.accessory(name: "shadow_lenses", description: "shadow_lenses_description", iconName: "char_glass_gray", category: .eyeglasses),
            Item.accessory(name: "ruby_frames", description: "ruby_frames_description", iconName: "char_glass_red", category: .eyeglasses),

            // Earrings
            Item.accessory(name: "moonstone_stud", description: "moonstone_stud_description", iconName: "char_earring_1", category: .earrings),
            Item.accessory(name: "starlight_hoop", description: "starlight_hoop_description", iconName: "char_earring_2", category: .earrings),

            // Lashes
            Item.accessory(name: "rose_blush", description: "rose_blush_description", iconName: "char_blush", category: .lashes)
        ]
    }

    // MARK: - Gear Items
    static var allGear: [Item] {
        return [
            // Weapons
            Item.gear(name: "oakheart_blade", description: "oakheart_blade_description", iconName: "char_sword_wood", category: .weapon, rarity: .common, value: 100),
            Item.gear(name: "ironclad_edge", description: "ironclad_edge_description", iconName: "char_sword_iron", category: .weapon, rarity: .uncommon, value: 250),
            Item.gear(name: "steel_serpent", description: "steel_serpent_description", iconName: "char_sword_steel", category: .weapon, rarity: .rare, value: 500),
            Item.gear(name: "magical_sword", description: "magical_sword_description", iconName: "char_sword_magic", category: .weapon, rarity: .epic, value: 1000),
            Item.gear(name: "legendary_sword", description: "legendary_sword_description", iconName: "char_sword_legendary", category: .weapon, rarity: .legendary, value: 2000),
            Item.gear(name: "deadly_sword", description: "deadly_sword_description", iconName: "char_sword_deadly", category: .weapon, rarity: .rare, value: 600),
            Item.gear(name: "battle_axe", description: "battle_axe_description", iconName: "char_sword_axe", category: .weapon, rarity: .epic, value: 1200),
            Item.gear(name: "small_battle_axe", description: "small_battle_axe_description", iconName: "char_sword_axe_small", category: .weapon, rarity: .uncommon, value: 400),
            Item.gear(name: "whip_sword", description: "whip_sword_description", iconName: "char_sword_whip", category: .weapon, rarity: .epic, value: 1100),
            Item.gear(name: "golden_dawn", description: "golden_dawn_description", iconName: "char_sword_gold", category: .weapon, rarity: .rare, value: 1500),
            Item.gear(name: "copper_fang", description: "copper_fang_description", iconName: "char_sword_copper", category: .weapon, rarity: .uncommon, value: 300),
            Item.gear(name: "crimson_fang", description: "crimson_fang_description", iconName: "char_sword_red", category: .weapon, rarity: .epic, value: 700),
            Item.gear(name: "blazing_fang", description: "blazing_fang_description", iconName: "char_sword_red_2", category: .weapon, rarity: .legendary, value: 1300),
            Item.gear(name: "iron_maiden", description: "iron_maiden_description", iconName: "char_sword_mace", category: .weapon, rarity: .epic, value: 800),
            Item.gear(name: "arcane_staff", description: "arcane_staff_description", iconName: "char_sword_staff", category: .weapon, rarity: .legendary, value: 1400),

            // Outfits
            Item.gear(name: "peasants_garb", description: "peasants_garb_description", iconName: "char_outfit_villager", category: .outfit, rarity: .common, value: 100),
            Item.gear(name: "azure_tunic", description: "azure_tunic_description", iconName: "char_outfit_villager_blue", category: .outfit, rarity: .common, value: 150),
            Item.gear(name: "ironclad_plate", description: "ironclad_plate_description", iconName: "char_outfit_iron", category: .outfit, rarity: .uncommon, value: 300),
            Item.gear(name: "reinforced_ironclad", description: "reinforced_ironclad_description", iconName: "char_outfit_iron_2", category: .outfit, rarity: .rare, value: 600),
            Item.gear(name: "crimson_raiment", description: "crimson_raiment_description", iconName: "char_outfit_red", category: .outfit, rarity: .legendary, value: 1200),

            // Helmets
            Item.gear(name: "crimson_crest", description: "crimson_crest_description", iconName: "char_helmet_red", category: .head, rarity: .epic, value: 80),
            Item.gear(name: "ironclad_crown", description: "ironclad_crown_description", iconName: "char_helmet_iron", category: .head, rarity: .epic, value: 200),
            Item.gear(name: "crown_of_kings", description: "crown_of_kings_description", iconName: "char_helmet_hood", category: .head, rarity: .rare, value: 800),

            // Shields
            Item.gear(name: "oakheart_ward", description: "oakheart_ward_description", iconName: "char_shield_wood", category: .shield, rarity: .uncommon, value: 60),
            Item.gear(name: "ironclad_bulwark", description: "ironclad_bulwark_description", iconName: "char_shield_iron", category: .shield, rarity: .uncommon, value: 150),
            Item.gear(name: "crimson_ward", description: "crimson_ward_description", iconName: "char_shield_red", category: .shield, rarity: .rare, value: 300),
            Item.gear(name: "golden_aegis", description: "golden_aegis_description", iconName: "char_shield_gold", category: .shield, rarity: .epic, value: 600),

            // Wings
            Item.gear(name: "celestial_wings", description: "celestial_wings_description", iconName: "char_wings_white", category: .wings, rarity: .epic, value: 500),
            Item.gear(name: "shadow_wings", description: "shadow_wings_description", iconName: "char_wings_bat", category: .wings, rarity: .legendary, value: 200),
            Item.gear(name: "phoenix_wings", description: "phoenix_wings_description", iconName: "char_wings_red", category: .wings, rarity: .legendary, value: 200),
            Item.gear(name: "blazing_phoenix_wings", description: "blazing_phoenix_wings_description", iconName: "char_wings_red_2", category: .wings, rarity: .legendary, value: 200),

            // Pets
            Item.gear(name: "shadowpaw", description: "shadowpaw_description", iconName: "char_pet_cat", category: .pet, rarity: .epic, value: 300),
            Item.gear(name: "shadowpaw", description: "shadowpaw_description", iconName: "char_pet_cat_2", category: .pet, rarity: .epic, value: 500),
            Item.gear(name: "golden_cluck", description: "golden_cluck_description", iconName: "char_pet_chicken", category: .pet, rarity: .uncommon, value: 1500)
        ]
    }

    // MARK: - Collectibles
    static var allCollectibles: [Item] {
        return [
            Item.collectible(name: "ring_of_power", description: "ring_of_power_description", iconName: "icon_ring", collectionCategory: "accessories", isRare: true),
            Item.collectible(name: "treasure_chest", description: "treasure_chest_description", iconName: "icon_chest", collectionCategory: "treasure"),
            Item.collectible(name: "azure_treasure_chest", description: "azure_treasure_chest_description", iconName: "icon_chest_blue", collectionCategory: "treasure", isRare: true),
            Item.collectible(name: "opened_treasure_chest", description: "opened_treasure_chest_description", iconName: "icon_chest_open", collectionCategory: "treasure"),
            Item.collectible(name: "bronze_trophy_of_valor", description: "bronze_trophy_of_valor_description", iconName: "icon_trophy_bronze", collectionCategory: "trophies"),
            Item.collectible(name: "silver_trophy_of_glory", description: "silver_trophy_of_glory_description", iconName: "icon_trophy_silver", collectionCategory: "trophies", isRare: true),
            Item.collectible(name: "golden_trophy_of_legends", description: "golden_trophy_of_legends_description", iconName: "icon_trophy_gold", collectionCategory: "trophies", isRare: true),
            Item.collectible(name: "scroll_of_ancient_wisdom", description: "scroll_of_ancient_wisdom_description", iconName: "icon_scroll_1", collectionCategory: "scrolls"),
            Item.collectible(name: "scroll_of_lost_secrets", description: "scroll_of_lost_secrets_description", iconName: "icon_scroll_2", collectionCategory: "scrolls", isRare: true),
            Item.collectible(name: "scroll_of_forbidden_knowledge", description: "scroll_of_forbidden_knowledge_description", iconName: "icon_scroll_3", collectionCategory: "scrolls", isRare: true),
            Item.collectible(name: "bell_of_awakening", description: "bell_of_awakening_description", iconName: "icon_bell", collectionCategory: "general"),
            Item.collectible(name: "chronometer", description: "chronometer_description", iconName: "icon_calendar", collectionCategory: "general"),
            Item.collectible(name: "lucky_four_leaf_clover", description: "lucky_four_leaf_clover_description", iconName: "icon_clover", collectionCategory: "general", isRare: true),
            Item.collectible(name: "holy_cross", description: "holy_cross_description", iconName: "icon_cross", collectionCategory: "general"),
            Item.collectible(name: "phoenix_feather", description: "phoenix_feather_description", iconName: "icon_feather", collectionCategory: "general"),
            Item.collectible(name: "essence_of_fire", description: "essence_of_fire_description", iconName: "icon_fire", collectionCategory: "elements"),
            Item.collectible(name: "lightning_bolt", description: "lightning_bolt_description", iconName: "icon_lightning", collectionCategory: "elements"),
            Item.collectible(name: "strength_totem", description: "strength_totem_description", iconName: "icon_muscle", collectionCategory: "general"),
            Item.collectible(name: "starlight_fragment", description: "starlight_fragment_description", iconName: "icon_star_fill", collectionCategory: "general"),
            Item.collectible(name: "skull_of_the_fallen", description: "skull_of_the_fallen_description", iconName: "icon_skull", collectionCategory: "general"),
            Item.collectible(name: "skull_of_the_ancient", description: "skull_of_the_ancient_description", iconName: "icon_skull_side", collectionCategory: "general")
        ]
    }

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
        static func findItem(by name: String) -> Item? {
        return ItemDatabase.allItems.first { $0.name == name }
    }
    
    static func findItem(byIconName iconName: String) -> Item? {
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

    static func getRandomItem() -> Item {
        return ItemDatabase.allItems.randomElement() ?? ItemDatabase.healthPotion
    }

    static func getItems(of type: ItemType) -> [Item] {
        return ItemDatabase.allItems.filter { $0.itemType == type }
    }

    static func getItems(of rarity: ItemRarity) -> [Item] {
        return ItemDatabase.allItems.filter { $0.rarity == rarity }
    }

    static func getItems(of category: GearCategory) -> [Item] {
        return ItemDatabase.allItems.filter { $0.gearCategory == category }
    }

    static func getItems(of category: AccessoryCategory) -> [Item] {
        return ItemDatabase.allItems.filter { $0.accessoryCategory == category }
    }
}
