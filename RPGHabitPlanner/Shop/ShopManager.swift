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
        // Since we're now using CharacterAssetManager for all shop items,
        // this legacy shopItems array is no longer needed
        return []
    }()

    // MARK: - Public Methods

    func getAllItems() -> [ShopItem] {
        return shopItems
    }

    func getItemsByCategory(_ category: EnhancedShopCategory) -> [ShopItem] {
        return shopItems.filter { $0.category == category }
    }

    func getItemsByRarity(_ rarity: ItemRarity) -> [ShopItem] {
        // Since we're now using CharacterAssetManager, this method is no longer needed
        return []
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
                // Create proper inventory item based on shop item category
                let inventoryItem = self.createInventoryItem(from: item)
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
    
    private func createInventoryItem(from shopItem: ShopItem) -> Item {
        switch shopItem.category {
        case .weapons, .armor, .wings, .pets:
            return createGearItem(from: shopItem)
        case .accessories:
            return createAccessoryItem(from: shopItem)
        case .consumables:
            return createConsumableItem(from: shopItem)
        }
    }
    
    private func createGearItem(from shopItem: ShopItem) -> Item {
        // Try to find the item in ItemDatabase first to get the correct gear category
        let itemDatabase = ItemDatabase.shared
        if let existingItem = itemDatabase.findItem(byIconName: shopItem.iconName) {
            // Use the existing item definition from ItemDatabase
            return existingItem
        }

        // Fallback to determining gear category if item not found in database
        let gearCategory = determineGearCategory(from: shopItem)
        return Item.gear(
            name: shopItem.name,
            description: shopItem.description,
            iconName: shopItem.iconName,
            category: gearCategory,
            rarity: shopItem.rarity,
            value: shopItem.price,
            effects: shopItem.effects
        )
    }

    private func determineGearCategory(from shopItem: ShopItem) -> GearCategory {
        // If we have asset category information, use it directly
        if let assetCategory = shopItem.assetCategory {
            switch assetCategory {
            case .head, .headGear:
                return .head
            case .outfit:
                return .outfit
            case .weapon:
                return .weapon
            case .shield:
                return .shield
            case .wings:
                return .wings
            case .pet:
                return .pet
            default:
                break
            }
        }
        
        // Fallback to category-based determination
        switch shopItem.category {
        case .weapons:
            return .weapon
        case .armor:
            return determineArmorCategory(from: shopItem.name)
        case .wings:
            return .wings
        case .pets:
            return .pet
        default:
            return .weapon
        }
    }

    private func determineArmorCategory(from name: String) -> GearCategory {
        let lowercasedName = name.lowercased()

        // Check for head gear items first
        if lowercasedName.contains("helmet") || lowercasedName.contains("head") || lowercasedName.contains("hood") {
            return .head
        } else if lowercasedName.contains("shield") {
            return .shield
        } else {
            // Default to outfit for other armor items
            return .outfit
        }
    }

    private func createAccessoryItem(from shopItem: ShopItem) -> Item {
        let accessoryCategory = determineAccessoryCategory(from: shopItem.name)
        return Item.accessory(
            name: shopItem.name,
            description: shopItem.description,
            iconName: shopItem.iconName,
            category: accessoryCategory,
            value: shopItem.price
        )
    }

    private func determineAccessoryCategory(from name: String) -> AccessoryCategory {
        let lowercasedName = name.lowercased()
        if lowercasedName.contains("glasses") || lowercasedName.contains("glass") {
            return .eyeglasses
        } else if lowercasedName.contains("earring") {
            return .earrings
        } else if lowercasedName.contains("lash") || lowercasedName.contains("blush") {
            return .lashes
        } else {
            return .clips
        }
    }

    private func createConsumableItem(from shopItem: ShopItem) -> Item {
        let lowercasedName = shopItem.name.lowercased()

        if lowercasedName.contains("potion") {
            return createHealthPotion(from: shopItem)
        } else if lowercasedName.contains("xp") {
            return createXPBoost(from: shopItem)
        } else if lowercasedName.contains("coin") {
            return createCoinBoost(from: shopItem)
        } else {
            return createCollectible(from: shopItem)
        }
    }

    private func createHealthPotion(from shopItem: ShopItem) -> Item {
        let healAmount = determineHealAmount(from: shopItem.name)

        return Item.healthPotion(
            name: shopItem.name,
            description: shopItem.description,
            healAmount: healAmount,
            value: shopItem.price
        )
    }

    private func determineHealAmount(from name: String) -> Int16 {
        let lowercasedName = name.lowercased()
        if lowercasedName.contains("legendary") {
            return 999
        } else if lowercasedName.contains("superior") {
            return 75
        } else if lowercasedName.contains("greater") {
            return 50
        } else if lowercasedName.contains("minor") {
            return 15
        } else {
            return 30
        }
    }

    private func createXPBoost(from shopItem: ShopItem) -> Item {
        let (multiplier, duration) = determineBoostValues(from: shopItem.name)

        return Item.xpBoost(
            name: shopItem.name,
            description: shopItem.description,
            multiplier: multiplier,
            duration: duration,
            value: shopItem.price
        )
    }

    private func createCoinBoost(from shopItem: ShopItem) -> Item {
        let (multiplier, duration) = determineBoostValues(from: shopItem.name)

        return Item.coinBoost(
            name: shopItem.name,
            description: shopItem.description,
            multiplier: multiplier,
            duration: duration,
            value: shopItem.price
        )
    }

    private func determineBoostValues(from name: String) -> (multiplier: Double, duration: TimeInterval) {
        let lowercasedName = name.lowercased()
        if lowercasedName.contains("legendary") {
            return (3.0, 4 * 60 * 60)
        } else if lowercasedName.contains("greater") {
            return (2.0, 2 * 60 * 60)
        } else if lowercasedName.contains("minor") {
            return (1.25, 30 * 60)
        } else {
            return (1.5, 60 * 60)
        }
    }

    private func createCollectible(from shopItem: ShopItem) -> Item {
        return Item.collectible(
            name: shopItem.name,
            description: shopItem.description,
            iconName: shopItem.iconName,
            collectionCategory: "Shop",
            isRare: shopItem.rarity != .common
        )
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
        // Since we're now using CharacterAssetManager, this method is no longer needed
        return []
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
        // Since we're now using CharacterAssetManager, all items are gear items
        return false
    }

    func isCollectibleItem(_ item: ShopItem) -> Bool {
        // Since we're now using CharacterAssetManager, all items are gear items
        return false
    }

    func isGearItem(_ item: ShopItem) -> Bool {
        // Since we're now using CharacterAssetManager, all items are gear items
        return true
    }

    func getItemType(_ item: ShopItem) -> ItemType {
        // Since we're now using CharacterAssetManager, all items are gear items
        return .gear
    }
}
