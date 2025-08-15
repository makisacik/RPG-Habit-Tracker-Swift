//
//  ShopManager.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 17.11.2024.
//

import Foundation
import SwiftUI

final class ShopManager: ObservableObject {
    static let shared = ShopManager()
    private let currencyManager = CurrencyManager.shared
    private let inventoryManager = InventoryManager.shared

    private init() {
    }

    // MARK: - Shop Items

    private let shopItems: [ShopItem] = [
        // Weapons
        ShopItem(name: "Iron Sword", description: "A reliable iron sword for basic combat", iconName: "icon_sword", price: 100, rarity: .common, category: .weapons),
        ShopItem(name: "Steel Axe", description: "A powerful steel axe for heavy damage", iconName: "icon_axe", price: 250, rarity: .uncommon, category: .weapons),
        ShopItem(name: "Magic Bow", description: "A bow imbued with magical properties", iconName: "icon_bow", price: 500, rarity: .rare, category: .weapons),
        ShopItem(name: "Dragon Slayer", description: "Legendary sword that can slay dragons", iconName: "icon_sword_double", price: 2000, rarity: .legendary, category: .weapons),

        // Armor
        ShopItem(name: "Leather Armor", description: "Light leather armor for mobility", iconName: "icon_armor", price: 150, rarity: .common, category: .armor),
        ShopItem(name: "Steel Helmet", description: "Protective steel helmet", iconName: "icon_helmet", price: 300, rarity: .uncommon, category: .armor),
        ShopItem(name: "Magic Robes", description: "Enchanted robes with magical protection", iconName: "icon_helmet_witch", price: 800, rarity: .epic, category: .armor),

        // Potions
        ShopItem(name: "Health Potion", description: "Restores health points", iconName: "icon_flash_red", price: 50, rarity: .common, category: .potions),
        ShopItem(name: "Mana Potion", description: "Restores magical energy", iconName: "icon_flask_blue", price: 75, rarity: .common, category: .potions),
        ShopItem(name: "Elixir of Life", description: "Powerful healing elixir", iconName: "icon_flash_green", price: 200, rarity: .rare, category: .potions),

        // XP Boosts
        ShopItem(name: "Minor XP Boost", description: "Increases XP gain by 25% for 30 minutes", iconName: "icon_xp_boost_minor", price: 75, rarity: .common, category: .boosts),
        ShopItem(name: "XP Boost", description: "Increases XP gain by 50% for 1 hour", iconName: "icon_xp_boost", price: 150, rarity: .uncommon, category: .boosts),
        ShopItem(name: "Greater XP Boost", description: "Increases XP gain by 100% for 2 hours", iconName: "icon_xp_boost_greater", price: 300, rarity: .rare, category: .boosts),
        ShopItem(name: "Legendary XP Boost", description: "Increases XP gain by 200% for 4 hours", iconName: "icon_xp_boost_legendary", price: 600, rarity: .legendary, category: .boosts),

        // Coin Boosts
        ShopItem(name: "Minor Coin Boost", description: "Increases coin gain by 25% for 30 minutes", iconName: "icon_coin_boost_minor", price: 100, rarity: .common, category: .boosts),
        ShopItem(name: "Coin Boost", description: "Increases coin gain by 50% for 1 hour", iconName: "icon_coin_boost", price: 200, rarity: .uncommon, category: .boosts),
        ShopItem(name: "Greater Coin Boost", description: "Increases coin gain by 100% for 2 hours", iconName: "icon_coin_boost_greater", price: 400, rarity: .rare, category: .boosts),

        // Accessories
        ShopItem(name: "Lucky Charm", description: "Increases luck and critical hits", iconName: "icon_medal", price: 400, rarity: .uncommon, category: .accessories),
        ShopItem(name: "Royal Crown", description: "Symbol of power and authority", iconName: "icon_crown", price: 1500, rarity: .epic, category: .accessories),
        ShopItem(name: "Golden Key", description: "Opens special treasure chests", iconName: "icon_key_gold", price: 300, rarity: .rare, category: .accessories),

        // Special Items
        ShopItem(name: "Mystery Egg", description: "What's inside? Only time will tell", iconName: "icon_egg", price: 1000, rarity: .epic, category: .special),
        ShopItem(name: "Pumpkin of Fortune", description: "A magical pumpkin with unknown powers", iconName: "icon_pumpkin", price: 750, rarity: .rare, category: .special)
    ]

    // MARK: - Public Methods

    func getAllItems() -> [ShopItem] {
        return shopItems
    }

    func getItemsByCategory(_ category: ShopCategory) -> [ShopItem] {
        return shopItems.filter { $0.category == category }
    }

    func getItemsByRarity(_ rarity: ItemRarity) -> [ShopItem] {
        return shopItems.filter { $0.rarity == rarity }
    }

    func purchaseItem(_ item: ShopItem, completion: @escaping (Bool, String?) -> Void) {
        currencyManager.spendCoins(item.price) { success, error in
            if success {
                // Add item to inventory
                let inventoryItem = Item(name: item.name, info: item.description, iconName: item.iconName)
                self.inventoryManager.addToInventory(inventoryItem)

                DispatchQueue.main.async {
                    completion(true, nil)
                }
            } else {
                DispatchQueue.main.async {
                    completion(false, error?.localizedDescription ?? "Purchase failed")
                }
            }
        }
    }

    func canAffordItem(_ item: ShopItem, completion: @escaping (Bool) -> Void) {
        currencyManager.getCurrentCoins { coins, _ in
            DispatchQueue.main.async {
                completion(coins >= item.price)
            }
        }
    }

    // MARK: - Daily Deals

    func getDailyDeals() -> [ShopItem] {
        // For now, return 3 random items with 20% discount
        let shuffledItems = shopItems.shuffled()
        return Array(shuffledItems.prefix(3))
    }

    func getDiscountedPrice(for item: ShopItem, discount: Double = 0.2) -> Int {
        return Int(Double(item.price) * (1.0 - discount))
    }

    // MARK: - Item Type Detection

    func isFunctionalItem(_ item: ShopItem) -> Bool {
        return item.category == .potions || item.category == .boosts
    }

    func isCollectibleItem(_ item: ShopItem) -> Bool {
        return item.category == .weapons || item.category == .armor || item.category == .accessories || item.category == .special
    }

    func getItemType(_ item: ShopItem) -> ItemType {
        return isFunctionalItem(item) ? .functional : .collectible
    }
}
