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
    let category: EnhancedShopCategory
    let effects: [ItemEffect]?

    init(id: UUID = UUID(), name: String, description: String, iconName: String, price: Int, rarity: ItemRarity = .common, category: EnhancedShopCategory, effects: [ItemEffect]? = nil) {
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
