//
//  InventoryGridComponents.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI

// MARK: - Inventory Grid Item View
struct InventoryGridItemView: View {
    let item: ItemEntity
    let theme: Theme
    @State private var showItemDetail = false
    @StateObject private var gearManager = GearManager.shared

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
                Text(item.name ?? "Unknown")
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
            ItemDetailSheet(item: item)
                .environmentObject(ThemeManager.shared)
                .environmentObject(InventoryManager.shared)
                .presentationDetents([.medium])
        }
    }

    private var isGearItem: Bool {
        guard let iconName = item.iconName else { return false }
        let itemDefinition = ItemDatabase.shared.findItem(byIconName: iconName)
        return itemDefinition?.itemType == .gear
    }

    private func getItemRarity() -> ItemRarity? {
        if let rarityString = item.rarity {
            return ItemRarity(rawValue: rarityString)
        }

        // Fallback to database lookup
        guard let iconName = item.iconName else { return nil }
        let itemDefinition = ItemDatabase.shared.findItem(byIconName: iconName)
        return itemDefinition?.rarity
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
