//
//  Item.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import Foundation
import SwiftUI

enum ItemRarity: String, CaseIterable {
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
}

// MARK: - Item Types

enum ItemType: String, CaseIterable {
    case collectible = "Collectible"
    case functional = "Functional"

    var description: String {
        switch self {
        case .collectible:
            return "Visual items for display and collection"
        case .functional:
            return "Items with gameplay effects"
        }
    }
}

enum FunctionalItemType: String, CaseIterable {
    case consumable = "Consumable"
    case equipable = "Equipable"

    var description: String {
        switch self {
        case .consumable:
            return "Used once and consumed"
        case .equipable:
            return "Persistent until changed"
        }
    }
}

// MARK: - Base Item Protocol

protocol GameItem: Identifiable, Equatable {
    var id: UUID { get }
    var name: String { get }
    var description: String { get }
    var iconName: String { get }
    var rarity: ItemRarity { get }
    var itemType: ItemType { get }
    var value: Int { get }
}

// MARK: - Collectible Items

struct CollectibleItem: GameItem {
    let id: UUID
    let name: String
    let description: String
    let iconName: String
    let rarity: ItemRarity
    let itemType: ItemType = .collectible
    let value: Int
    let collectionCategory: String
    let isRare: Bool

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        iconName: String,
        rarity: ItemRarity = .common,
        value: Int = 0,
        collectionCategory: String = "General",
        isRare: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.iconName = iconName
        self.rarity = rarity
        self.value = value
        self.collectionCategory = collectionCategory
        self.isRare = isRare
    }
}

// MARK: - Functional Items

struct FunctionalItem: GameItem {
    let id: UUID
    let name: String
    let description: String
    let iconName: String
    let rarity: ItemRarity
    let itemType: ItemType = .functional
    let value: Int
    let functionalType: FunctionalItemType
    let effects: [ItemEffect]
    let duration: TimeInterval? // For temporary effects
    let cooldown: TimeInterval? // For reusable items

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        iconName: String,
        rarity: ItemRarity = .common,
        value: Int = 0,
        functionalType: FunctionalItemType,
        effects: [ItemEffect] = [],
        duration: TimeInterval? = nil,
        cooldown: TimeInterval? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.iconName = iconName
        self.rarity = rarity
        self.value = value
        self.functionalType = functionalType
        self.effects = effects
        self.duration = duration
        self.cooldown = cooldown
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
            case .coinBoost: return "dollarsign.circle.fill"
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
}

// MARK: - XP Boost Items

struct XPBoostItem: GameItem {
    let id: UUID
    let name: String
    let description: String
    let iconName: String
    let rarity: ItemRarity
    let itemType: ItemType = .functional
    let value: Int
    let boostMultiplier: Double
    let boostDuration: TimeInterval

    var functionalType: FunctionalItemType { .consumable }
    var effects: [ItemEffect] {
        [
            ItemEffect(
                type: .xpBoost,
                value: Int(boostMultiplier * 100),
                duration: boostDuration,
                isPercentage: true
            )
        ]
    }
    var duration: TimeInterval? { boostDuration }
    var cooldown: TimeInterval? { nil }

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        iconName: String,
        rarity: ItemRarity = .common,
        value: Int = 0,
        boostMultiplier: Double,
        boostDuration: TimeInterval
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.iconName = iconName
        self.rarity = rarity
        self.value = value
        self.boostMultiplier = boostMultiplier
        self.boostDuration = boostDuration
    }

    // Predefined XP Boost items
    static let minorXPBoost = XPBoostItem(
        name: "Minor XP Boost",
        description: "Increases XP gain by 25% for 30 minutes",
        iconName: "icon_xp_boost_minor",
        rarity: .common,
        value: 50,
        boostMultiplier: 1.25,
        boostDuration: 30 * 60 // 30 minutes
    )

    static let xpBoost = XPBoostItem(
        name: "XP Boost",
        description: "Increases XP gain by 50% for 1 hour",
        iconName: "icon_xp_boost",
        rarity: .uncommon,
        value: 100,
        boostMultiplier: 1.5,
        boostDuration: 60 * 60 // 1 hour
    )

    static let greaterXPBoost = XPBoostItem(
        name: "Greater XP Boost",
        description: "Increases XP gain by 100% for 2 hours",
        iconName: "icon_xp_boost_greater",
        rarity: .rare,
        value: 250,
        boostMultiplier: 2.0,
        boostDuration: 2 * 60 * 60 // 2 hours
    )

    static let legendaryXPBoost = XPBoostItem(
        name: "Legendary XP Boost",
        description: "Increases XP gain by 200% for 4 hours",
        iconName: "icon_xp_boost_legendary",
        rarity: .legendary,
        value: 500,
        boostMultiplier: 3.0,
        boostDuration: 4 * 60 * 60 // 4 hours
    )

    static let allXPBoosts: [XPBoostItem] = [
        minorXPBoost,
        xpBoost,
        greaterXPBoost,
        legendaryXPBoost
    ]
}

// MARK: - Legacy BattleItem (keeping for compatibility)

struct BattleItem: Identifiable, Equatable {
    let id: UUID
    let name: String
    let description: String
    let iconName: String
    let rarity: ItemRarity
    let value: Int?
    let effects: [ItemEffect]?

    init(id: UUID = UUID(), name: String, description: String, iconName: String, rarity: ItemRarity = .common, value: Int? = nil, effects: [ItemEffect]? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.iconName = iconName
        self.rarity = rarity
        self.value = value
        self.effects = effects
    }
}
