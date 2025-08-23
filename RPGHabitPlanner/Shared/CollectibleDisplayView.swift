//
//  CollectibleDisplayView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI

struct CollectibleDisplayView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var inventoryManager: InventoryManager
    @State private var selectedItemEntity: ItemEntity?
    @State private var showAddItemSheet = false

    private let maxDisplaySlots = 3

    var collectibleItems: [ItemEntity] {
        inventoryManager.inventoryItems.filter { itemEntity in
            guard let name = itemEntity.name else { return false }
            // Filter for collectible items (not health potions, XP boosts, or coin boosts)
            return !name.contains("Health Potion") &&
                   !name.contains("XP Boost") &&
                   !name.contains("Coin Boost") &&
                   !name.contains("Potion")
        }
    }

    var displayedItems: [ItemEntity] {
        Array(collectibleItems.prefix(maxDisplaySlots))
    }

    var body: some View {
        let theme = themeManager.activeTheme

        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundColor(.yellow)
                    .font(.title2)

                Text("Collectibles")
                    .font(.appFont(size: 20, weight: .black))
                    .foregroundColor(theme.textColor)

                Spacer()

                // Add item button
                Button(action: {
                    showAddItemSheet = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.yellow)
                        .font(.title2)
                }
            }
            .padding(.horizontal)

            // Collectible items grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                ForEach(0..<maxDisplaySlots, id: \.self) { index in
                    if index < displayedItems.count {
                        let itemEntity = displayedItems[index]
                        CollectibleItemCard(
                            itemEntity: itemEntity
                        ) {
                            // Present sheet tied to item so first frame has content
                            selectedItemEntity = itemEntity
                        }
                    } else {
                        EmptyCollectibleSlot()
                    }
                }
            }
            .padding(.horizontal)

            // Collection stats
            if !collectibleItems.isEmpty {
                HStack {
                    Text("Collection: \(collectibleItems.count) items")
                        .font(.appFont(size: 14, weight: .medium))
                        .foregroundColor(theme.textColor.opacity(0.8))

                    Spacer()

                    Text("Display: \(displayedItems.count)/\(maxDisplaySlots)")
                        .font(.appFont(size: 14, weight: .medium))
                        .foregroundColor(theme.textColor.opacity(0.8))
                }
                .padding(.horizontal)
            }
        }
        // Present only when selectedItemEntity is non-nil (prevents blank first frame)
        .sheet(item: $selectedItemEntity) { itemEntity in
            UnifiedItemDetailView(item: itemEntity)
                .environmentObject(inventoryManager)
                .environmentObject(themeManager)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showAddItemSheet) {
            AddCollectibleItemView()
                .environmentObject(inventoryManager)
                .environmentObject(themeManager)
        }
    }
}

// MARK: - Collectible Item Card

struct CollectibleItemCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let itemEntity: ItemEntity
    let onTap: () -> Void
    @State private var isPressed = false

    var body: some View {
        let theme = themeManager.activeTheme

        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            // Set selection immediately (no delay) to avoid empty sheet frame
            onTap()
            // Let the press effect relax after
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isPressed = false
            }
        }) {
            VStack(spacing: 8) {
                // Item icon with glow effect
                ZStack {
                    // Glow
                    Image(itemEntity.iconName ?? "")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .blur(radius: 8)
                        .opacity(0.6)
                        .foregroundColor(rarityColor)

                    // Main icon
                    Image(itemEntity.iconName ?? "")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(theme.textColor)
                }
                .frame(width: 60, height: 60)

                // Item name
                Text(itemEntity.name ?? "Unknown")
                    .font(.appFont(size: 12, weight: .black))
                    .foregroundColor(theme.textColor)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)

                // Rarity indicator - show star for all collectible items
                Image(systemName: "star.fill")
                    .font(.system(size: 8))
                    .foregroundColor(rarityColor)
            }
            .frame(width: 80, height: 100)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.secondaryColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(rarityColor.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var rarityColor: Color {
        guard let name = itemEntity.name else { return .gray }

        if name.contains("Legendary") || name.contains("Crown") || name.contains("Medal") {
            return .orange
        } else if name.contains("Epic") || name.contains("Gold") || name.contains("Sword Double") {
            return .purple
        } else if name.contains("Rare") || name.contains("Silver") || name.contains("Blue") {
            return .blue
        } else if name.contains("Uncommon") || name.contains("Green") {
            return .green
        } else {
            return .gray
        }
    }
}

// MARK: - Empty Collectible Slot

struct EmptyCollectibleSlot: View {
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        let theme = themeManager.activeTheme

        VStack(spacing: 8) {
            Image(systemName: "plus.circle")
                .font(.system(size: 30))
                .foregroundColor(theme.textColor.opacity(0.3))

            Text("Empty")
                .font(.appFont(size: 12, weight: .medium))
                .foregroundColor(theme.textColor.opacity(0.5))
        }
        .frame(width: 80, height: 100)
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.secondaryColor.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(theme.textColor.opacity(0.2), lineWidth: 1)
                )
        )
    }
}


// MARK: - Add Collectible Item View

struct AddCollectibleItemView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var inventoryManager: InventoryManager
    @Environment(\.dismiss) private var dismiss

    @State private var selectedItemName = ""
    @State private var selectedItemInfo = ""
    @State private var selectedItemIcon = ""

    private var userCollectibleItems: [ItemEntity] {
        // Get collectible items from user's existing inventory
        return inventoryManager.inventoryItems.filter { itemEntity in
            guard let name = itemEntity.name else { return false }
            // Filter for collectible items (not health potions, XP boosts, or coin boosts)
            return !name.contains("Health Potion") &&
                   !name.contains("XP Boost") &&
                   !name.contains("Coin Boost") &&
                   !name.contains("Potion")
        }
    }

    var body: some View {
        let theme = themeManager.activeTheme

        NavigationView {
            ZStack {
                theme.backgroundColor
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Text("Select Collectible")
                        .font(.appFont(size: 24, weight: .black))
                        .foregroundColor(theme.textColor)
                        .padding(.top)

                    if userCollectibleItems.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "tray")
                                .font(.system(size: 40))
                                .foregroundColor(theme.textColor.opacity(0.5))

                            Text("No Collectible Items")
                                .font(.appFont(size: 18, weight: .black))
                                .foregroundColor(theme.textColor)

                            Text("You don't have any collectible items in your inventory yet.")
                                .font(.appFont(size: 14, weight: .medium))
                                .foregroundColor(theme.textColor.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    } else {
                        // User's existing collectible items grid
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                            ForEach(userCollectibleItems, id: \.objectID) { itemEntity in
                                Button(action: {
                                    selectedItemName = itemEntity.name ?? ""
                                    selectedItemInfo = itemEntity.info ?? ""
                                    selectedItemIcon = itemEntity.iconName ?? ""
                                }) {
                                    VStack(spacing: 8) {
                                        Image(itemEntity.iconName ?? "")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(theme.textColor)

                                        Text(itemEntity.name ?? "Unknown")
                                            .font(.appFont(size: 12, weight: .black))
                                            .foregroundColor(theme.textColor)
                                            .lineLimit(2)
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(width: 80, height: 80)
                                    .padding(8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selectedItemIcon == itemEntity.iconName ? Color.yellow.opacity(0.3) : theme.secondaryColor)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(selectedItemIcon == itemEntity.iconName ? Color.yellow : Color.yellow.opacity(0.3), lineWidth: selectedItemIcon == itemEntity.iconName ? 2 : 1)
                                            )
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)

                        // Select button
                        if !selectedItemIcon.isEmpty {
                            Button(action: {
                                // The item is already in the user's inventory, so we just dismiss
                                dismiss()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title3)
                                    Text("Select Item")
                                        .font(.appFont(size: 16, weight: .black))
                                }
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 24)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.yellow)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }

                    Spacer()
                }
            }
            .navigationTitle("Select Collectible")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.yellow)
                }
            }
        }
    }
}
