//
//  ShopItemsGridView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 24.08.2025.
//

import SwiftUI

struct ShopItemsGridView: View {
    let theme: Theme
    let items: [ShopItem]
    let selectedCategory: EnhancedShopCategory
    let onPurchase: (ShopItem) -> Void
    let onPreview: ((ShopItem) -> Void)?
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(items) { item in
                    EnhancedShopItemCard(
                        item: item,
                        selectedCategory: selectedCategory,
                        isCustomizationItem: selectedCategory.isCustomizationCategory || selectedCategory.assetCategory != nil || selectedCategory == .consumables,
                        onPurchase: {
                            onPurchase(item)
                        },
                        onPreview: (selectedCategory.isCustomizationCategory || selectedCategory.assetCategory != nil || selectedCategory == .consumables) ? {
                            onPreview?(item)
                        } : nil
                    )
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }
}
