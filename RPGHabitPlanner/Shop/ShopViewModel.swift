//
//  ShopViewModel.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 24.08.2025.
//

import SwiftUI

class ShopViewModel: ObservableObject {
    @Published var selectedCategory: EnhancedShopCategory
    @Published var selectedArmorSubcategory: ArmorSubcategory = .helmet
    @Published var selectedConsumableSubcategory: ConsumableSubcategory = .potions
    @Published var selectedRarity: ItemRarity?
    @Published var showOnlyAffordable = false
    @Published var showPurchaseAlert = false
    @Published var purchaseAlertMessage = ""
    @Published var selectedItem: ShopItem?
    @Published var showItemPreview = false

    // Cache for shop items to prevent constant recreation
    @Published var cachedItems: [ShopItem] = []
    private var lastCategory: EnhancedShopCategory?
    private var lastRarity: ItemRarity?
    private var lastShowOnlyAffordable: Bool = false

    private let shopManager = ShopManager.shared
    private let currencyManager = CurrencyManager.shared
    private let inventoryManager = InventoryManager.shared

    // Initial category parameter
    let initialCategory: EnhancedShopCategory?
    let initialArmorSubcategory: ArmorSubcategory?

    init(initialCategory: EnhancedShopCategory? = nil, initialArmorSubcategory: ArmorSubcategory? = nil) {
        self.initialCategory = initialCategory
        self.initialArmorSubcategory = initialArmorSubcategory
        self.selectedCategory = initialCategory ?? .weapons
        print("🎯 ShopViewModel: Initialized with category: \(selectedCategory.rawValue)")
    }

    // MARK: - Public Methods

    func loadCurrentCurrency() {
        currencyManager.getCurrentCoins { coins, _ in
            DispatchQueue.main.async {
                self.currencyManager.currentCoins = coins
            }
        }
        currencyManager.getCurrentGems { gems, _ in
            DispatchQueue.main.async {
                self.currencyManager.currentGems = gems
            }
        }
    }

    func refreshInventory() {
        inventoryManager.refreshInventory()
    }

    func updateCachedItems() {
        var items: [ShopItem] = getCustomizationItems(for: selectedCategory)

        // Apply rarity filter
        if let selectedRarity = selectedRarity {
            items = items.filter { $0.rarity == selectedRarity }
        }

        // Apply affordability filter
        if showOnlyAffordable {
            items = items.filter { item in
                if let gemPrice = item.gemPrice, item.rarity == .epic || item.rarity == .legendary {
                    return currencyManager.currentGems >= gemPrice
                } else {
                    return currencyManager.currentCoins >= shopManager.getDisplayPrice(for: item)
                }
            }
        }

        // Preserve existing item IDs to maintain SwiftUI identity
        let updatedItems = items.map { newItem in
            // Try to find existing item with same iconName to preserve ID
            if let existingItem = cachedItems.first(where: { $0.iconName == newItem.iconName }) {
                print("🔧 ShopViewModel: Preserving ID for existing item: \(newItem.name) - ID: \(existingItem.id)")
                return ShopItem(
                    id: existingItem.id, // Preserve the existing ID
                    name: newItem.name,
                    description: newItem.description,
                    iconName: newItem.iconName,
                    previewImage: newItem.previewImage,
                    price: newItem.price,
                    gemPrice: newItem.gemPrice,
                    rarity: newItem.rarity,
                    category: newItem.category,
                    assetCategory: newItem.assetCategory,
                    effects: newItem.effects,
                    isOwned: newItem.isOwned
                )
            } else {
                // New item, use the generated ID
                print("🔧 ShopViewModel: Creating new item with generated ID: \(newItem.name)")
                return newItem
            }
        }

        // Update cache
        cachedItems = updatedItems
        lastCategory = selectedCategory
        lastRarity = selectedRarity
        lastShowOnlyAffordable = showOnlyAffordable
    }

    func purchaseItem(_ item: ShopItem) {
        shopManager.purchaseItem(item) { success, errorMessage in
            if success {
                self.purchaseAlertMessage = String(format: "successfully_purchased".localized, item.name)
                self.loadCurrentCurrency()
                // Update only the specific item's ownership status instead of regenerating the entire list
                self.updateItemOwnershipStatus(item)
                // Refresh inventory after updating the UI to avoid any potential race conditions
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.refreshInventory()
                }
            } else {
                self.purchaseAlertMessage = errorMessage ?? "purchase_failed".localized
            }
            self.showPurchaseAlert = true
        }
    }

    func preloadImagesForCategory(_ category: EnhancedShopCategory) {
        DispatchQueue.global(qos: .utility).async {
            let items = self.getCustomizationItems(for: category)

            for item in items {
                // Preload each preview image in the background
                if let _ = UIImage(named: item.previewImage) {
                    // Image will be cached by the ImageCache when accessed
                    // This just ensures the image is loaded into memory
                }
            }
        }
    }

    // MARK: - Private Methods

    private func updateItemOwnershipStatus(_ purchasedItem: ShopItem) {
        // Find the item in cachedItems and update only its ownership status
        if let index = cachedItems.firstIndex(where: { $0.iconName == purchasedItem.iconName }) {
            print("🔧 ShopViewModel: Updating ownership status for item: \(purchasedItem.name) at index: \(index)")
            print("🔧 ShopViewModel: Item ID before update: \(cachedItems[index].id)")

            // Create a new ShopItem with updated ownership status but same ID and other properties
            let updatedItem = ShopItem(
                id: cachedItems[index].id, // Keep the same ID to prevent SwiftUI from treating it as a new item
                name: cachedItems[index].name,
                description: cachedItems[index].description,
                iconName: cachedItems[index].iconName,
                previewImage: cachedItems[index].previewImage,
                price: cachedItems[index].price,
                gemPrice: cachedItems[index].gemPrice,
                rarity: cachedItems[index].rarity,
                category: cachedItems[index].category,
                assetCategory: cachedItems[index].assetCategory,
                effects: cachedItems[index].effects,
                isOwned: true // Update ownership status
            )

            // Update the item in the cached array
            cachedItems[index] = updatedItem
            print("🔧 ShopViewModel: Item ownership updated successfully. New isOwned: \(updatedItem.isOwned)")
        } else {
            print("❌ ShopViewModel: Could not find item to update ownership: \(purchasedItem.name) with iconName: \(purchasedItem.iconName)")
        }
    }

    private func getCustomizationItems(for category: EnhancedShopCategory) -> [ShopItem] {
        var items: [ShopItem] = []

        switch category {
        case .armor:
            // Handle armor subcategories
            items = getArmorItems(for: selectedArmorSubcategory)
        case .consumables:
            // Handle consumable subcategories
            items = getConsumableItems(for: selectedConsumableSubcategory)
        case .wings:
            // Handle wings specifically
            items = getWingsItems()
        case .weapons:
            // Handle weapons specifically
            if let assetCategory = category.assetCategory {
                let assets = CharacterAssetManager.shared.getAvailableAssets(for: assetCategory)
                items = assets.map { asset in
                    let itemName = getItemNameFromDatabase(iconName: asset.imageName) ?? asset.name
                    let description = getItemDescription(for: itemName, category: category)
                    let rarity = asset.rarity.toItemRarity

                    // Set gem prices for epic and legendary items based on category
                    let gemPrice = getGemPrice(for: rarity, category: assetCategory)

                    return ShopItem(
                        name: itemName,
                        description: description,
                        iconName: asset.imageName, // The actual image name for inventory storage
                        previewImage: asset.previewImage, // The preview image for shop display
                        price: Int(asset.rarity.basePriceMultiplier * 100), // Base price of 100
                        gemPrice: gemPrice,
                        rarity: rarity,
                        category: category,
                        assetCategory: assetCategory, // Pass the asset category for proper gear categorization
                        isOwned: isItemOwned(name: itemName, iconName: asset.imageName, category: category)
                    )
                }
            }
        default:
            // Handle other gear/customization items
            if let assetCategory = category.assetCategory {
                let assets = CharacterAssetManager.shared.getAvailableAssets(for: assetCategory)
                items = assets.map { asset in
                    let itemName = getItemNameFromDatabase(iconName: asset.imageName) ?? asset.name
                    let description = getItemDescription(for: itemName, category: category)
                    let rarity = asset.rarity.toItemRarity

                    // Set gem prices for epic and legendary items based on category
                    let gemPrice = getGemPrice(for: rarity, category: assetCategory)

                    return ShopItem(
                        name: itemName,
                        description: description,
                        iconName: asset.imageName, // The actual image name for inventory storage
                        previewImage: asset.previewImage, // The preview image for shop display
                        price: Int(asset.rarity.basePriceMultiplier * 100), // Base price of 100
                        gemPrice: gemPrice,
                        rarity: rarity,
                        category: category,
                        assetCategory: assetCategory, // Pass the asset category for proper gear categorization
                        isOwned: isItemOwned(name: itemName, iconName: asset.imageName, category: category)
                    )
                }
            }
        }

        // Sort items by rarity from common to legendary
        return sortItemsByRarity(items)
    }

    private func sortItemsByRarity(_ items: [ShopItem]) -> [ShopItem] {
        return items.sorted { item1, item2 in
            item1.rarity.sortOrder < item2.rarity.sortOrder
        }
    }

    private func getArmorItems(for subcategory: ArmorSubcategory) -> [ShopItem] {
        var items: [ShopItem] = []

        switch subcategory {
        case .helmet:
            // Get helmet items from CharacterAssetManager with preview images
            let assets = CharacterAssetManager.shared.getAvailableAssets(for: .head)
            items = assets.map { asset in
                let itemName = getItemNameFromDatabase(iconName: asset.imageName) ?? asset.name
                let rarity = asset.rarity.toItemRarity
                let gemPrice = getGemPrice(for: rarity, category: .head)

                return ShopItem(
                    name: itemName,
                    description: getItemDescription(for: itemName, category: .armor),
                    iconName: asset.imageName, // The actual image name for inventory storage
                    previewImage: asset.previewImage, // The preview image for shop display
                    price: Int(asset.rarity.basePriceMultiplier * 100),
                    gemPrice: gemPrice,
                    rarity: rarity,
                    category: .armor,
                    assetCategory: .head, // Specify the asset category for proper gear categorization
                    isOwned: isItemOwned(name: itemName, iconName: asset.imageName, category: .armor)
                )
            }
        case .outfit:
            // Get outfit items from CharacterAssetManager
            let assets = CharacterAssetManager.shared.getAvailableAssets(for: .outfit)
            items = assets.map { asset in
                let itemName = getItemNameFromDatabase(iconName: asset.imageName) ?? asset.name
                let rarity = asset.rarity.toItemRarity
                let gemPrice = getGemPrice(for: rarity, category: .outfit)

                return ShopItem(
                    name: itemName,
                    description: getItemDescription(for: itemName, category: .armor),
                    iconName: asset.imageName, // The actual image name for inventory storage
                    previewImage: asset.previewImage, // The preview image for shop display
                    price: Int(asset.rarity.basePriceMultiplier * 100),
                    gemPrice: gemPrice,
                    rarity: rarity,
                    category: .armor,
                    assetCategory: .outfit, // Specify the asset category for proper gear categorization
                    isOwned: isItemOwned(name: itemName, iconName: asset.imageName, category: .armor)
                )
            }
        case .shield:
            // Get shield items from CharacterAssetManager with preview images
            let assets = CharacterAssetManager.shared.getAvailableAssets(for: .shield)
            items = assets.map { asset in
                let itemName = getItemNameFromDatabase(iconName: asset.imageName) ?? asset.name
                let rarity = asset.rarity.toItemRarity
                let gemPrice = getGemPrice(for: rarity, category: .shield)

                return ShopItem(
                    name: itemName,
                    description: getItemDescription(for: itemName, category: .armor),
                    iconName: asset.imageName, // The actual image name for inventory storage
                    previewImage: asset.previewImage, // The preview image for shop display
                    price: Int(asset.rarity.basePriceMultiplier * 100),
                    gemPrice: gemPrice,
                    rarity: rarity,
                    category: .armor,
                    assetCategory: .shield, // Specify the asset category for proper gear categorization
                    isOwned: isItemOwned(name: itemName, iconName: asset.imageName, category: .armor)
                )
            }
        }

        // Sort items by rarity from common to legendary
        return sortItemsByRarity(items)
    }

    private func getConsumableItems(for subcategory: ConsumableSubcategory) -> [ShopItem] {
        var items: [ShopItem] = []

        switch subcategory {
        case .potions:
            items = ItemDatabase.allHealthPotions.map { item in
                ShopItem(
                    name: item.localizedName,
                    description: item.localizedDescription,
                    iconName: item.iconName,
                    previewImage: item.iconName, // Use iconName as preview since no preview assets exist
                    price: item.value,
                    rarity: .common, // Potions are typically common
                    category: .consumables,
                    isOwned: isItemOwned(name: item.name, iconName: item.iconName, category: .consumables)
                )
            }
        case .boosts:
            items = (ItemDatabase.allXPBoosts + ItemDatabase.allCoinBoosts).map { item in
                ShopItem(
                    name: item.localizedName,
                    description: item.localizedDescription,
                    iconName: item.iconName,
                    previewImage: item.iconName, // Use iconName as preview since no preview assets exist
                    price: item.value,
                    rarity: item.isRare ? .rare : .common,
                    category: .consumables,
                    isOwned: isItemOwned(name: item.name, iconName: item.iconName, category: .consumables)
                )
            }
        }

        // Sort items by rarity from common to legendary
        return sortItemsByRarity(items)
    }

    private func getWingsItems() -> [ShopItem] {
        // Get wings items from ItemDatabase
        let items = ItemDatabase.allGear.filter { $0.gearCategory == .wings }.map { item in
            let rarity = item.rarity ?? .common
            let gemPrice = getGemPrice(for: rarity, category: .wings)

            return ShopItem(
                name: item.localizedName,
                description: item.localizedDescription,
                iconName: item.iconName,
                previewImage: item.previewImage, // Use the proper preview image from ItemDatabase
                price: item.value,
                gemPrice: gemPrice,
                rarity: rarity,
                category: .wings,
                isOwned: isItemOwned(name: item.name, iconName: item.iconName, category: .wings)
            )
        }

        // Sort items by rarity from common to legendary
        return sortItemsByRarity(items)
    }

    private func getItemDescription(for assetName: String, category: EnhancedShopCategory) -> String {
        // Try to find the item in ItemDatabase first
        let itemDatabase = ItemDatabase.shared

        // Search in all items
        if let item = ItemDatabase.findItem(by: assetName) {
            return item.description
        }

        // If not found, return a generic description based on category
        return getDescriptionForCategory(category)
    }

    private func getDescriptionForCategory(_ category: EnhancedShopCategory) -> String {
        switch category {
        case .weapons:
            return "shop_category_weapons_description".localized
        case .armor:
            return "shop_category_armor_description".localized
        case .wings:
            return "shop_category_wings_description".localized
        case .pets:
            return "shop_category_pets_description".localized
        case .consumables:
            return "shop_category_consumables_description".localized
        }
    }

    private func isItemOwned(name: String, iconName: String, category: EnhancedShopCategory) -> Bool {
        // Check ownership for gear items and collectibles, but allow consumables to be purchased multiple times
        switch category {
        case .consumables:
            return false // Consumables can always be purchased
        default:
            let isOwned = inventoryManager.inventoryItems.contains { item in
                item.iconName == iconName
            }
            print("🔧 ShopViewModel: Checking if item is owned - name: \(name), iconName: \(iconName), category: \(category.rawValue), isOwned: \(isOwned)")
            print("🔧 ShopViewModel: Current inventory count: \(inventoryManager.inventoryItems.count)")
            for item in inventoryManager.inventoryItems {
                print("  - \(item.name ?? "unknown_item".localized) (iconName: \(item.iconName ?? "nil"))")
            }
            return isOwned
        }
    }

    private func getGemPrice(for rarity: ItemRarity, category: AssetCategory) -> Int? {
        // Only epic and legendary items require gems
        guard rarity == .epic || rarity == .legendary else {
            return nil
        }

        switch category {
        case .head, .headGear:
            return rarity == .epic ? 30 : 50 // Epic helmets 30 gems, legendary 50 gems
        case .outfit:
            return rarity == .epic ? 60 : 100 // Epic outfits 60 gems, legendary 100 gems
        case .wings:
            return rarity == .epic ? 80 : 150 // Epic wings 80 gems, legendary 150 gems
        case .shield:
            return rarity == .epic ? 30 : 50 // Epic shields 30 gems, legendary 50 gems
        case .weapon:
            return rarity == .epic ? 60 : 100 // Epic weapons 60 gems, legendary 100 gems
        default:
            return nil // Other categories don't use gems
        }
    }
    
    private func getItemNameFromDatabase(iconName: String) -> String? {
        // Try to find the item in ItemDatabase by icon name
        if let item = ItemDatabase.findItem(byIconName: iconName) {
            return item.localizedName
        }
        return nil
    }
}
