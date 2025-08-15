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
    @State private var selectedCategory: ShopCategory = .weapons
    @State private var showPurchaseAlert = false
    @State private var purchaseAlertMessage = ""
    @State private var selectedItem: ShopItem?
    @State private var showItemDetails = false
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        ZStack {
            theme.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with coins
                shopHeader(theme: theme)
                
                // Category picker
                categoryPicker(theme: theme)
                
                // Items grid
                itemsGrid(theme: theme)
            }
        }
        .navigationTitle("Shop")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadCurrentCoins()
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
    
    // MARK: - Category Picker
    
    private func categoryPicker(theme: Theme) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ShopCategory.allCases, id: \.self) { category in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedCategory = category
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: category.icon)
                                .font(.system(size: 16))
                            
                            Text(category.rawValue)
                                .font(.appFont(size: 14, weight: .medium))
                        }
                        .foregroundColor(selectedCategory == category ? .white : theme.textColor)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(selectedCategory == category ? Color.yellow : theme.secondaryColor)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Items Grid
    
    private func itemsGrid(theme: Theme) -> some View {
        let items = shopManager.getItemsByCategory(selectedCategory)
        
        return ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ForEach(items) { item in
                    ShopItemCard(
                        item: item,
                        canAfford: currencyManager.currentCoins >= item.price,
                        onTap: {
                            selectedItem = item
                            showItemDetails = true
                        },
                        onPurchase: {
                            purchaseItem(item)
                        }
                    )
                    .environmentObject(themeManager)
                }
            }
            .padding()
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
}

// MARK: - Shop Item Card

struct ShopItemCard: View {
    @EnvironmentObject var themeManager: ThemeManager
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
                Text(item.name)
                    .font(.appFont(size: 16, weight: .black))
                    .foregroundColor(theme.textColor)
                    .multilineTextAlignment(.center)
                
                Text(item.description)
                    .font(.appFont(size: 12))
                    .foregroundColor(theme.textColor.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                // Price
                HStack(spacing: 4) {
                    Image("icon_gold")
                        .resizable()
                        .frame(width: 16, height: 16)
                    
                    Text("\(item.price)")
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
                        
                        Text("\(item.price)")
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
                    Text("Purchase for \(item.price) Coins")
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
