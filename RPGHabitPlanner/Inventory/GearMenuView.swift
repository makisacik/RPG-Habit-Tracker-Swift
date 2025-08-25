//
//  GearMenuView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 5.08.2025.
//

import SwiftUI

struct GearMenuView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var inventoryManager: InventoryManager
    @Environment(\.dismiss) private var dismiss
    
    let gearCategory: GearCategory
    let user: UserEntity
    @State private var selectedItem: ItemEntity?
    @State private var showShop = false
    
    @StateObject private var gearManager = GearManager.shared
    private let customizationService = CharacterCustomizationService()
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        NavigationView {
            ZStack {
                theme.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    // Header
                    headerView(theme: theme)
                    
                    // Gear Items Grid
                    gearItemsGrid(theme: theme)
                    
                    Spacer()
                }
                .padding()
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showShop) {
            let (category, armorSubcategory) = mapGearCategoryToShopCategory(gearCategory)
            NavigationStack {
                ShopView(initialCategory: category, initialArmorSubcategory: armorSubcategory)
                    .environmentObject(themeManager)
            }
        }
    }
    
    // MARK: - Header View
    @ViewBuilder
    private func headerView(theme: Theme) -> some View {
        VStack(spacing: 12) {
            HStack {
                Button("close".localized) {
                    dismiss()
                }
                .font(.appFont(size: 16, weight: .medium))
                .foregroundColor(theme.textColor.opacity(0.7))
                
                Spacer()
                
                Text(gearCategory.rawValue.localized)
                    .font(.appFont(size: 20, weight: .bold))
                    .foregroundColor(theme.textColor)

                Spacer()
            }
            
            Text(gearCategory.description)
                .font(.appFont(size: 14))
                .foregroundColor(theme.textColor.opacity(0.7))
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Gear Items Grid
    @ViewBuilder
    private func gearItemsGrid(theme: Theme) -> some View {
        let gearItems = getGearItems()
        
        if gearItems.isEmpty {
            emptyStateView(theme: theme)
        } else {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 12) {
                    ForEach(gearItems, id: \.id) { item in
                        GearItemCard(
                            item: item,
                            isEquipped: isItemEquipped(item),
                            onTap: {
                                equipItem(item)
                            },
                            theme: theme
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Empty State View
    @ViewBuilder
    private func emptyStateView(theme: Theme) -> some View {
        VStack(spacing: 16) {
            if getEmptyStateIcon().hasPrefix("icon_") {
                Image(getEmptyStateIcon())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .foregroundColor(theme.textColor.opacity(0.3))
            } else {
                Image(systemName: getEmptyStateIcon())
                    .font(.system(size: 48))
                    .foregroundColor(theme.textColor.opacity(0.3))
            }
            
                            Text("no_items_for_category".localized.localized(with: gearCategory.rawValue.lowercased()))
                .font(.appFont(size: 16, weight: .medium))
                .foregroundColor(theme.textColor)
            
                            Text("visit_shop_to_get_items".localized.localized(with: gearCategory.rawValue.lowercased()))
                .font(.appFont(size: 14))
                .foregroundColor(theme.textColor.opacity(0.7))
                .multilineTextAlignment(.center)
            
            Button(action: {
                showShop = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "cart.fill")
                        .font(.system(size: 16))
                    Text("go_to_shop".localized)
                        .font(.appFont(size: 16, weight: .medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(theme.accentColor)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(40)
    }
    
    // MARK: - Helper Methods
    
    private func getGearItems() -> [ItemEntity] {
        return inventoryManager.inventoryItems.filter { item in
            guard inventoryManager.isGear(item) else { return false }
            
            // Check if the item matches the gear category
            if let gearCategoryString = item.gearCategory,
               let itemGearCategory = GearCategory(rawValue: gearCategoryString) {
                return itemGearCategory == gearCategory
            }
            
            // Fallback: check item name for category hints
            let itemName = item.name?.lowercased() ?? ""
            switch gearCategory {
            case .head:
                return itemName.contains("helmet") || itemName.contains("hat") || itemName.contains("crown")
            case .outfit:
                return itemName.contains("armor") || itemName.contains("robe") || itemName.contains("outfit")
            case .weapon:
                return itemName.contains("sword") || itemName.contains("axe") || itemName.contains("weapon")
            case .shield:
                return itemName.contains("shield") || itemName.contains("defense")
            case .wings:
                return itemName.contains("wing") || itemName.contains("feather")
            case .pet:
                return itemName.contains("pet") || itemName.contains("companion")
            }
        }
    }
    
    private func isItemEquipped(_ item: ItemEntity) -> Bool {
        return gearManager.isItemEquipped(item)
    }
    
    private func equipItem(_ item: ItemEntity) {
        gearManager.equipItem(item, to: gearCategory, for: user)
    }
    
    private func getCurrentCustomization() -> CharacterCustomization? {
        if let entity = customizationService.fetchCustomization(for: user) {
            return entity.toCharacterCustomization()
        }
        return nil
    }
    
    private func getEmptyStateIcon() -> String {
        switch gearCategory {
        case .head: return "icon_helmet"
        case .outfit: return "icon_armor"
        case .weapon: return "icon_sword"
        case .shield: return "icon_shield"
        case .wings: return "icon_wing"
        case .pet: return "pawprint.fill"
        }
    }
}

// MARK: - Gear Item Card
struct GearItemCard: View {
    let item: ItemEntity
    let isEquipped: Bool
    let onTap: () -> Void
    let theme: Theme
    @State private var showItemDetail = false
    
    var body: some View {
        Button(action: {
            onTap()
        }) {
            VStack(spacing: 8) {
                ZStack {
                    // Item background
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.surfaceColor.opacity(0.6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    isEquipped ? theme.accentColor : theme.borderColor.opacity(0.3),
                                    lineWidth: isEquipped ? 2 : 1
                                )
                        )
                    
                    // Item icon
                    if let iconName = item.previewImage ?? item.iconName {
                        Image(iconName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .padding(8)
                    } else {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 40))
                            .foregroundColor(theme.textColor.opacity(0.5))
                    }
                    
                    // Equipped indicator
                    if isEquipped {
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(theme.accentColor)
                                    .background(Circle().fill(Color.white))
                                    .offset(x: 4, y: -4)
                            }
                            Spacer()
                        }
                    }
                }
                .frame(height: 80)
                .padding(4)
                
                // Item name
                Text(item.name ?? "unknown".localized)
                    .font(.appFont(size: 12, weight: .medium))
                    .foregroundColor(theme.textColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                // Rarity indicator
                if let rarity = getRarity() {
                    HStack {
                        Circle()
                            .fill(rarity.uiColor)
                            .frame(width: 8, height: 8)
                        Text(rarity.rawValue.localized)
                            .font(.appFont(size: 10))
                            .foregroundColor(theme.textColor.opacity(0.7))
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showItemDetail) {
            if let itemDefinition = getItemDefinition() {
                ItemDetailSheet(item: itemDefinition)
                    .environmentObject(ThemeManager.shared)
                    .environmentObject(InventoryManager.shared)
                    .presentationDetents([.medium])
            }
        }
        .contextMenu {
                                Button("view_details".localized) {
                showItemDetail = true
                                }
            
                            Button("equip".localized) {
                onTap()
                            }
            .disabled(isEquipped)
        }
    }
    
    private func getRarity() -> ItemRarity? {
        guard let rarityString = item.rarity else { return nil }
        return ItemRarity(rawValue: rarityString)
    }

    private func getItemDefinition() -> Item? {
        guard let iconName = item.iconName else { return nil }
        return ItemDatabase.shared.findItem(byIconName: iconName)
    }
}

#Preview {
    GearMenuView(gearCategory: .weapon, user: UserEntity())
        .environmentObject(ThemeManager.shared)
        .environmentObject(InventoryManager.shared)
}

// MARK: - Helper Functions

/// Maps GearCategory to EnhancedShopCategory and ArmorSubcategory for navigation
private func mapGearCategoryToShopCategory(_ gearCategory: GearCategory) -> (EnhancedShopCategory, ArmorSubcategory) {
    print("🎯 GearMenuView: Mapping gear category \(gearCategory.rawValue)")
    let result: (EnhancedShopCategory, ArmorSubcategory)
    
    switch gearCategory {
    case .head:
        result = (.armor, .helmet)
    case .outfit:
        result = (.armor, .outfit)
    case .weapon:
        result = (.weapons, .helmet) // Default armor subcategory, won't be used
    case .shield:
        result = (.armor, .shield)
    case .wings:
        result = (.wings, .helmet) // Default armor subcategory, won't be used
    case .pet:
        result = (.pets, .helmet) // Default armor subcategory, won't be used
    }
    
    print("🎯 GearMenuView: Mapped to shop category: \(result.0.rawValue), armor subcategory: \(result.1.rawValue)")
    return result
}
