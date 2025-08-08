//
//  Item.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import Foundation

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
}

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

struct ItemEffect: Equatable {
    let type: EffectType
    let value: Int
    let duration: TimeInterval?

    enum EffectType: Equatable {
        case attack
        case defense
        case health
        case focus
        case experience
    }
}
