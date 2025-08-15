//
//  InventoryView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 5.08.2025.
//

import SwiftUI

struct InventoryView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var healthManager = HealthManager.shared
    @State private var items: [ItemEntity] = []
    @State private var selectedItem: ItemEntity?
    @State private var showUsePotionAlert = false
    @State private var potionToUse: ItemEntity?
    
    private let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 6), count: 6)
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        ZStack {
            theme.backgroundColor
                .ignoresSafeArea()
                .onTapGesture {
                    selectedItem = nil
                }
            
            VStack(spacing: 10) {
                Text(String.inventory.localized)
                    .font(.appFont(size: 22, weight: .black))
                    .foregroundColor(theme.textColor)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 14)
                    .background(RoundedRectangle(cornerRadius: 6).fill(Color.purple.opacity(0.8)))
                
                LazyVGrid(columns: columns, spacing: 6) {
                    ForEach(0..<18, id: \.self) { index in
                        let item = index < items.count ? items[index] : nil
                        InventorySlotView(iconName: item?.iconName)
                            .onTapGesture {
                                if let item = item {
                                    withAnimation(.easeInOut) {
                                        selectedItem = item
                                    }
                                } else {
                                    selectedItem = nil
                                }
                            }
                            .onLongPressGesture {
                                if let item = item, InventoryManager.shared.isHealthPotion(item) {
                                    potionToUse = item
                                    showUsePotionAlert = true
                                }
                            }
                            .overlay(
                                InfoBubbleView(item: item, selectedItem: selectedItem)
                                    .environmentObject(themeManager)
                            )
                    }
                }
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.purple.opacity(0.6)))
            }
            .padding()
        }
                        .navigationTitle(String.inventory.localized)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            items = InventoryManager.shared.fetchInventory()
            
            // Add starter health potions if inventory is empty (for testing)
            if items.isEmpty {
                InventoryManager.shared.addStarterHealthPotions()
                items = InventoryManager.shared.fetchInventory()
            }
        }
        .alert("Use Health Potion", isPresented: $showUsePotionAlert) {
            Button("Use") {
                if let potion = potionToUse {
                    InventoryManager.shared.useHealthPotion(potion) { success, _ in
                        if success {
                            // Refresh inventory
                            items = InventoryManager.shared.fetchInventory()
                            selectedItem = nil
                        }
                    }
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            if let potion = potionToUse {
                let healthPotion = InventoryManager.shared.getHealthPotionFromItem(potion)
                Text("Use \(potion.name ?? "Health Potion") to restore \(healthPotion?.displayHealAmount ?? "health")?")
            }
        }
    }
    
    struct InfoBubbleView: View {
        @EnvironmentObject var themeManager: ThemeManager
        var item: ItemEntity?
        var selectedItem: ItemEntity?

        var body: some View {
            let theme = themeManager.activeTheme
            if let selectedItem = selectedItem,
               let current = item,
               current == selectedItem {
                VStack(alignment: .center, spacing: 4) {
                    Text(current.name ?? String.unknown.localized)
                        .font(.appFont(size: 14, weight: .black))
                        .foregroundColor(theme.textColor)
                        .multilineTextAlignment(.center)

                    Text(current.info ?? "")
                        .font(.appFont(size: 12))
                        .foregroundColor(theme.textColor.opacity(0.9))
                        .multilineTextAlignment(.center)
                    
                    // Show health potion info if applicable
                    if InventoryManager.shared.isHealthPotion(current),
                       let healthPotion = InventoryManager.shared.getHealthPotionFromItem(current) {
                        HStack(spacing: 4) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.red)
                            Text(healthPotion.displayHealAmount)
                                .font(.appFont(size: 10, weight: .black))
                                .foregroundColor(.red)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.red.opacity(0.2))
                        )
                    }
                }
                .padding(10)
                .frame(minWidth: 120, maxWidth: 180)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.yellow.opacity(0.9))
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                )
                .fixedSize(horizontal: false, vertical: true)
                .offset(y: -70)
                .transition(.scale.combined(with: .opacity))
            }
        }
    }


struct InventorySlotView: View {
    let iconName: String?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .strokeBorder(Color.white.opacity(0.4), lineWidth: 1.5)
                .background(RoundedRectangle(cornerRadius: 4).fill(Color.purple.opacity(0.3)))
                .aspectRatio(1, contentMode: .fit)
            
            if let iconName = iconName {
                if iconName.contains("potion_health") {
                    // Use custom health potion icon
                    let rarity = getPotionRarity(from: iconName)
                    HealthPotionIconView(rarity: rarity, size: 20)
                } else {
                    Image(iconName)
                        .resizable()
                        .scaledToFit()
                        .padding(6)
                }
            }
        }
    }
    
    private func getPotionRarity(from iconName: String) -> ItemRarity {
        if iconName.contains("legendary") {
            return .legendary
        } else if iconName.contains("superior") {
            return .epic
        } else if iconName.contains("greater") {
            return .rare
        } else if iconName.contains("health") && !iconName.contains("minor") {
            return .uncommon
        } else {
            return .common
        }
    }
}
}
