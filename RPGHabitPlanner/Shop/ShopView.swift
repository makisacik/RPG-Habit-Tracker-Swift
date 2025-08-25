//
//  ShopView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 17.11.2024.
//

import SwiftUI

struct ShopView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var viewModel: ShopViewModel

    init(initialCategory: EnhancedShopCategory? = nil, initialArmorSubcategory: ArmorSubcategory? = nil) {
        self._viewModel = StateObject(wrappedValue: ShopViewModel(
            initialCategory: initialCategory,
            initialArmorSubcategory: initialArmorSubcategory
        ))
    }

    var body: some View {
        let theme = themeManager.activeTheme

        ZStack {
            theme.backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with currency
                ShopHeaderView(
                    theme: theme,
                    currentCoins: CurrencyManager.shared.currentCoins,
                    currentGems: CurrencyManager.shared.currentGems
                )

                // Enhanced category picker
                ShopCategoryView(
                    selectedCategory: $viewModel.selectedCategory
                ) { category in
                    viewModel.selectedCategory = category
                    // Preload images for the new category
                    viewModel.preloadImagesForCategory(category)
                }
                .padding(.vertical, 8)

                // Subcategory picker for armor
                if viewModel.selectedCategory == .armor {
                    ArmorSubcategoryView(
                        selectedSubcategory: $viewModel.selectedArmorSubcategory
                    ) { subcategory in
                        viewModel.selectedArmorSubcategory = subcategory
                        viewModel.updateCachedItems()
                    }
                    .padding(.vertical, 4)
                }

                // Subcategory picker for consumables
                if viewModel.selectedCategory == .consumables {
                    ConsumableSubcategoryView(
                        selectedSubcategory: $viewModel.selectedConsumableSubcategory
                    ) { subcategory in
                        viewModel.selectedConsumableSubcategory = subcategory
                        viewModel.updateCachedItems()
                    }
                    .padding(.vertical, 4)
                }

                // Filters
                ShopFilterView(
                    selectedRarity: $viewModel.selectedRarity,
                    priceRange: .constant(0...1000),
                    showOnlyAffordable: $viewModel.showOnlyAffordable,
                    selectedCategory: viewModel.selectedCategory
                ) {
                    // Filter logic handled in itemsGrid
                }

                // Enhanced items grid
                ShopItemsGridView(
                    theme: theme,
                    items: viewModel.cachedItems,
                    selectedCategory: viewModel.selectedCategory,
                    onPurchase: { item in
                        viewModel.purchaseItem(item)
                    },
                    onPreview: { item in
                        viewModel.selectedItem = item
                        viewModel.showItemPreview = true
                    }
                )
            }
        }
        .navigationTitle(String(localized: "shop"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            setupInitialState()
            viewModel.loadCurrentCurrency()
        }
        .onChange(of: viewModel.selectedCategory) { _ in
            viewModel.updateCachedItems()
            // Preload images for the new category
            viewModel.preloadImagesForCategory(viewModel.selectedCategory)
        }
        .onChange(of: viewModel.selectedRarity) { _ in
            viewModel.updateCachedItems()
        }
        .onChange(of: viewModel.showOnlyAffordable) { _ in
            viewModel.updateCachedItems()
        }
        .alert("Purchase", isPresented: $viewModel.showPurchaseAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.purchaseAlertMessage)
        }
        .overlay {
            if viewModel.showItemPreview, let item = viewModel.selectedItem {
                ItemPreviewModal(
                    item: item,
                    onDismiss: { viewModel.showItemPreview = false },
                    onPurchase: { viewModel.purchaseItem(item) }
                )
                .environmentObject(themeManager)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func setupInitialState() {
        viewModel.loadCurrentCurrency()
        viewModel.refreshInventory()
        
        // Set the initial values if provided
        if let initialCategory = viewModel.initialCategory {
            viewModel.selectedCategory = initialCategory
        }
        
        if let initialArmorSubcategory = viewModel.initialArmorSubcategory {
            viewModel.selectedArmorSubcategory = initialArmorSubcategory
        }
        
        // Preload images for the current category
        viewModel.preloadImagesForCategory(viewModel.selectedCategory)
        // Initialize cache
        viewModel.updateCachedItems()
    }
}
