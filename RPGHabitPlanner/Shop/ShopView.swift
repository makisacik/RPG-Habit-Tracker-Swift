//
//  ShopView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 17.11.2024.
//

import SwiftUI

struct ShopView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var shopManager = ShopManager.shared
    @StateObject private var currencyManager = CurrencyManager.shared
    @StateObject private var inventoryManager = InventoryManager.shared
    @State private var selectedCategory: EnhancedShopCategory = .weapons
    @State private var selectedArmorSubcategory: ArmorSubcategory = .helmet
    @State private var selectedConsumableSubcategory: ConsumableSubcategory = .potions
    @State private var selectedRarity: ItemRarity?
    @State private var showOnlyAffordable = false
    @State private var showPurchaseAlert = false
    @State private var purchaseAlertMessage = ""
    @State private var selectedItem: ShopItem?
    @State private var showItemPreview = false
    
    // Cache for shop items to prevent constant recreation
    @State private var cachedItems: [ShopItem] = []
    @State private var lastCategory: EnhancedShopCategory?
    @State private var lastRarity: ItemRarity?
    @State private var lastShowOnlyAffordable: Bool = false

    var body: some View {
        let theme = themeManager.activeTheme

        ZStack {
            theme.backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with coins
                shopHeader(theme: theme)

                // Enhanced category picker
                ShopCategoryView(
                    selectedCategory: $selectedCategory
                ) { category in
                        selectedCategory = category
                        // Preload images for the new category
                        preloadImagesForCategory(category)
                }
                .padding(.vertical, 8)

                // Subcategory picker for armor
                if selectedCategory == .armor {
                    ArmorSubcategoryView(
                        selectedSubcategory: $selectedArmorSubcategory
                    ) { subcategory in
                        selectedArmorSubcategory = subcategory
                        updateCachedItems()
                    }
                    .padding(.vertical, 4)
                }

                // Subcategory picker for consumables
                if selectedCategory == .consumables {
                    ConsumableSubcategoryView(
                        selectedSubcategory: $selectedConsumableSubcategory
                    ) { subcategory in
                        selectedConsumableSubcategory = subcategory
                        updateCachedItems()
                    }
                    .padding(.vertical, 4)
                }

                // Filters
                ShopFilterView(
                    selectedRarity: $selectedRarity,
                    priceRange: .constant(0...1000),
                    showOnlyAffordable: $showOnlyAffordable,
                    selectedCategory: selectedCategory
                ) {
                        // Filter logic handled in itemsGrid
                }

                // Enhanced items grid
                enhancedItemsGrid(theme: theme)
            }
        }
        .navigationTitle("Shop")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadCurrentCoins()
            // Refresh inventory to get latest ownership status
            inventoryManager.refreshInventory()
            // Preload images for the current category
            preloadImagesForCategory(selectedCategory)
            // Initialize cache
            updateCachedItems()
        }
        .onChange(of: selectedCategory) { _ in
            updateCachedItems()
            // Preload images for the new category
            preloadImagesForCategory(selectedCategory)
        }
        .onChange(of: inventoryManager.inventoryItems) { _ in
            // Update cached items when inventory changes
            updateCachedItems()
        }
        .onChange(of: selectedRarity) { _ in
            updateCachedItems()
        }
        .onChange(of: showOnlyAffordable) { _ in
            updateCachedItems()
        }
        .alert("Purchase", isPresented: $showPurchaseAlert) {
            Button("OK") { }
        } message: {
            Text(purchaseAlertMessage)
        }

        .overlay {
            if showItemPreview, let item = selectedItem {
                ItemPreviewModal(
                    item: item,
                    onDismiss: { showItemPreview = false },
                    onPurchase: { purchaseItem(item) }
                )
                .environmentObject(themeManager)
            }
        }
    }

    // MARK: - Header

    private func shopHeader(theme: Theme) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Adventure Shop")
                    .font(.appFont(size: 24, weight: .black))
                    .foregroundColor(theme.textColor)

                Text("Trade your coins for powerful items")
                    .font(.appFont(size: 14))
                    .foregroundColor(theme.textColor.opacity(0.7))
            }

            Spacer()

            // Coin display
            HStack(spacing: 8) {
                Image("icon_gold")
                    .resizable()
                    .frame(width: 24, height: 24)

                Text("\(currencyManager.currentCoins)")
                    .font(.appFont(size: 18, weight: .black))
                    .foregroundColor(.yellow)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.yellow.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
                    )
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.primaryColor)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal)
        .padding(.top)
    }

    // MARK: - Enhanced Items Grid

    private func enhancedItemsGrid(theme: Theme) -> some View {
        let filteredItems = getFilteredItems()

        return ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(filteredItems) { item in
                    EnhancedShopItemCard(
                        item: item,
                        selectedCategory: selectedCategory,
                        isCustomizationItem: selectedCategory.isCustomizationCategory || selectedCategory.assetCategory != nil,
                        onPurchase: {
                            purchaseItem(item)
                        },
                        onPreview: (selectedCategory.isCustomizationCategory || selectedCategory.assetCategory != nil) ? {
                            selectedItem = item
                            showItemPreview = true
                        } : nil
                    )
                    .environmentObject(themeManager)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }

    private func getFilteredItems() -> [ShopItem] {
        // Return cached items - updates will be handled by onChange modifiers
        return cachedItems
    }
    
    private func updateCachedItems() {
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
                    let description = getDescriptionForCategory(category)

                    return ShopItem(
                        name: asset.name,
                        description: description,
                        iconName: asset.imageName, // Use the actual image name, not preview
                        price: Int(asset.rarity.basePriceMultiplier * 100), // Base price of 100
                        rarity: asset.rarity == .common ? .common :
                                asset.rarity == .uncommon ? .uncommon :
                                asset.rarity == .rare ? .rare :
                                asset.rarity == .epic ? .epic : .legendary,
                        category: category,
                        isOwned: isItemOwned(name: asset.name, iconName: asset.imageName, category: category)
                    )
                }
            }
        }

        return items
    }

    private func getArmorItems(for subcategory: ArmorSubcategory) -> [ShopItem] {
        switch subcategory {
        case .helmet:
            // Get helmet items from CharacterAssetManager with preview images
            let assets = CharacterAssetManager.shared.getAvailableAssets(for: .head)
            return assets.map { asset in
                ShopItem(
                    name: asset.name,
                    description: "Protective helmet for your adventures",
                    iconName: asset.imageName, // Use the actual image name, not preview
                    price: Int(asset.rarity.basePriceMultiplier * 100),
                    rarity: asset.rarity == .common ? .common :
                            asset.rarity == .uncommon ? .uncommon :
                            asset.rarity == .rare ? .rare :
                            asset.rarity == .epic ? .epic : .legendary,
                    category: .armor,
                    isOwned: isItemOwned(name: asset.name, iconName: asset.imageName, category: .armor)
                )
            }
        case .outfit:
            // Get outfit items from CharacterAssetManager
            let assets = CharacterAssetManager.shared.getAvailableAssets(for: .outfit)
            return assets.map { asset in
                ShopItem(
                    name: asset.name,
                    description: "Protective outfit for your adventures",
                    iconName: asset.imageName, // Use the actual image name, not preview
                    price: Int(asset.rarity.basePriceMultiplier * 100),
                    rarity: asset.rarity == .common ? .common :
                            asset.rarity == .uncommon ? .uncommon :
                            asset.rarity == .rare ? .rare :
                            asset.rarity == .epic ? .epic : .legendary,
                    category: .armor,
                    isOwned: isItemOwned(name: asset.name, iconName: asset.imageName, category: .armor)
                )
            }
        case .shield:
            // Get shield items from CharacterAssetManager with preview images
            let assets = CharacterAssetManager.shared.getAvailableAssets(for: .shield)
            return assets.map { asset in
                ShopItem(
                    name: asset.name,
                    description: "Protective shield for your adventures",
                    iconName: asset.imageName, // Use the actual image name, not preview
                    price: Int(asset.rarity.basePriceMultiplier * 100),
                    rarity: asset.rarity == .common ? .common :
                            asset.rarity == .uncommon ? .uncommon :
                            asset.rarity == .rare ? .rare :
                            asset.rarity == .epic ? .epic : .legendary,
                    category: .armor,
                    isOwned: isItemOwned(name: asset.name, iconName: asset.imageName, category: .armor)
                )
            }
        }
    }
    
    private func getConsumableItems(for subcategory: ConsumableSubcategory) -> [ShopItem] {
        switch subcategory {
        case .potions:
            return ItemDatabase.allHealthPotions.map { item in
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
            return (ItemDatabase.allXPBoosts + ItemDatabase.allCoinBoosts).map { item in
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
            return ItemDatabase.allCollectibles.map { item in
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
    }

    private func getWingsItems() -> [ShopItem] {
        // Get wings items from ItemDatabase
        return ItemDatabase.allGear.filter { $0.gearCategory == .wings }.map { item in
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


    // MARK: - Helper Methods

    private func loadCurrentCoins() {
        currencyManager.getCurrentCoins { coins, _ in
            DispatchQueue.main.async {
                currencyManager.currentCoins = coins
            }
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

    private func purchaseItem(_ item: ShopItem) {
        shopManager.purchaseItem(item) { success, errorMessage in
            if success {
                purchaseAlertMessage = "Successfully purchased \(item.name)!"
                loadCurrentCoins()
            } else {
                purchaseAlertMessage = errorMessage ?? "Purchase failed"
            }
            showPurchaseAlert = true
        }
    }

    // MARK: - Image Preloading

    private func preloadImagesForCategory(_ category: EnhancedShopCategory) {
        DispatchQueue.global(qos: .utility).async {
            let items = getCustomizationItems(for: category)

            for item in items {
                // Preload each image in the background
                if let _ = UIImage(named: item.iconName) {
                    // Image will be cached by the ImageCache when accessed
                    // This just ensures the image is loaded into memory
                }
            }
        }
    }
}
