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
    private lazy var inventoryManager = InventoryManager.shared

    private init() {
    }

    // MARK: - Shop Items

    private lazy var shopItems: [ShopItem] = {
        let itemDatabase = ItemDatabase.shared

        // Convert ItemDatabase items to ShopItems
        var items: [ShopItem] = []

        // Add all health potions
        for potion in ItemDatabase.allHealthPotions {
            items.append(ShopItem(
                name: potion.name,
                description: potion.description,
                iconName: potion.iconName,
                price: potion.value,
                rarity: potion.rarity,
                category: .potions,
                effects: potion.effects
            ))
        }

        // Add all XP boosts
        for boost in ItemDatabase.allXPBoosts {
            items.append(ShopItem(
                name: boost.name,
                description: boost.description,
                iconName: boost.iconName,
                price: boost.value,
                rarity: boost.rarity,
                category: .boosts,
                effects: boost.effects
            ))
        }

        // Add all coin boosts
        for boost in ItemDatabase.allCoinBoosts {
            items.append(ShopItem(
                name: boost.name,
                description: boost.description,
                iconName: boost.iconName,
                price: boost.value,
                rarity: boost.rarity,
                category: .boosts,
                effects: boost.effects
            ))
        }

        // Add some collectible items (weapons, armor, accessories)
        let collectibleItems = [
            "Sword", "Axe", "Dagger", "Shield", "Helmet", "Crown", "Medal", "Key Gold", "Egg", "Pumpkin"
        ]

        for itemName in collectibleItems {
            if let item = itemDatabase.findItem(by: itemName) {
                let category: ShopCategory
                switch item.collectionCategory {
                case "Weapons": category = .weapons
                case "Armor": category = .armor
                case "Accessories", "Royalty": category = .accessories
                default: category = .special
                }

                items.append(ShopItem(
                    name: item.name,
                    description: item.description,
                    iconName: item.iconName,
                    price: item.value,
                    rarity: item.rarity,
                    category: category,
                    effects: item.effects
                ))
            }
        }

        return items
    }()

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
        // In debug mode, all items cost 1 coin
        #if DEBUG
        let actualPrice = 1
        #else
        let actualPrice = item.price
        #endif

        currencyManager.spendCoins(actualPrice) { success, error in
            if success {
                // Add item to inventory
                let inventoryItem = Item(name: item.name, description: item.description, iconName: item.iconName)
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
        // In debug mode, all items cost 1 coin
        #if DEBUG
        let actualPrice = 1
        #else
        let actualPrice = item.price
        #endif

        currencyManager.getCurrentCoins { coins, _ in
            DispatchQueue.main.async {
                completion(coins >= actualPrice)
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
        // In debug mode, all items cost 1 coin
        #if DEBUG
        return 1
        #else
        return Int(Double(item.price) * (1.0 - discount))
        #endif
    }

    func getDisplayPrice(for item: ShopItem) -> Int {
        // In debug mode, all items cost 1 coin
        #if DEBUG
        return 1
        #else
        return item.price
        #endif
    }

    // MARK: - Item Type Detection

    func isFunctionalItem(_ item: ShopItem) -> Bool {
        return item.category == .potions || item.category == .boosts
    }

    func isCollectibleItem(_ item: ShopItem) -> Bool {
        return item.category == .weapons || item.category == .armor || item.category == .accessories || item.category == .special
    }

    func getItemType(_ item: ShopItem) -> ItemType {
        switch item.category {
        case .potions:
            return .consumable
        case .boosts:
            return .booster
        case .weapons, .armor:
            return .equipable
        case .accessories, .special:
            return .collectible
        }
    }
}
