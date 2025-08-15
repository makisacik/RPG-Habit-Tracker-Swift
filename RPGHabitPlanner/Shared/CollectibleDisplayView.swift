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
    @State private var selectedItem: Item?
    @State private var showAddItemSheet = false
    
    private let maxDisplaySlots = 3
    
    var collectibleItems: [Item] {
        inventoryManager.inventoryItems.compactMap { itemEntity in
            inventoryManager.getItemFromEntity(itemEntity)
        }.filter { $0.itemType == .collectible }
    }
    
    var displayedItems: [Item] {
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
                        let item = displayedItems[index]
                        CollectibleItemCard(
                            item: item
                        ) {
                            // Present sheet tied to item so first frame has content
                            selectedItem = item
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
        // Present only when selectedItem is non-nil (prevents blank first frame)
        .sheet(item: $selectedItem) { item in
            CollectibleItemDetailView(item: item)
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
    let item: Item
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
                    Image(item.iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .blur(radius: 8)
                        .opacity(0.6)
                        .foregroundColor(item.rarity.uiColor)
                    
                    // Main icon
                    Image(item.iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(theme.textColor)
                }
                .frame(width: 60, height: 60)
                
                // Item name
                Text(item.name)
                    .font(.appFont(size: 12, weight: .black))
                    .foregroundColor(theme.textColor)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                // Rarity indicator - show star for all collectible items
                if item.itemType == .collectible {
                    Image(systemName: "star.fill")
                        .font(.system(size: 8))
                        .foregroundColor(item.rarity.uiColor)
                }
            }
            .frame(width: 80, height: 100)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.secondaryColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(item.rarity.uiColor.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
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

// MARK: - Collectible Item Detail View

struct CollectibleItemDetailView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    let item: Item
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        ZStack {
            theme.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header with close button
                HStack {
                    Text("Item Details")
                        .font(.appFont(size: 18, weight: .black))
                        .foregroundColor(theme.textColor)
                    
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(theme.textColor.opacity(0.6))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Item icon
                Image(item.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(theme.textColor)
                    .shadow(radius: 4)
                
                // Item details
                VStack(spacing: 12) {
                    Text(item.name)
                        .font(.appFont(size: 20, weight: .black))
                        .foregroundColor(theme.textColor)
                        .multilineTextAlignment(.center)
                    
                    Text(item.description)
                        .font(.appFont(size: 14, weight: .medium))
                        .foregroundColor(theme.textColor.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    // Item type badge
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.yellow)
                        Text("Collectible")
                            .font(.appFont(size: 12, weight: .black))
                            .foregroundColor(.yellow)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.yellow.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.yellow, lineWidth: 1)
                            )
                    )
                }
                
                Spacer(minLength: 0)
            }
        }
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
    
    private var userCollectibleItems: [Item] {
        // Get collectible items from user's existing inventory
        return inventoryManager.inventoryItems.compactMap { itemEntity in
            inventoryManager.getItemFromEntity(itemEntity)
        }.filter { $0.itemType == .collectible }
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
                            ForEach(userCollectibleItems, id: \.id) { item in
                                Button(action: {
                                    selectedItemName = item.name
                                    selectedItemInfo = item.description
                                    selectedItemIcon = item.iconName
                                }) {
                                    VStack(spacing: 8) {
                                        Image(item.iconName)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(theme.textColor)
                                        
                                        Text(item.name)
                                            .font(.appFont(size: 12, weight: .black))
                                            .foregroundColor(theme.textColor)
                                            .lineLimit(2)
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(width: 80, height: 80)
                                    .padding(8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selectedItemName == item.name ? Color.yellow.opacity(0.3) : theme.secondaryColor)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(selectedItemName == item.name ? Color.yellow : Color.yellow.opacity(0.3), lineWidth: selectedItemName == item.name ? 2 : 1)
                                            )
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        
                        // Select button
                        if !selectedItemName.isEmpty {
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
