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
    @State private var selectedCategory: EnhancedShopCategory = .potions
    @State private var selectedRarity: ItemRarity?
    @State private var showOnlyAffordable = false
    @State private var showPurchaseAlert = false
    @State private var purchaseAlertMessage = ""
    @State private var selectedItem: ShopItem?
    @State private var showItemDetails = false
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

                // Filters
                ShopFilterView(
                    selectedRarity: $selectedRarity,
                    priceRange: .constant(0...1000),
                    showOnlyAffordable: $showOnlyAffordable
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
        .sheet(isPresented: $showItemDetails) {
            if let item = selectedItem {
                ItemDetailView(item: item) { purchaseItem(item) }
                    .environmentObject(themeManager)
            }
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
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ForEach(filteredItems) { item in
                    EnhancedShopItemCard(
                        item: item,
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
            .padding()
        }
    }

    private func getFilteredItems() -> [ShopItem] {
        // Return cached items - updates will be handled by onChange modifiers
        return cachedItems
    }
    
    private func updateCachedItems() {
        var items: [ShopItem]

        // Get items for category - use character assets for all gear categories
        if selectedCategory.isCustomizationCategory || selectedCategory.assetCategory != nil {
            items = getCustomizationItems(for: selectedCategory)
        } else {
            // Use legacy category mapping for non-character asset items (potions, boosts, special)
            let legacyCategory = mapToLegacyCategory(selectedCategory)
            items = shopManager.getItemsByCategory(legacyCategory)
        }

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
        // For character asset categories (pets, weapons, armor, accessories), use preview images
        if let assetCategory = category.assetCategory {
            let assets = CharacterAssetManager.shared.getAvailableAssetsWithPreview(for: assetCategory)
            return assets.map { asset in
                let description = getDescriptionForCategory(category)
                let shopCategory = mapToLegacyCategory(category)

                return ShopItem(
                    name: asset.name,
                    description: description,
                    iconName: asset.imageName,
                    price: Int(asset.rarity.basePriceMultiplier * 100), // Base price of 100
                    rarity: asset.rarity == .common ? .common :
                            asset.rarity == .uncommon ? .uncommon :
                            asset.rarity == .rare ? .rare :
                            asset.rarity == .epic ? .epic : .legendary,
                    category: shopCategory
                )
            }
        }

        // For other categories (potions, boosts, special), use gear items from the database
        let legacyCategory = mapToLegacyCategory(category)
        return shopManager.getItemsByCategory(legacyCategory)
    }
    
    private func getDescriptionForCategory(_ category: EnhancedShopCategory) -> String {
        switch category {
        case .weapons:
            return "A powerful weapon for combat"
        case .armor:
            return "Protective gear for your adventures"
        case .accessories:
            return "Stylish accessories to enhance your character"
        case .pets:
            return "A loyal companion for your adventures"
        default:
            return "A useful item for your journey"
        }
    }

    private func mapToLegacyCategory(_ enhancedCategory: EnhancedShopCategory) -> ShopCategory {
        switch enhancedCategory {
        case .weapons: return .weapons
        case .armor: return .armor
        case .accessories: return .accessories
        case .pets: return .accessories
        case .potions: return .potions
        case .boosts: return .boosts
        case .special: return .special
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

// MARK: - Shop Item Card

struct ShopItemCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var shopManager: ShopManager
    let item: ShopItem
    let canAfford: Bool
    let onTap: () -> Void
    let onPurchase: () -> Void
    @State private var isPressed = false

    var body: some View {
        let theme = themeManager.activeTheme

        VStack(spacing: 12) {
            // Item icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.secondaryColor)
                    .frame(height: 80)

                Image(item.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
            }

            // Item info
            VStack(spacing: 4) {
                HStack {
                    Text(item.name)
                        .font(.appFont(size: 16, weight: .black))
                        .foregroundColor(theme.textColor)
                        .multilineTextAlignment(.center)

                    // Item type indicator
                    if shopManager.isFunctionalItem(item) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.yellow)
                    } else {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }

                Text(item.description)
                    .font(.appFont(size: 12))
                    .foregroundColor(theme.textColor.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                // Item type label
                HStack(spacing: 4) {
                    if shopManager.isFunctionalItem(item) {
                        Text("Functional")
                            .font(.appFont(size: 10, weight: .black))
                            .foregroundColor(.yellow)
                    } else {
                        Text("Collectible")
                            .font(.appFont(size: 10, weight: .medium))
                            .foregroundColor(theme.textColor.opacity(0.7))
                    }
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(shopManager.isFunctionalItem(item) ? Color.yellow.opacity(0.2) : Color.white.opacity(0.1))
                )

                // Price
                HStack(spacing: 4) {
                    Image("icon_gold")
                        .resizable()
                        .frame(width: 16, height: 16)

                    Text("\(shopManager.getDisplayPrice(for: item))")
                        .font(.appFont(size: 14, weight: .black))
                        .foregroundColor(canAfford ? .yellow : .red)
                }
                .padding(.top, 4)
            }

            // Purchase button
            Button(action: {
                isPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                    onPurchase()
                }
            }) {
                Text(canAfford ? "Purchase" : "Not Enough Coins")
                    .font(.appFont(size: 14, weight: .black))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(canAfford ? Color.yellow : Color.gray)
                    )
            }
            .disabled(!canAfford)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.primaryColor)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Item Detail View

struct ItemDetailView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    @StateObject private var shopManager = ShopManager.shared
    let item: ShopItem
    let onPurchase: () -> Void
    @State private var isPressed = false

    var body: some View {
        let theme = themeManager.activeTheme

        NavigationView {
            VStack(spacing: 24) {
                // Item icon
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(theme.secondaryColor)
                        .frame(width: 120, height: 120)

                    Image(item.iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                }

                // Item details
                VStack(spacing: 16) {
                    Text(item.name)
                        .font(.appFont(size: 24, weight: .black))
                        .foregroundColor(theme.textColor)

                    Text(item.description)
                        .font(.appFont(size: 16))
                        .foregroundColor(theme.textColor.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    // Rarity and category
                    HStack(spacing: 20) {
                        VStack {
                            Text("Rarity")
                                .font(.appFont(size: 12, weight: .medium))
                                .foregroundColor(theme.textColor.opacity(0.6))
                            Text(item.rarity.rawValue)
                                .font(.appFont(size: 14, weight: .black))
                                .foregroundColor(theme.textColor)
                        }

                        VStack {
                            Text("Category")
                                .font(.appFont(size: 12, weight: .medium))
                                .foregroundColor(theme.textColor.opacity(0.6))
                            Text(item.category.rawValue)
                                .font(.appFont(size: 14, weight: .black))
                                .foregroundColor(theme.textColor)
                        }
                    }

                    // Price
                    HStack(spacing: 8) {
                        Image("icon_gold")
                            .resizable()
                            .frame(width: 24, height: 24)

                        Text("\(shopManager.getDisplayPrice(for: item))")
                            .font(.appFont(size: 20, weight: .black))
                            .foregroundColor(.yellow)
                    }
                    .padding(.top, 8)
                }

                Spacer()

                // Purchase button
                Button(action: {
                    isPressed = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isPressed = false
                        onPurchase()
                        dismiss()
                    }
                }) {
                    Text("Purchase for \(shopManager.getDisplayPrice(for: item)) Coins")
                        .font(.appFont(size: 18, weight: .black))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.yellow)
                        )
                }
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
                .padding(.horizontal)
            }
            .padding()
            .background(theme.backgroundColor.ignoresSafeArea())
            .navigationTitle("Item Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}
