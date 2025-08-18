//
//  UnifiedItemDetailView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI

struct UnifiedItemDetailView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var inventoryManager: InventoryManager
    @Environment(\.dismiss) private var dismiss
    let item: ItemEntity
    @State private var isUsingItem = false
    
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
                if let iconName = item.iconName {
                    if iconName.contains("potion_health") {
                        let rarity = getPotionRarity(from: iconName)
                        HealthPotionIconView(rarity: rarity, size: 80)
                    } else {
                        Image(iconName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(theme.textColor)
                            .shadow(radius: 4)
                    }
                }
                
                // Item details
                VStack(spacing: 12) {
                    Text(item.name ?? "Unknown")
                        .font(.appFont(size: 20, weight: .black))
                        .foregroundColor(theme.textColor)
                        .multilineTextAlignment(.center)
                    
                    Text(item.info ?? "No description available")
                        .font(.appFont(size: 14, weight: .medium))
                        .foregroundColor(theme.textColor.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    // Item type badge
                    HStack {
                        Image(systemName: itemTypeIcon)
                            .foregroundColor(itemTypeColor)
                        Text(itemTypeText)
                            .font(.appFont(size: 12, weight: .black))
                            .foregroundColor(itemTypeColor)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(itemTypeColor.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(itemTypeColor, lineWidth: 1)
                            )
                    )
                }
                
                // Use button for consumable or booster items
                if inventoryManager.isConsumable(item) || inventoryManager.isBooster(item) {
                    Button(action: {
                        useItem()
                    }) {
                        HStack {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 16))
                            Text("Use")
                                .font(.appFont(size: 16, weight: .black))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(theme.accentColor)
                        )
                    }
                    .disabled(isUsingItem)
                    .opacity(isUsingItem ? 0.6 : 1.0)
                }
                
                Spacer(minLength: 0)
            }
        }
    }
    
    private var itemTypeIcon: String {
        if inventoryManager.isConsumable(item) {
            return "drop.fill"
        } else if inventoryManager.isBooster(item) {
            return "bolt.fill"
        } else {
            return "trophy.fill"
        }
    }
    
    private var itemTypeColor: Color {
        if inventoryManager.isConsumable(item) {
            return .red
        } else if inventoryManager.isBooster(item) {
            return .blue
        } else {
            return .yellow
        }
    }
    
    private var itemTypeText: String {
        if inventoryManager.isConsumable(item) {
            return "Consumable"
        } else if inventoryManager.isBooster(item) {
            return "Booster"
        } else {
            return "Collectible"
        }
    }
    
    private func useItem() {
        isUsingItem = true
        
        inventoryManager.useItem(item) { success, error in
            DispatchQueue.main.async {
                isUsingItem = false
                
                if success {
                    dismiss()
                } else {
                    // Handle error - could show an alert here
                    print("Failed to use item: \(error?.localizedDescription ?? "Unknown error")")
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
