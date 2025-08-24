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
    let iconName: String // The actual image name for inventory storage
    let previewImage: String // The preview image for shop display
    let price: Int
    let gemPrice: Int? // Price in gems for epic/legendary items
    let rarity: ItemRarity
    let category: EnhancedShopCategory
    let assetCategory: AssetCategory? // The specific asset category for gear items
    let effects: [ItemEffect]?
    let isOwned: Bool

    init(id: UUID = UUID(), name: String, description: String, iconName: String, previewImage: String? = nil, price: Int, gemPrice: Int? = nil, rarity: ItemRarity = .common, category: EnhancedShopCategory, assetCategory: AssetCategory? = nil, effects: [ItemEffect]? = nil, isOwned: Bool = false) {
        self.id = id
        self.name = name
        self.description = description
        self.iconName = iconName
        self.previewImage = previewImage ?? iconName // Use iconName as fallback
        self.price = price
        self.gemPrice = gemPrice
        self.rarity = rarity
        self.category = category
        self.assetCategory = assetCategory
        self.effects = effects
        self.isOwned = isOwned
    }
}
