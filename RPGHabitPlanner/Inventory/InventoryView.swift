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
    @State private var showItemDetail = false
    @State private var selectedCategory: InventoryCategory = .gear

    var body: some View {
        let theme = themeManager.activeTheme

        ZStack {
            theme.backgroundColor
                .ignoresSafeArea()
                .onTapGesture {
                    selectedItem = nil
                }

            VStack(spacing: 10) {
                // Header
                HStack {
                    Text(String.inventory.localized)
                        .font(.appFont(size: 22, weight: .black))
                        .foregroundColor(theme.textColor)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 14)
                        .background(RoundedRectangle(cornerRadius: 6).fill(theme.secondaryColor.opacity(0.8)))

                    Spacer()
                }

                // Category Selector
                CategorySelectorView(selectedCategory: $selectedCategory, theme: theme)

                // Items Grid
                CategorizedItemsGridView(
                    category: selectedCategory,
                    inventoryManager: inventoryManager,
                    selectedItem: $selectedItem,
                    showItemDetail: $showItemDetail,
                    theme: theme
                )
                .environmentObject(themeManager)
            }
            .padding()
        }
        .navigationTitle(String.inventory.localized)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            inventoryManager.refreshInventory()

            // Note: Starter items are now added during onboarding completion
        }
        .sheet(isPresented: $showItemDetail) {
            if let item = selectedItem {
                UnifiedItemDetailView(item: item)
                    .environmentObject(inventoryManager)
                    .environmentObject(themeManager)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

// MARK: - Inventory Categories

enum InventoryCategory: String, CaseIterable {
    case gear = "Gear"
    case others = "Others"
    case accessories = "Accessories"

    var icon: String {
        switch self {
        case .gear: return "shield.fill"
        case .others: return "flask.fill"
        case .accessories: return "sparkles"
        }
    }

    var description: String {
        switch self {
        case .gear: return "Equippable gear items"
        case .others: return "Boosters, potions, collectibles"
        case .accessories: return "Character accessories"
        }
    }
}

// MARK: - Gear Subcategories

enum GearSubcategory: String, CaseIterable {
    case head = "Head"
    case weapon = "Weapon"
    case shield = "Shield"
    case outfit = "Outfit"
    case pet = "Pet"
    case wings = "Wings"

    var icon: String {
        switch self {
        case .head: return "helmet"
        case .weapon: return "sword.fill"
        case .shield: return "shield.fill"
        case .outfit: return "tshirt.fill"
        case .pet: return "pawprint.fill"
        case .wings: return "airplane"
        }
    }

    var gearCategory: GearCategory {
        switch self {
        case .head: return .head
        case .weapon: return .weapon
        case .shield: return .shield
        case .outfit: return .outfit
        case .pet: return .pet
        case .wings: return .wings
        }
    }
}

// MARK: - Others Subcategories

enum OthersSubcategory: String, CaseIterable {
    case boosters = "Boosters"
    case potions = "Potions"
    case collectibles = "Collectibles"

    var icon: String {
        switch self {
        case .boosters: return "bolt.fill"
        case .potions: return "drop.fill"
        case .collectibles: return "star.fill"
        }
    }
}

// MARK: - Category Selector View

struct CategorySelectorView: View {
    @Binding var selectedCategory: InventoryCategory
    let theme: Theme

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(InventoryCategory.allCases, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: category.icon)
                                .font(.system(size: 16))
                                .foregroundColor(selectedCategory == category ? theme.accentColor : theme.textColor.opacity(0.7))

                            Text(category.rawValue)
                                .font(.appFont(size: 12, weight: .medium))
                                .foregroundColor(selectedCategory == category ? theme.accentColor : theme.textColor.opacity(0.7))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedCategory == category ? theme.accentColor.opacity(0.2) : Color.clear)
                        )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Gear Subcategory Selector

struct GearSubcategorySelector: View {
    @Binding var selectedSubcategory: GearSubcategory
    let theme: Theme

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(GearSubcategory.allCases, id: \.self) { subcategory in
                    Button(action: {
                        selectedSubcategory = subcategory
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: subcategory.icon)
                                .font(.system(size: 12))
                                .foregroundColor(selectedSubcategory == subcategory ? theme.accentColor : theme.textColor.opacity(0.7))

                            Text(subcategory.rawValue)
                                .font(.appFont(size: 11, weight: .medium))
                                .foregroundColor(selectedSubcategory == subcategory ? theme.accentColor : theme.textColor.opacity(0.7))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(selectedSubcategory == subcategory ? theme.accentColor.opacity(0.2) : Color.clear)
                        )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Others Subcategory Selector

struct OthersSubcategorySelector: View {
    @Binding var selectedSubcategory: OthersSubcategory
    let theme: Theme

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(OthersSubcategory.allCases, id: \.self) { subcategory in
                    Button(action: {
                        selectedSubcategory = subcategory
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: subcategory.icon)
                                .font(.system(size: 12))
                                .foregroundColor(selectedSubcategory == subcategory ? theme.accentColor : theme.textColor.opacity(0.7))

                            Text(subcategory.rawValue)
                                .font(.appFont(size: 11, weight: .medium))
                                .foregroundColor(selectedSubcategory == subcategory ? theme.accentColor : theme.textColor.opacity(0.7))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(selectedSubcategory == subcategory ? theme.accentColor.opacity(0.2) : Color.clear)
                        )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Categorized Items Grid View

struct CategorizedItemsGridView: View {
    let category: InventoryCategory
    @ObservedObject var inventoryManager: InventoryManager
    @Binding var selectedItem: ItemEntity?
    @Binding var showItemDetail: Bool
    let theme: Theme
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedGearSubcategory: GearSubcategory = .head
    @State private var selectedOthersSubcategory: OthersSubcategory = .boosters

    private let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 6), count: 6)

    var body: some View {
        VStack(spacing: 10) {
            // Category Header
            HStack {
                Text(category.rawValue)
                    .font(.appFont(size: 18, weight: .bold))
                    .foregroundColor(theme.textColor)

                Spacer()

                Text("\(getFilteredItems().count) items")
                    .font(.appFont(size: 14))
                    .foregroundColor(theme.textColor.opacity(0.7))
            }

            // Subcategory Selector
            if category == .gear {
                GearSubcategorySelector(selectedSubcategory: $selectedGearSubcategory, theme: theme)
            } else if category == .others {
                OthersSubcategorySelector(selectedSubcategory: $selectedOthersSubcategory, theme: theme)
            }

            let filteredItems = getFilteredItems()

            if filteredItems.isEmpty {
                EmptyCategoryView(category: category, theme: theme)
            } else {
                LazyVGrid(columns: columns, spacing: 6) {
                    ForEach(0..<18, id: \.self) { index in
                        let item = index < filteredItems.count ? filteredItems[index] : nil
                        InventorySlotView(
                            item: item,
                            isSelected: selectedItem == item
                        ) {
                            if let item = item {
                                selectedItem = item
                                showItemDetail = true
                            } else {
                                selectedItem = nil
                            }
                        }
                        .environmentObject(themeManager)
                        .environmentObject(inventoryManager)
                    }
                }
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 10).fill(theme.surfaceColor.opacity(0.6)))
            }
        }
    }

    private func getFilteredItems() -> [ItemEntity] {
        switch category {
        case .gear:
            return inventoryManager.inventoryItems.filter { item in
                guard inventoryManager.isGear(item) else { return false }
                // Filter by gear subcategory
                if let gearCategory = inventoryManager.getGearCategory(item) {
                    return gearCategory == selectedGearSubcategory.gearCategory
                }
                return false
            }
        case .others:
            switch selectedOthersSubcategory {
            case .boosters:
                return inventoryManager.inventoryItems.filter { inventoryManager.isBooster($0) }
            case .potions:
                return inventoryManager.inventoryItems.filter { inventoryManager.isConsumable($0) }
            case .collectibles:
                return inventoryManager.inventoryItems.filter { inventoryManager.isCollectible($0) }
            }
        case .accessories:
            return inventoryManager.inventoryItems.filter { inventoryManager.isAccessory($0) }
        }
    }
}

// MARK: - Empty Category View

struct EmptyCategoryView: View {
    let category: InventoryCategory
    let theme: Theme

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: category.icon)
                .font(.system(size: 48))
                .foregroundColor(theme.textColor.opacity(0.3))

            Text("No \(category.rawValue.lowercased()) items")
                .font(.appFont(size: 16, weight: .medium))
                .foregroundColor(theme.textColor.opacity(0.7))

            Text(category.description)
                .font(.appFont(size: 14))
                .foregroundColor(theme.textColor.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.backgroundColor.opacity(0.7))
        )
    }
}

// MARK: - Inventory Slot View

struct InventorySlotView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var inventoryManager: InventoryManager
    let item: ItemEntity?
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        let theme = themeManager.activeTheme

        Button(action: onTap) {
            ZStack {
                // Slot background
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(
                        isSelected ? Color.yellow : Color.white.opacity(0.4),
                        lineWidth: isSelected ? 2 : 1.5
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(theme.secondaryColor.opacity(0.3))
                    )

                if let item = item {
                    // Main content container
                    VStack(spacing: 0) {
                        // Item icon container
                        ZStack {
                            if item.iconName?.contains("potion_health") == true {
                                // Use custom health potion icon
                                let rarity = getPotionRarity(from: item.iconName ?? "")
                                HealthPotionIconView(rarity: rarity, size: 36)
                            } else {
                                Image(item.iconName ?? "")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: 40, maxHeight: 40)
                                    .padding(2)
                            }

                            // XP Boost indicator (top-right corner)
                            if inventoryManager.isBooster(item) && item.iconName?.contains("xp") == true {
                                VStack {
                                    HStack {
                                        Spacer()
                                        Image(systemName: "arrow.up.circle.fill")
                                            .font(.system(size: 10))
                                            .foregroundColor(.green)
                                            .background(Circle().fill(Color.white))
                                            .offset(x: 2, y: -2)
                                    }
                                    Spacer()
                                }
                            }

                            // Coin Boost indicator (top-left corner)
                            if inventoryManager.isBooster(item) && item.iconName?.contains("coin") == true {
                                VStack {
                                    HStack {
                                        Image(systemName: "dollarsign.circle.fill")
                                            .font(.system(size: 10))
                                            .foregroundColor(.yellow)
                                            .background(Circle().fill(Color.white))
                                            .offset(x: -2, y: -2)
                                        Spacer()
                                    }
                                    Spacer()
                                }
                            }

                            // Rarity indicator for gear items
                            if inventoryManager.isGear(item), let rarity = inventoryManager.getRarity(item) {
                                VStack {
                                    HStack {
                                        Spacer()
                                        Circle()
                                            .fill(rarity.uiColor)
                                            .frame(width: 8, height: 8)
                                            .offset(x: 2, y: -2)
                                    }
                                    Spacer()
                                }
                            }
                        }
                        .frame(height: 44)

                        // Item type indicator (bottom)
                        HStack {
                            Spacer()
                            if inventoryManager.isConsumable(item) || inventoryManager.isBooster(item) {
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(.yellow)
                            } else if inventoryManager.isGear(item) {
                                Image(systemName: "shield.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(.blue)
                            } else if inventoryManager.isAccessory(item) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 8))
                                    .foregroundColor(.purple)
                            } else {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            Spacer()
                        }
                        .frame(height: 10)
                    }
                    .padding(2)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .aspectRatio(1, contentMode: .fit)
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
    let title: String
    let description: String
    let theme: Theme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.appFont(size: 16, weight: .black))
                .foregroundColor(theme.textColor)

            Text(description)
                .font(.appFont(size: 14))
                .foregroundColor(theme.textColor.opacity(0.8))
                .multilineTextAlignment(.leading)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(theme.primaryColor)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

#Preview {
    InventoryView()
        .environmentObject(ThemeManager.shared)
        .environmentObject(InventoryManager.shared)
}
