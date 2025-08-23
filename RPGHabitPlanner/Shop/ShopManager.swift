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
