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
    @StateObject private var inventoryManager = InventoryManager.shared
    @State private var selectedItem: ItemEntity?
    @State private var showUseItemAlert = false
    @State private var itemToUse: ItemEntity?
    @State private var showActiveEffects = false

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
                // Header with active effects indicator
                HStack {
                    Text(String.inventory.localized)
                        .font(.appFont(size: 22, weight: .black))
                        .foregroundColor(theme.textColor)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 14)
                        .background(RoundedRectangle(cornerRadius: 6).fill(Color.purple.opacity(0.8)))

                    Spacer()

                    // Active effects button
                    if !inventoryManager.activeEffects.isEmpty {
                        Button(action: {
                            showActiveEffects.toggle()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 12))
                                Text("\(inventoryManager.activeEffects.count)")
                                    .font(.appFont(size: 12, weight: .black))
                            }
                            .foregroundColor(.yellow)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.yellow.opacity(0.2))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.yellow, lineWidth: 1)
                                    )
                            )
                        }
                    }
                }

                // Active effects overlay
                if showActiveEffects && !inventoryManager.activeEffects.isEmpty {
                    ActiveEffectsView(activeEffects: inventoryManager.activeEffects)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                LazyVGrid(columns: columns, spacing: 6) {
                    ForEach(0..<18, id: \.self) { index in
                        let item = index < inventoryManager.inventoryItems.count ? inventoryManager.inventoryItems[index] : nil
                        InventorySlotView(
                            item: item,
                            isSelected: selectedItem == item,
                            onTap: {
                                if let item = item {
                                    withAnimation(.easeInOut) {
                                        selectedItem = item
                                    }
                                } else {
                                    selectedItem = nil
                                }
                            },
                            onLongPress: {
                                if let item = item, inventoryManager.isFunctionalItem(item) {
                                    itemToUse = item
                                    showUseItemAlert = true
                                }
                            }
                        )
                        .environmentObject(themeManager)
                        .environmentObject(inventoryManager)
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
            inventoryManager.refreshInventory()

            // Add starter items if inventory is empty (for testing)
            if inventoryManager.inventoryItems.isEmpty {
                inventoryManager.addStarterHealthPotions()
                inventoryManager.addStarterXPBoosts()
            }
        }
        .alert("Use Item", isPresented: $showUseItemAlert) {
            Button("Use") {
                if let item = itemToUse {
                    inventoryManager.useFunctionalItem(item) { success, _ in
                        if success {
                            selectedItem = nil
                        }
                    }
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            if let item = itemToUse {
                Text("Use \(item.name ?? "Item")?")
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showActiveEffects)
    }
}

// MARK: - Active Effects View

struct ActiveEffectsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let activeEffects: [ActiveEffect]

    var body: some View {
        let theme = themeManager.activeTheme
        VStack(spacing: 8) {
            Text("Active Effects")
                .font(.appFont(size: 16, weight: .black))
                .foregroundColor(theme.textColor)

            ForEach(activeEffects) { effect in
                ActiveEffectRow(effect: effect)
                    .environmentObject(themeManager)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.secondaryColor)
                .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)
        )
        .padding(.horizontal)
    }
}

struct ActiveEffectRow: View {
    @EnvironmentObject var themeManager: ThemeManager
    let effect: ActiveEffect
    @State private var remainingTime: TimeInterval = 0

    var body: some View {
        let theme = themeManager.activeTheme
        HStack(spacing: 8) {
            // Effect icon
            Image(systemName: effect.effect.type.icon)
                .font(.system(size: 16))
                .foregroundColor(.yellow)
                .frame(width: 20)

            // Effect name and value
            VStack(alignment: .leading, spacing: 2) {
                Text(effect.effect.type.rawValue)
                    .font(.appFont(size: 12, weight: .black))
                    .foregroundColor(theme.textColor)

                Text(effect.effect.displayValue)
                    .font(.appFont(size: 10, weight: .medium))
                    .foregroundColor(theme.textColor.opacity(0.8))
            }

            Spacer()

            // Countdown timer
            if let remaining = effect.remainingTime {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(formatTime(remaining))
                        .font(.appFont(size: 10, weight: .black))
                        .foregroundColor(.yellow)

                    // Progress bar
                    ProgressView(value: effect.progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .yellow))
                        .frame(width: 40, height: 4)
                }
            }
        }
        .padding(.vertical, 4)
        .onAppear {
            updateRemainingTime()
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            updateRemainingTime()
        }
    }

    private func updateRemainingTime() {
        remainingTime = effect.remainingTime ?? 0
    }

    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Enhanced Inventory Slot View

struct InventorySlotView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var inventoryManager: InventoryManager
    let item: ItemEntity?
    let isSelected: Bool
    let onTap: () -> Void
    let onLongPress: () -> Void

    var body: some View {
        let theme = themeManager.activeTheme
        ZStack {
            // Slot background
            RoundedRectangle(cornerRadius: 4)
                .strokeBorder(
                    isSelected ? Color.yellow : Color.white.opacity(0.4),
                    lineWidth: isSelected ? 2 : 1.5
                )
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.purple.opacity(0.3))
                )
                .aspectRatio(1, contentMode: .fit)

            if let item = item {
                // Item icon
                VStack(spacing: 2) {
                    if item.iconName?.contains("potion_health") == true {
                        // Use custom health potion icon
                        let rarity = getPotionRarity(from: item.iconName ?? "")
                        HealthPotionIconView(rarity: rarity, size: 20)
                    } else {
                        Image(item.iconName ?? "")
                            .resizable()
                            .scaledToFit()
                            .padding(6)
                    }

                    // Item type indicator
                    if inventoryManager.isFunctionalItem(item) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 8))
                            .foregroundColor(.yellow)
                    } else {
                        Image(systemName: "star.fill")
                            .font(.system(size: 8))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }

                // XP Boost indicator
                if inventoryManager.isXPBoost(item) {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.green)
                                .background(Circle().fill(Color.white))
                        }
                        Spacer()
                    }
                    .padding(2)
                }
            }
        }
        .onTapGesture {
            onTap()
        }
        .onLongPressGesture {
            onLongPress()
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

// MARK: - Enhanced Info Bubble View

struct InfoBubbleView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var inventoryManager: InventoryManager
    var item: ItemEntity?
    var selectedItem: ItemEntity?

    var body: some View {
        let theme = themeManager.activeTheme
        if let selectedItem = selectedItem,
           let current = item,
           current == selectedItem {
            VStack(alignment: .center, spacing: 4) {
                // Item name
                Text(current.name ?? String.unknown.localized)
                    .font(.appFont(size: 14, weight: .black))
                    .foregroundColor(theme.textColor)
                    .multilineTextAlignment(.center)

                // Item description
                Text(current.info ?? "")
                    .font(.appFont(size: 12))
                    .foregroundColor(theme.textColor.opacity(0.9))
                    .multilineTextAlignment(.center)

                // Item type indicator
                HStack(spacing: 4) {
                    if inventoryManager.isFunctionalItem(current) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.yellow)
                        Text("Functional")
                            .font(.appFont(size: 10, weight: .black))
                            .foregroundColor(.yellow)
                    } else {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.6))
                        Text("Collectible")
                            .font(.appFont(size: 10, weight: .medium))
                            .foregroundColor(theme.textColor.opacity(0.7))
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(inventoryManager.isFunctionalItem(current) ? Color.yellow.opacity(0.2) : Color.white.opacity(0.1))
                )

                // Health potion info
                if inventoryManager.isHealthPotion(current),
                   let healthPotion = inventoryManager.getHealthPotionFromItem(current) {
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

                // XP Boost info
                if inventoryManager.isXPBoost(current),
                   let xpBoost = inventoryManager.getXPBoostFromItem(current) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.green)
                        Text("\(Int(xpBoost.boostMultiplier * 100))% XP")
                            .font(.appFont(size: 10, weight: .black))
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.green.opacity(0.2))
                    )
                }

                // Usage instruction
                if inventoryManager.isFunctionalItem(current) {
                    Text("Long press to use")
                        .font(.appFont(size: 10, weight: .medium))
                        .foregroundColor(theme.textColor.opacity(0.6))
                        .padding(.top, 4)
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

// MARK: - Legacy Components (keeping for compatibility)

struct InventorySlotView_Legacy: View {
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
