//
//  InventoryGridComponents.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI
import CoreData

// MARK: - Inventory Grid Item View
struct InventoryGridItemView: View {
    let item: ItemEntity
    let theme: Theme
    @State private var showItemDetail = false
    @StateObject private var gearManager = GearManager.shared
    @State private var refreshTrigger = false

    var body: some View {
        Button(action: {
            showItemDetail = true
        }) {
            VStack(spacing: 4) {
                // Item Icon Container
                ZStack {
                    // Slot background
                    RoundedRectangle(cornerRadius: 6)
                        .fill(theme.secondaryColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(theme.borderColor.opacity(0.6), lineWidth: 1.5)
                        )

                    // Item icon
                    if let previewImage = item.previewImage, !previewImage.isEmpty {
                        if UIImage(named: previewImage) != nil {
                            Image(previewImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                                .padding(6)
                        } else if let iconName = item.iconName, !iconName.isEmpty, UIImage(named: iconName) != nil {
                            Image(iconName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                                .padding(6)
                        } else {
                            Image(systemName: "questionmark.circle")
                                .font(.system(size: 28))
                                .foregroundColor(theme.textColor.opacity(0.5))
                        }
                    } else if let iconName = item.iconName, !iconName.isEmpty, UIImage(named: iconName) != nil {
                        Image(iconName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .padding(6)
                    } else {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 28))
                            .foregroundColor(theme.textColor.opacity(0.5))
                    }

                    // Rarity indicator for gear items
                    if let rarity = getItemRarity() {
                        VStack {
                            HStack {
                                Spacer()
                                Circle()
                                    .fill(rarity.uiColor)
                                    .frame(width: 6, height: 6)
                                    .offset(x: 2, y: -2)
                            }
                            Spacer()
                        }
                    }

                    // Equipped indicator for gear items
                    if isGearItem && gearManager.isItemEquipped(item) {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.green)
                                    .background(
                                        Circle()
                                            .fill(.white)
                                            .frame(width: 14, height: 14)
                                    )
                                    .offset(x: 2, y: -2)
                            }
                        }
                    }
                }
                .frame(width: 52, height: 52)

                // Item Name
                Text(item.localizedName)
                    .font(.appFont(size: 10, weight: .medium))
                    .foregroundColor(theme.textColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .frame(height: 22)
            }
            .frame(width: 70, height: 80)
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
        .onReceive(NotificationCenter.default.publisher(for: .languageChanged)) { _ in
            // Trigger a refresh when language changes
            refreshTrigger.toggle()
        }
    }

    private var isGearItem: Bool {
        guard let iconName = item.iconName else { return false }
        let itemDefinition = ItemDatabase.findItem(byIconName: iconName)
        return itemDefinition?.itemType == .gear
    }

    private func getItemRarity() -> ItemRarity? {
        if let rarityString = item.rarity {
            return ItemRarity(rawValue: rarityString)
        }

        // Fallback to database lookup
        guard let iconName = item.iconName else { return nil }
        let itemDefinition = ItemDatabase.findItem(byIconName: iconName)
        return itemDefinition?.rarity ?? getRarityFromEntity()
    }

    private func getItemDefinition() -> Item? {
        guard let iconName = item.iconName else { return nil }

        // First try to find the item in the database
        if let databaseItem = ItemDatabase.findItem(byIconName: iconName) {
            return databaseItem
        }

        // If not found in database, create a dynamic item definition from ItemEntity data
        // This handles shop-bought items that aren't in the static database
        let itemType = getItemTypeFromEntity()
        let gearCategory = getGearCategoryFromEntity()
        let rarity = getRarityFromEntity()

        return Item(
            name: item.name ?? "Unknown Item",
            description: item.info ?? "No description available",
            iconName: iconName,
            previewImage: item.previewImage ?? iconName,
            itemType: itemType,
            value: Int(item.value),
            collectionCategory: item.collectionCategory,
            isRare: item.isRare,
            gearCategory: gearCategory,
            rarity: rarity
        )
    }

    private func getItemTypeFromEntity() -> ItemType {
        if let itemTypeString = item.itemType {
            return ItemType(rawValue: itemTypeString) ?? .collectible
        }

        // Fallback logic based on gear category
        if getGearCategoryFromEntity() != nil {
            return .gear
        }

        return .collectible
    }

    private func getGearCategoryFromEntity() -> GearCategory? {
        if let gearCategoryString = item.gearCategory {
            return GearCategory(rawValue: gearCategoryString)
        }

        // Fallback: try to determine from icon name
        let iconName = item.iconName ?? ""
        if iconName.contains("outfit") {
            return .outfit
        } else if iconName.contains("sword") || iconName.contains("weapon") {
            return .weapon
        } else if iconName.contains("shield") {
            return .shield
        } else if iconName.contains("head") || iconName.contains("helmet") {
            return .head
        } else if iconName.contains("wings") {
            return .wings
        } else if iconName.contains("pet") {
            return .pet
        }

        return nil
    }

    private func getRarityFromEntity() -> ItemRarity? {
        if let rarityString = item.rarity {
            return ItemRarity(rawValue: rarityString)
        }

        // Fallback: determine rarity from item value or other properties
        if item.isRare {
            return .rare
        }

        return .common
    }
}

// MARK: - Empty Inventory Slot View
struct EmptyInventorySlotView: View {
    let theme: Theme

    var body: some View {
        VStack(spacing: 4) {
            // Empty slot background
            RoundedRectangle(cornerRadius: 6)
                .fill(theme.secondaryColor.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(theme.borderColor.opacity(0.4), lineWidth: 1)
                )
                .frame(width: 52, height: 52)

            // Empty space for text
            Rectangle()
                .fill(Color.clear)
                .frame(height: 22)
        }
        .frame(width: 70, height: 80)
    }
}
