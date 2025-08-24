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
    case weapon = "Weapon"
    case shield = "Shield"
    case wings = "Wings"
    case pet = "Pet"

    var description: String {
        switch self {
        case .head:
            return "Headgear and helmets"
        case .outfit:
            return "Body armor and clothing"
        case .weapon:
            return "Weapons and tools"
        case .shield:
            return "Shields and defensive gear"
        case .wings:
            return "Wing accessories"
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
        name: "Lesser Healing Elixir",
        description: "Restores 15 HP. A basic healing potion made from common herbs.",
        healAmount: 15,
        value: 25
    )

    static let healthPotion = Item.healthPotion(
        name: "Vitality Draught",
        description: "Restores 30 HP. A reliable healing potion for adventurers.",
        healAmount: 30,
        value: 50
    )

    static let greaterHealthPotion = Item.healthPotion(
        name: "Greater Restoration Tonic",
        description: "Restores 50 HP. A powerful healing potion that can save your life.",
        healAmount: 50,
        value: 100
    )

    static let superiorHealthPotion = Item.healthPotion(
        name: "Supreme Life Essence",
        description: "Restores 75 HP. An exceptional healing potion with rare ingredients.",
        healAmount: 75,
        value: 200
    )

    static let legendaryHealthPotion = Item.healthPotion(
        name: "Phoenix Tears",
        description: "Fully restores health. A legendary potion that brings you back from the brink of death.",
        healAmount: 999,
        value: 500
    )

    // MARK: - XP Boosts (Boosters)
    static let minorXPBoost = Item.xpBoost(
        name: "Wisdom's Breath",
        description: "Increases XP gain by 25% for 30 minutes",
        multiplier: 1.25,
        duration: 30 * 60,
        value: 50
    )

    static let xpBoost = Item.xpBoost(
        name: "Scholar's Insight",
        description: "Increases XP gain by 50% for 1 hour",
        multiplier: 1.5,
        duration: 60 * 60,
        value: 100
    )

    static let greaterXPBoost = Item.xpBoost(
        name: "Master's Enlightenment",
        description: "Increases XP gain by 100% for 2 hours",
        multiplier: 2.0,
        duration: 2 * 60 * 60,
        value: 250
    )

    static let legendaryXPBoost = Item.xpBoost(
        name: "Ancient Knowledge Essence",
        description: "Increases XP gain by 200% for 4 hours",
        multiplier: 3.0,
        duration: 4 * 60 * 60,
        value: 500
    )

    // MARK: - Coin Boosts (Boosters)
    static let minorCoinBoost = Item.coinBoost(
        name: "Merchant's Blessing",
        description: "Increases coin gain by 25% for 30 minutes",
        multiplier: 1.25,
        duration: 30 * 60,
        value: 50
    )

    static let coinBoost = Item.coinBoost(
        name: "Wealth Attractor",
        description: "Increases coin gain by 50% for 1 hour",
        multiplier: 1.5,
        duration: 60 * 60,
        value: 100
    )

    static let greaterCoinBoost = Item.coinBoost(
        name: "Golden Fortune",
        description: "Increases coin gain by 100% for 2 hours",
        multiplier: 2.0,
        duration: 2 * 60 * 60,
        value: 250
    )

    static let legendaryCoinBoost = Item.coinBoost(
        name: "Dragon's Hoard Essence",
        description: "Increases coin gain by 200% for 4 hours",
        multiplier: 3.0,
        duration: 4 * 60 * 60,
        value: 500
    )

    // MARK: - Accessories
    static let allAccessories: [Item] = [
        // Clips (Flowers)
        Item.accessory(name: "Azure Bloom", description: "A beautiful blue flower that seems to capture the essence of a clear summer sky. Its petals shimmer with an inner light that brings peace to those who wear it.", iconName: "char_flower_blue", category: .clips),
        Item.accessory(name: "Emerald Petal", description: "A lovely green flower with leaves that sparkle like morning dew. It radiates natural energy and seems to enhance the wearer's connection to nature.", iconName: "char_flower_green", category: .clips),
        Item.accessory(name: "Amethyst Blossom", description: "An elegant purple flower with petals that seem to glow with mystical energy. Wearing it grants a sense of wisdom and inner strength.", iconName: "char_flower_purple", category: .clips),
        
        // Eyeglasses
        Item.accessory(name: "Sapphire Spectacles", description: "Stylish blue glasses with lenses that seem to enhance vision beyond normal human capabilities. The frames are crafted from precious metals and set with tiny sapphire gems.", iconName: "char_glass_blue", category: .eyeglasses),
        Item.accessory(name: "Shadow Lenses", description: "Classic gray glasses that seem to absorb light rather than reflect it. They grant the wearer an air of mystery and help them blend into shadows.", iconName: "char_glass_gray", category: .eyeglasses),
        Item.accessory(name: "Ruby Frames", description: "Bold red glasses that burn with inner fire. The lenses seem to glow with heat, and wearing them grants an intimidating presence.", iconName: "char_glass_red", category: .eyeglasses),
        
        // Earrings
        Item.accessory(name: "Moonstone Stud", description: "A simple earring crafted from pure moonstone. It catches the light like moonlight on water and seems to pulse with gentle energy.", iconName: "char_earring_1", category: .earrings),
        Item.accessory(name: "Starlight Hoop", description: "An elegant earring that sparkles like starlight. The metal seems to contain tiny stars that twinkle and dance in the light.", iconName: "char_earring_2", category: .earrings),
        
        // Lashes
        Item.accessory(name: "Rose Blush", description: "A touch of blush that gives the wearer a natural, healthy glow. The color seems to enhance beauty and confidence, making the wearer radiate charm.", iconName: "char_blush", category: .lashes)
    ]

    // MARK: - Gear Items
    static let allGear: [Item] = [
        // Head Gear
        Item.gear(name: "Shadow Veil", description: "A mysterious hood woven from shadow essence. Conceals your identity while offering basic protection from the elements.", iconName: "char_helmet_hood", category: .head, rarity: .common),
        Item.gear(name: "Ironclad Crown", description: "Forged from the finest iron, this crown provides excellent protection while maintaining a regal appearance. Worn by many aspiring knights.", iconName: "char_helmet_iron", category: .head, rarity: .uncommon),
        Item.gear(name: "Crimson Crest", description: "A striking helmet adorned with crimson gems. The metal seems to pulse with inner fire, granting its wearer an intimidating presence.", iconName: "char_helmet_red", category: .head, rarity: .rare),

        // Outfits
        Item.gear(name: "Peasant's Garb", description: "Simple but durable clothing worn by villagers. Though humble in appearance, it has served countless adventurers on their first steps into the unknown.", iconName: "char_outfit_villager", category: .outfit, rarity: .common),
        Item.gear(name: "Azure Tunic", description: "A beautiful blue tunic that catches the light like morning dew. The fabric is surprisingly resilient, offering both style and protection.", iconName: "char_outfit_villager_blue", category: .outfit, rarity: .common),
        Item.gear(name: "Comfort Cloak", description: "A warm, comfortable hoodie that feels like a gentle embrace. Perfect for those long nights of study or quiet contemplation.", iconName: "char_outfit_hoodie", category: .outfit, rarity: .uncommon),
        Item.gear(name: "Silken Grace", description: "An elegant dress woven from the finest silk. The fabric flows like water, and the intricate embroidery tells stories of ancient courts.", iconName: "char_outfit_dress", category: .outfit, rarity: .uncommon),
        Item.gear(name: "Ironclad Plate", description: "Heavy iron armor that clanks with authority. Each plate has been carefully crafted and fitted, offering superior protection against physical attacks.", iconName: "char_outfit_iron", category: .outfit, rarity: .rare),
        Item.gear(name: "Reinforced Ironclad", description: "Enhanced iron armor with additional reinforcements. The metal has been treated with ancient techniques, making it nearly impervious to common weapons.", iconName: "char_outfit_iron_2", category: .outfit, rarity: .rare),
        Item.gear(name: "Crimson Raiment", description: "Bold red armor that burns with inner fire. The metal seems alive, pulsing with heat that intimidates enemies and inspires allies.", iconName: "char_outfit_red", category: .outfit, rarity: .epic),
        Item.gear(name: "Arcane Robes", description: "Mystical robes that shimmer with magical energy. Woven with enchanted threads, they enhance magical abilities and protect against arcane attacks.", iconName: "char_outfit_wizard", category: .outfit, rarity: .epic),
        Item.gear(name: "Nightwing Shroud", description: "A mysterious outfit that seems to absorb light itself. Worn by those who walk in shadows, it grants the wearer an otherworldly presence.", iconName: "char_outfit_bat", category: .outfit, rarity: .legendary),
        Item.gear(name: "Inferno Mantle", description: "A blazing outfit that radiates pure fire energy. The flames dance around the wearer, creating an aura of destruction and power.", iconName: "char_outfit_fire", category: .outfit, rarity: .legendary),

        // Wings
        Item.gear(name: "Celestial Wings", description: "Pure white wings that glow with divine light. They seem to be made of pure energy, allowing the bearer to soar through the heavens with grace.", iconName: "char_wings_white", category: .wings, rarity: .rare),
        Item.gear(name: "Phoenix Wings", description: "Fiery wings that burn with eternal flame. Each feather crackles with heat, and the wings seem to regenerate even from the ashes of destruction.", iconName: "char_wings_red", category: .wings, rarity: .epic),
        Item.gear(name: "Blazing Phoenix", description: "Enhanced phoenix wings that blaze with intensified fire. The heat is so intense that enemies nearby feel the scorching power of rebirth.", iconName: "char_wings_red_2", category: .wings, rarity: .epic),
        Item.gear(name: "Shadow Wings", description: "Dark wings that seem to absorb all light around them. They allow silent flight through the night, perfect for those who prefer to remain unseen.", iconName: "char_wings_bat", category: .wings, rarity: .legendary),
        
        // Weapons
        Item.gear(name: "Oakheart Blade", description: "A sword carved from ancient oak, its blade hardened through years of seasoning. Though simple, it has a natural balance that makes it surprisingly effective in skilled hands.", iconName: "char_sword_wood", category: .weapon, rarity: .common),
        Item.gear(name: "Copper Fang", description: "A copper sword with a distinctive reddish hue. The metal has been carefully forged to create a sharp edge that gleams in the sunlight.", iconName: "char_sword_copper", category: .weapon, rarity: .common),
        Item.gear(name: "Ironclad Edge", description: "A reliable iron sword that has been the weapon of choice for countless warriors. Its balance and durability make it a trusted companion in battle.", iconName: "char_sword_iron", category: .weapon, rarity: .uncommon),
        Item.gear(name: "Steel Serpent", description: "A sharp steel sword that moves like a striking snake. The blade is so finely crafted that it can cut through lesser armor with ease.", iconName: "char_sword_steel", category: .weapon, rarity: .rare),
        Item.gear(name: "Crimson Fang", description: "A fiery red sword that burns with inner heat. The blade seems to thirst for battle, growing hotter with each strike against enemies.", iconName: "char_sword_red", category: .weapon, rarity: .epic),
        Item.gear(name: "Blazing Fang", description: "An enhanced version of the Crimson Fang, this sword burns with such intensity that it can ignite enemies with a single strike.", iconName: "char_sword_red_2", category: .weapon, rarity: .epic),
        Item.gear(name: "Golden Dawn", description: "A legendary golden sword that seems to capture the first light of dawn. Its blade radiates warmth and hope, inspiring allies while striking fear into enemies.", iconName: "char_sword_gold", category: .weapon, rarity: .legendary),
        Item.gear(name: "Thunder Axe", description: "A heavy axe that crackles with electrical energy. Each swing creates a thunderous boom, and the blade can channel lightning through its strikes.", iconName: "char_sword_axe", category: .weapon, rarity: .rare),
        Item.gear(name: "Storm Hatchet", description: "A smaller axe that hums with storm energy. Though lighter than its larger cousin, it can still channel the power of thunder and lightning.", iconName: "char_sword_axe_small", category: .weapon, rarity: .uncommon),
        Item.gear(name: "Viper's Lash", description: "A flexible whip that strikes like a venomous snake. The leather has been treated with special oils, making it both deadly and silent.", iconName: "char_sword_whip", category: .weapon, rarity: .epic),
        Item.gear(name: "Arcane Staff", description: "A magical staff that pulses with arcane energy. Carved from ancient wood and set with mystical crystals, it enhances magical abilities and channels powerful spells.", iconName: "char_sword_staff", category: .weapon, rarity: .epic),
        Item.gear(name: "Iron Maiden", description: "A heavy mace that strikes with devastating force. The spiked head can crush armor and bone alike, making it feared by all who face it.", iconName: "char_sword_mace", category: .weapon, rarity: .rare),
        Item.gear(name: "Soul Reaper", description: "A deadly weapon that seems to drain the life from its victims. The blade is dark as night and cold as death, feared by all who know its name.", iconName: "char_sword_deadly", category: .weapon, rarity: .legendary),
        Item.gear(name: "Windseeker Bow", description: "A bow that seems to be guided by the wind itself. Arrows fired from this bow fly with uncanny accuracy, finding their targets even in the strongest gales.", iconName: "char_weapon_bow_front", category: .weapon, rarity: .rare),
        Item.gear(name: "Stormcaller Bow", description: "A bow that can summon storms with its arrows. Each shot crackles with lightning, and the bow itself hums with the power of thunder.", iconName: "char_weapon_bow_back", category: .weapon, rarity: .rare),
        
        // Shields
        Item.gear(name: "Oakheart Ward", description: "A shield carved from ancient oak, its surface weathered but strong. The wood has absorbed countless blows, making it a reliable defense for any warrior.", iconName: "char_shield_wood", category: .shield, rarity: .common),
        Item.gear(name: "Crimson Ward", description: "A red shield that burns with defensive fire. The metal seems to absorb attacks and reflect them back as heat, making enemies think twice before striking.", iconName: "char_shield_red", category: .shield, rarity: .uncommon),
        Item.gear(name: "Ironclad Bulwark", description: "A sturdy iron shield that has withstood the test of time. Its surface is covered in battle scars, each one a testament to its protective power.", iconName: "char_shield_iron", category: .shield, rarity: .rare),
        Item.gear(name: "Golden Aegis", description: "A golden shield that radiates divine protection. The metal gleams with holy light, and enemies find their attacks weakened when facing its brilliance.", iconName: "char_shield_gold", category: .shield, rarity: .epic),
        
        // Pets
        Item.gear(name: "Shadowpaw", description: "A mysterious cat companion with fur as dark as midnight. It moves silently and seems to understand your thoughts, making it the perfect companion for stealth missions.", iconName: "char_pet_cat", category: .pet, rarity: .rare),
        Item.gear(name: "Whiskerwind", description: "A graceful cat with fur that shimmers like starlight. It has an uncanny ability to sense danger and will warn you of approaching threats.", iconName: "char_pet_cat_2", category: .pet, rarity: .rare),
        Item.gear(name: "Golden Cluck", description: "A loyal chicken companion with golden feathers that gleam in the sunlight. Despite its humble appearance, it has a heart of gold and will follow you anywhere.", iconName: "char_pet_chicken", category: .pet, rarity: .epic)
    ]

    // MARK: - Collectible Items
    static let allCollectibles: [Item] = [
        Item.collectible(name: "Crown of Kings", description: "A magnificent crown that has adorned the heads of countless rulers throughout history. Its jewels seem to hold the wisdom of ages past, and wearing it grants an aura of authority.", iconName: "icon_crown", collectionCategory: "Royalty", isRare: true),
        Item.collectible(name: "Mystic Egg", description: "A mysterious egg that pulses with unknown energy. Ancient legends speak of creatures that hatch from such eggs, but none have ever witnessed the transformation.", iconName: "icon_egg", collectionCategory: "General"),
        Item.collectible(name: "Thunder Hammer", description: "A mighty hammer that crackles with electrical energy. Each strike creates a thunderous boom, and the weapon seems to channel the power of storms themselves.", iconName: "icon_hammer", collectionCategory: "Weapons"),
        Item.collectible(name: "Golden Key of Ages", description: "A golden key that seems to unlock more than just physical doors. Ancient inscriptions suggest it can open portals to forgotten realms and hidden knowledge.", iconName: "icon_key_gold", collectionCategory: "Treasure", isRare: true),
        Item.collectible(name: "Silver Key of Secrets", description: "A silver key that whispers secrets to those who hold it. The metal seems to remember every lock it has ever opened, and every secret it has ever revealed.", iconName: "icon_key_silver", collectionCategory: "Treasure", isRare: true),
        Item.collectible(name: "Medal of Honor", description: "A prestigious medal awarded for acts of great courage and valor. The metal gleams with the light of honor, and wearing it inspires respect from all who see it.", iconName: "icon_medal", collectionCategory: "Royalty", isRare: true),
        Item.collectible(name: "Harvest Pumpkin", description: "A festive pumpkin that seems to glow with inner light. Carved with care and decorated with mystical symbols, it brings joy and celebration wherever it appears.", iconName: "icon_pumpkin", collectionCategory: "General"),
        Item.collectible(name: "Ring of Power", description: "A magical ring that pulses with arcane energy. Ancient runes are etched into its surface, and wearing it grants access to forgotten magical abilities.", iconName: "icon_ring", collectionCategory: "Accessories", isRare: true),
        Item.collectible(name: "Treasure Chest", description: "A sturdy treasure chest that has held countless fortunes throughout the ages. Its wood is weathered but strong, and the lock mechanism is a marvel of ancient engineering.", iconName: "icon_chest", collectionCategory: "Treasure"),
        Item.collectible(name: "Azure Treasure Chest", description: "A rare blue treasure chest that seems to glow with inner light. The metal is unlike any known alloy, and the chest itself seems to hum with magical energy.", iconName: "icon_chest_blue", collectionCategory: "Treasure", isRare: true),
        Item.collectible(name: "Opened Treasure Chest", description: "An opened treasure chest that has already revealed its secrets. Though empty now, it still holds the promise of adventure and discovery.", iconName: "icon_chest_open", collectionCategory: "Treasure"),
        Item.collectible(name: "Bronze Trophy of Valor", description: "A bronze trophy awarded for acts of bravery and courage. The metal has been polished to a shine, and the craftsmanship speaks of great skill and dedication.", iconName: "icon_trophy_bronze", collectionCategory: "Trophies"),
        Item.collectible(name: "Silver Trophy of Glory", description: "A silver trophy that gleams with the light of achievement. The metal seems to capture and reflect the glory of past victories, inspiring future triumphs.", iconName: "icon_trophy_silver", collectionCategory: "Trophies", isRare: true),
        Item.collectible(name: "Golden Trophy of Legends", description: "A golden trophy that radiates with the power of legend. The metal seems to hold the essence of greatness itself, and those who possess it are destined for fame.", iconName: "icon_trophy_gold", collectionCategory: "Trophies", isRare: true),
        Item.collectible(name: "Scroll of Ancient Wisdom", description: "An ancient scroll covered in mystical runes and forgotten knowledge. The parchment seems to whisper secrets to those who study it carefully.", iconName: "icon_scroll_1", collectionCategory: "Scrolls"),
        Item.collectible(name: "Scroll of Lost Secrets", description: "A scroll that contains secrets so powerful they were hidden away for centuries. The ink seems to glow with forbidden knowledge, and reading it grants insights into forgotten magic.", iconName: "icon_scroll_2", collectionCategory: "Scrolls", isRare: true),
        Item.collectible(name: "Scroll of Forbidden Knowledge", description: "A scroll that pulses with dangerous energy. The knowledge contained within is so powerful that it was sealed away by ancient sages to protect the world.", iconName: "icon_scroll_3", collectionCategory: "Scrolls", isRare: true),
        Item.collectible(name: "Bell of Awakening", description: "A magical bell that rings with a sound that seems to awaken the soul. The metal resonates with pure energy, and its chime can break enchantments and dispel illusions.", iconName: "icon_bell", collectionCategory: "General"),
        Item.collectible(name: "Chronometer", description: "A mystical timepiece that seems to track more than just hours and minutes. The gears move with impossible precision, and the device can measure the flow of time itself.", iconName: "icon_calendar", collectionCategory: "General"),
        Item.collectible(name: "Lucky Four-Leaf Clover", description: "A rare four-leaf clover that seems to radiate good fortune. The leaves shimmer with an inner light, and carrying it brings luck and protection to its owner.", iconName: "icon_clover", collectionCategory: "General", isRare: true),
        Item.collectible(name: "Holy Cross", description: "A sacred cross that glows with divine light. The metal seems to be blessed, and it offers protection against dark forces and evil magic.", iconName: "icon_cross", collectionCategory: "General"),
        Item.collectible(name: "Phoenix Feather", description: "A feather that burns with eternal flame. Though it should be consumed by fire, it remains intact and radiates warmth and renewal.", iconName: "icon_feather", collectionCategory: "General"),
        Item.collectible(name: "Essence of Fire", description: "A crystal that contains pure fire energy. The flames dance within the gem, and it radiates heat that can warm even the coldest heart.", iconName: "icon_fire", collectionCategory: "Elements"),
        Item.collectible(name: "Lightning Bolt", description: "A bolt of lightning captured in crystal form. The energy crackles within, and the crystal hums with the power of storms.", iconName: "icon_lightning", collectionCategory: "Elements"),
        Item.collectible(name: "Strength Totem", description: "A totem that radiates with the power of physical might. Carved with symbols of strength, it enhances the bearer's physical abilities and grants courage in battle.", iconName: "icon_muscle", collectionCategory: "General"),
        Item.collectible(name: "Starlight Fragment", description: "A fragment of starlight captured in crystal form. It glows with the light of distant stars, and holding it brings clarity and inspiration.", iconName: "icon_star_fill", collectionCategory: "General"),
        Item.collectible(name: "Skull of the Fallen", description: "A mysterious skull that seems to hold the memories of its former owner. Though unsettling, it can reveal secrets about the past and warn of future dangers.", iconName: "icon_skull", collectionCategory: "General"),
        Item.collectible(name: "Skull of the Ancient", description: "A skull so old that it has become fossilized. Ancient wisdom seems to emanate from it, and those who study it can learn forgotten knowledge.", iconName: "icon_skull_side", collectionCategory: "General")
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
        return ItemDatabase.allItems.first { $0.iconName == iconName }
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
