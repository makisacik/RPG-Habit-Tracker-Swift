//
//  ShopItem.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 17.11.2024.
//

import Foundation

struct ShopItem: Identifiable, Equatable {
    let id: UUID
    let name: String
    let description: String
    let iconName: String
    let price: Int
    let rarity: ItemRarity
    let category: ShopCategory
    let effects: [ItemEffect]?

    init(id: UUID = UUID(), name: String, description: String, iconName: String, price: Int, rarity: ItemRarity = .common, category: ShopCategory, effects: [ItemEffect]? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.iconName = iconName
        self.price = price
        self.rarity = rarity
        self.category = category
        self.effects = effects
    }
}

enum ShopCategory: String, CaseIterable {
    case weapons = "Weapons"
    case armor = "Armor"
    case potions = "Potions"
    case boosts = "Boosts"
    case accessories = "Accessories"
    case special = "Special"

    var icon: String {
        switch self {
        case .weapons: return "sword.fill"
        case .armor: return "shield.fill"
        case .potions: return "drop.fill"
        case .boosts: return "bolt.fill"
        case .accessories: return "crown.fill"
        case .special: return "star.fill"
        }
    }
}
