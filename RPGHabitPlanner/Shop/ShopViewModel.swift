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
    
    func loadCurrentCoins() {
        currencyManager.getCurrentCoins { coins, _ in
            DispatchQueue.main.async {
                self.currencyManager.currentCoins = coins
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
            items = items.filter { currencyManager.currentCoins >= shopManager.getDisplayPrice(for: $0) }
        }
        
        // Update cache
        cachedItems = items
        lastCategory = selectedCategory
        lastRarity = selectedRarity
        lastShowOnlyAffordable = showOnlyAffordable
    }
    
    func purchaseItem(_ item: ShopItem) {
        shopManager.purchaseItem(item) { success, errorMessage in
            if success {
                self.purchaseAlertMessage = "Successfully purchased \(item.name)!"
                self.loadCurrentCoins()
                // Refresh inventory and update cached items to reflect new ownership
                self.refreshInventory()
                self.updateCachedItems()
            } else {
                self.purchaseAlertMessage = errorMessage ?? "Purchase failed"
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
        default:
            // Handle other gear/customization items
            if let assetCategory = category.assetCategory {
                let assets = CharacterAssetManager.shared.getAvailableAssets(for: assetCategory)
                items = assets.map { asset in
                    let description = getItemDescription(for: asset.name, category: category)

                    return ShopItem(
                        name: asset.name,
                        description: description,
                        iconName: asset.imageName, // The actual image name for inventory storage
                        previewImage: asset.previewImage, // The preview image for shop display
                        price: Int(asset.rarity.basePriceMultiplier * 100), // Base price of 100
                        rarity: asset.rarity == .common ? .common :
                                asset.rarity == .uncommon ? .uncommon :
                                asset.rarity == .rare ? .rare :
                                asset.rarity == .epic ? .epic : .legendary,
                        category: category,
                        assetCategory: assetCategory, // Pass the asset category for proper gear categorization
                        isOwned: isItemOwned(name: asset.name, iconName: asset.imageName, category: category)
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
                ShopItem(
                    name: asset.name,
                    description: getItemDescription(for: asset.name, category: .armor),
                    iconName: asset.imageName, // The actual image name for inventory storage
                    previewImage: asset.previewImage, // The preview image for shop display
                    price: Int(asset.rarity.basePriceMultiplier * 100),
                    rarity: asset.rarity == .common ? .common :
                            asset.rarity == .uncommon ? .uncommon :
                            asset.rarity == .rare ? .rare :
                            asset.rarity == .epic ? .epic : .legendary,
                    category: .armor,
                    assetCategory: .head, // Specify the asset category for proper gear categorization
                    isOwned: isItemOwned(name: asset.name, iconName: asset.imageName, category: .armor)
                )
            }
        case .outfit:
            // Get outfit items from CharacterAssetManager
            let assets = CharacterAssetManager.shared.getAvailableAssets(for: .outfit)
            items = assets.map { asset in
                ShopItem(
                    name: asset.name,
                    description: getItemDescription(for: asset.name, category: .armor),
                    iconName: asset.imageName, // The actual image name for inventory storage
                    previewImage: asset.previewImage, // The preview image for shop display
                    price: Int(asset.rarity.basePriceMultiplier * 100),
                    rarity: asset.rarity == .common ? .common :
                            asset.rarity == .uncommon ? .uncommon :
                            asset.rarity == .rare ? .rare :
                            asset.rarity == .epic ? .epic : .legendary,
                    category: .armor,
                    assetCategory: .outfit, // Specify the asset category for proper gear categorization
                    isOwned: isItemOwned(name: asset.name, iconName: asset.imageName, category: .armor)
                )
            }
        case .shield:
            // Get shield items from CharacterAssetManager with preview images
            let assets = CharacterAssetManager.shared.getAvailableAssets(for: .shield)
            items = assets.map { asset in
                ShopItem(
                    name: asset.name,
                    description: getItemDescription(for: asset.name, category: .armor),
                    iconName: asset.imageName, // The actual image name for inventory storage
                    previewImage: asset.previewImage, // The preview image for shop display
                    price: Int(asset.rarity.basePriceMultiplier * 100),
                    rarity: asset.rarity == .common ? .common :
                            asset.rarity == .uncommon ? .uncommon :
                            asset.rarity == .rare ? .rare :
                            asset.rarity == .epic ? .epic : .legendary,
                    category: .armor,
                    assetCategory: .shield, // Specify the asset category for proper gear categorization
                    isOwned: isItemOwned(name: asset.name, iconName: asset.imageName, category: .armor)
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
                    name: item.name,
                    description: item.description,
                    iconName: item.iconName,
                    price: item.value,
                    rarity: .common, // Potions are typically common
                    category: .consumables,
                    isOwned: isItemOwned(name: item.name, iconName: item.iconName, category: .consumables)
                )
            }
        case .boosts:
            items = (ItemDatabase.allXPBoosts + ItemDatabase.allCoinBoosts).map { item in
                ShopItem(
                    name: item.name,
                    description: item.description,
                    iconName: item.iconName,
                    price: item.value,
                    rarity: item.isRare ? .rare : .uncommon,
                    category: .consumables,
                    isOwned: isItemOwned(name: item.name, iconName: item.iconName, category: .consumables)
                )
            }
        case .specials:
            items = ItemDatabase.allCollectibles.map { item in
                ShopItem(
                    name: item.name,
                    description: item.description,
                    iconName: item.iconName,
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
            ShopItem(
                name: item.name,
                description: item.description,
                iconName: item.iconName,
                price: item.value,
                rarity: item.rarity ?? .common,
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
        if let item = itemDatabase.findItem(by: assetName) {
            return item.description
        }

        // If not found, return a generic description based on category
        return getDescriptionForCategory(category)
    }
    
    private func getDescriptionForCategory(_ category: EnhancedShopCategory) -> String {
        switch category {
        case .weapons:
            return "A powerful weapon for combat"
        case .armor:
            return "Protective gear for your adventures"
        case .accessories:
            return "Stylish accessories to enhance your character"
        case .wings:
            return "Magical wings for your character"
        case .pets:
            return "A loyal companion for your adventures"
        case .consumables:
            return "Consumable items for your journey"
        }
    }
    
    private func isItemOwned(name: String, iconName: String, category: EnhancedShopCategory) -> Bool {
        // Check ownership for gear items, accessories, and collectibles, but allow consumables to be purchased multiple times
        switch category {
        case .consumables:
            return false // Consumables can always be purchased
        default:
            return inventoryManager.inventoryItems.contains { item in
                item.iconName == iconName
            }
        }
    }
}
