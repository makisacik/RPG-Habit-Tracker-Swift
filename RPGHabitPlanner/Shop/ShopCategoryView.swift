//
//  ShopCategoryView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 7.01.2025.
//

import SwiftUI

// MARK: - Enhanced Shop Categories

enum EnhancedShopCategory: String, CaseIterable, Identifiable {
    // Gear categories
    case weapons = "weapons"
    case armor = "armor"
    case wings = "wings"
    case pets = "pets"
    
    // Functional categories (merged)
    case consumables = "consumables"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .weapons: return "icon_sword"
        case .armor: return "icon_shield"
        case .wings: return "icon_wing"
        case .pets: return "pawprint.fill"
        case .consumables: return "drop.fill"
        }
    }

    var color: Color {
        switch self {
        case .weapons: return .red
        case .armor: return .blue
        case .wings: return .purple
        case .pets: return .brown
        case .consumables: return .green
        }
    }

    var assetCategory: AssetCategory? {
        switch self {
        case .weapons: return .weapon
        case .armor: return .outfit
        case .wings: return .wings
        case .pets: return .pet
        default: return nil
        }
    }

    var isCustomizationCategory: Bool {
        return assetCategory != nil
    }
    
    // Subcategories for armor
    var armorSubcategories: [ArmorSubcategory] {
        switch self {
        case .armor:
            return [.helmet, .outfit, .shield]
        default:
            return []
        }
    }
    
    // Subcategories for consumables
    var consumableSubcategories: [ConsumableSubcategory] {
        switch self {
        case .consumables:
            return [.potions, .boosts]
        default:
            return []
        }
    }
}

// MARK: - Armor Subcategories

enum ArmorSubcategory: String, CaseIterable, Identifiable {
    case helmet = "helmet"
    case outfit = "outfit"
    case shield = "shield"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .helmet: return "icon_helmet"
        case .outfit: return "icon_armor"
        case .shield: return "icon_shield"
        }
    }
    
    var color: Color {
        switch self {
        case .helmet: return .orange
        case .outfit: return .blue
        case .shield: return .gray
        }
    }
    
    var assetCategory: AssetCategory {
        switch self {
        case .helmet: return .head
        case .outfit: return .outfit
        case .shield: return .accessory // We'll handle shields specially
        }
    }
}

// MARK: - Consumable Subcategories

enum ConsumableSubcategory: String, CaseIterable, Identifiable {
    case potions = "potions"
    case boosts = "boosts"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .potions: return "drop.fill"
        case .boosts: return "bolt.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .potions: return .pink
        case .boosts: return .yellow
        }
    }
}

// MARK: - Shop Category View

struct ShopCategoryView: View {
    @Binding var selectedCategory: EnhancedShopCategory
    let onCategorySelected: (EnhancedShopCategory) -> Void

    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        let theme = themeManager.activeTheme

        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(EnhancedShopCategory.allCases) { category in
                    ShopCategoryCard(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedCategory = category
                                onCategorySelected(category)
                            }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Shop Category Card

struct ShopCategoryCard: View {
    let category: EnhancedShopCategory
    let isSelected: Bool
    let onTap: () -> Void

    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        let theme = themeManager.activeTheme

        VStack(spacing: 8) {
            // Category icon
            ZStack {
                Circle()
                    .fill(isSelected ? category.color.opacity(0.2) : theme.primaryColor)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? category.color : Color.clear, lineWidth: 2)
                    )

                if category.icon.hasPrefix("icon_") {
                    Image(category.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(isSelected ? category.color : theme.textColor)
                } else {
                    Image(systemName: category.icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(isSelected ? category.color : theme.textColor)
                }
            }

            // Category name
            Text(NSLocalizedString(category.rawValue, comment: ""))
                .font(.appFont(size: 12, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? category.color : theme.textColor.opacity(0.7))
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 80)
        }
        .padding(.vertical, 8)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Shop Item Card (Enhanced)

struct EnhancedShopItemCard: View {
    let item: ShopItem
    let selectedCategory: EnhancedShopCategory
    let isCustomizationItem: Bool
    let onPurchase: () -> Void
    let onPreview: (() -> Void)?

    @EnvironmentObject var themeManager: ThemeManager
    @State private var canAfford = true
    @State private var isHovered = false
    @State private var cachedImage: UIImage?

    var body: some View {
        let theme = themeManager.activeTheme

        VStack(spacing: 12) {
            // Item preview
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(theme.secondaryColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(theme.borderColor.opacity(0.6), lineWidth: 1.5)
                    )
                    .frame(height: 60)
                    .overlay(
                                        // Only show rarity border for gear items
                Group {
                    if selectedCategory == .weapons || selectedCategory == .armor {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(item.rarity.borderColor, lineWidth: 1)
                    }
                }
                    )

                // Rarity glow effect - only for gear items
                if isGearCategory(selectedCategory) && item.rarity != .common {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(item.rarity.glowColor)
                        .frame(height: 60)
                        .blur(radius: 2)
                }

                // Simple image loading with caching
                Group {
                    if let image = cachedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .scaleEffect(isHovered ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: isHovered)
                    } else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: theme.textColor.opacity(0.6)))
                            .frame(width: 40, height: 40)
                    }
                }

                // Preview button for customization items
                if isCustomizationItem, let onPreview = onPreview {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: onPreview) {
                                Image(systemName: "eye.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Circle().fill(.black.opacity(0.6)))
                            }
                        }
                    }
                    .padding(8)
                }
            }

            // Item info
            VStack(spacing: 4) {
                // Item name
                Text(item.name)
                    .font(.appFont(size: 12, weight: .bold))
                    .foregroundColor(theme.textColor)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)

                // Rarity badge - only show for gear items
                if isGearCategory(selectedCategory) {
                    RarityBadge(rarity: item.rarity.toAssetRarity)
                }

                // Price and purchase button
                HStack {
                    // Price
                    HStack(spacing: 2) {
                        if ShopManager.shared.getDisplayCurrency(for: item) == "gems" {
                            Image("icon_gem")
                                .resizable()
                                .frame(width: 12, height: 12)
                                .foregroundColor(.purple)
                        } else {
                            Image("icon_gold")
                                .resizable()
                                .frame(width: 12, height: 12)
                                .foregroundColor(.yellow)
                        }
                        Text("\(ShopManager.shared.getDisplayPrice(for: item))")
                            .font(.appFont(size: 10, weight: .bold))
                            .foregroundColor(canAfford ? theme.textColor : .red)
                    }

                    Spacer()

                    // Purchase button or Owned status
                    if item.isOwned {
                        Text("owned".localized)
                            .font(.appFont(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.gray)
                            )
                    } else {
                        Button(action: onPurchase) {
                            Text("buy".localized)
                                .font(.appFont(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(canAfford ? .green : .gray)
                                )
                        }
                        .disabled(!canAfford)
                    }
                }
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.secondaryColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(theme.borderColor.opacity(0.6), lineWidth: 1.5)
                )
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .opacity(item.isOwned ? 0.6 : 1.0) // Gray out owned items
        .onHover { hovering in
            isHovered = hovering
        }
        .onAppear {
            checkAffordability()
            loadImage()
        }
    }

    private func checkAffordability() {
        ShopManager.shared.canAffordItem(item) { canAfford in
            self.canAfford = canAfford
        }
    }

    private func loadImage() {
        // Use previewImage for display in shop, fallback to iconName
        let displayImageName = item.previewImage
        
        // Check cache first
        if let cachedImage = ImageCache.shared.getImage(for: displayImageName) {
            self.cachedImage = cachedImage
            return
        }

        // Load image asynchronously
        DispatchQueue.global(qos: .userInitiated).async {
            if let image = UIImage(named: displayImageName) {
                // Cache the image
                ImageCache.shared.setImage(image, for: displayImageName)

                DispatchQueue.main.async {
                    self.cachedImage = image
                }
            }
        }
    }
}


// MARK: - Shop Filter View

struct ShopFilterView: View {
    @Binding var selectedRarity: ItemRarity?
    @Binding var priceRange: ClosedRange<Int>
    @Binding var showOnlyAffordable: Bool
    let selectedCategory: EnhancedShopCategory
    let onFilterChanged: () -> Void

    @EnvironmentObject var themeManager: ThemeManager
    @State private var showFilters = false

    var body: some View {
        let theme = themeManager.activeTheme

        VStack(spacing: 0) {
            // Filter toggle button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    showFilters.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "slider.horizontal.3")
                    Text(String(localized: "filters"))
                    Spacer()
                    Image(systemName: showFilters ? "chevron.up" : "chevron.down")
                }
                .font(.appFont(size: 14, weight: .medium))
                .foregroundColor(theme.textColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(theme.primaryColor)
                )
            }

            // Filter options
            if showFilters {
                VStack(spacing: 16) {
                    // Rarity filter - only show for gear categories
                    if isGearCategory(selectedCategory) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(String(localized: "rarity"))
                                .font(.appFont(size: 14, weight: .bold))
                                .foregroundColor(theme.textColor)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    // All option
                                    FilterChip(
                                        text: String(localized: "all"),
                                        isSelected: selectedRarity == nil,
                                        color: .gray
                                    ) {
                                            selectedRarity = nil
                                            onFilterChanged()
                                    }

                                    // Rarity options
                                    ForEach(ItemRarity.allCases, id: \.self) { rarity in
                                        FilterChip(
                                            text: rarity.rawValue.localized,
                                            isSelected: selectedRarity == rarity,
                                            color: rarity.uiColor
                                        ) {
                                                selectedRarity = selectedRarity == rarity ? nil : rarity
                                                onFilterChanged()
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }

                    // Affordability filter
                    Toggle(String(localized: "show_only_affordable_items"), isOn: $showOnlyAffordable)
                        .font(.appFont(size: 14))
                        .foregroundColor(theme.textColor)
                        .onChange(of: showOnlyAffordable) { _ in
                            onFilterChanged()
                        }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(theme.backgroundColor.opacity(0.5))
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let text: String
    let isSelected: Bool
    let color: Color
    let onTap: () -> Void

    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        let theme = themeManager.activeTheme

        Text(text)
            .font(.appFont(size: 12, weight: .medium))
            .foregroundColor(isSelected ? .white : color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? color : color.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(color, lineWidth: 1)
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isSelected)
            .onTapGesture {
                onTap()
            }
    }
}

// MARK: - Item Preview Modal

struct ItemPreviewModal: View {
    let item: ShopItem
    let onDismiss: () -> Void
    let onPurchase: () -> Void

    @EnvironmentObject var themeManager: ThemeManager
    @State private var previewScale: CGFloat = 0.8
    @State private var showItemDetails = false

    var body: some View {
        let theme = themeManager.activeTheme

        ZStack {
            // Background overlay
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }

            // Modal content
            VStack(spacing: 20) {
                // Header
                HStack {
                    Text(String(localized: "item_preview"))
                        .font(.appFont(size: 20, weight: .bold))
                        .foregroundColor(theme.textColor)

                    Spacer()

                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(theme.textColor.opacity(0.6))
                    }
                }

                // Character preview with item
                VStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(theme.primaryColor)
                            .frame(width: 200, height: 200)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(item.rarity.borderColor, lineWidth: 3)
                            )

                        // Character with item preview
                        VStack {
                            if let image = UIImage(named: item.previewImage) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 120, height: 120)
                                    .scaleEffect(previewScale)
                                    .animation(.spring(response: 0.8, dampingFraction: 0.6).repeatForever(autoreverses: true), value: previewScale)
                            } else {
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .foregroundColor(theme.textColor.opacity(0.3))
                                    .frame(width: 120, height: 120)
                                    .scaleEffect(previewScale)
                                    .animation(.spring(response: 0.8, dampingFraction: 0.6).repeatForever(autoreverses: true), value: previewScale)
                            }
                        }
                    }

                    // Item info
                    VStack(spacing: 8) {
                        Text(item.name)
                            .font(.appFont(size: 18, weight: .bold))
                            .foregroundColor(theme.textColor)

                        // Only show rarity badge for gear items
                        if isGearCategory(item.category) {
                            RarityBadge(rarity: item.rarity.toAssetRarity)
                        }

                        Text(item.description)
                            .font(.appFont(size: 14))
                            .foregroundColor(theme.textColor.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }

                // Action buttons
                HStack(spacing: 16) {
                    Button(action: onDismiss) {
                        Text(String(localized: "cancel"))
                            .font(.appFont(size: 16, weight: .medium))
                            .foregroundColor(theme.textColor)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(theme.primaryColor)
                            )
                    }

                    Button(action: {
                        onPurchase()
                        onDismiss()
                    }) {
                        HStack {
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundColor(.white)
                            Text(String(localized: "buy_for").localized(with: String(ShopManager.shared.getDisplayPrice(for: item))))
                                .font(.appFont(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.green)
                        )
                    }
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(theme.backgroundColor)
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 20)
            .scaleEffect(showItemDetails ? 1.0 : 0.8)
            .opacity(showItemDetails ? 1.0 : 0.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showItemDetails)
        }
        .onAppear {
            showItemDetails = true
            startPreviewAnimation()
        }
    }

    private func startPreviewAnimation() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).repeatForever(autoreverses: true)) {
            previewScale = 1.1
        }
    }
}

// MARK: - Armor Subcategory View

struct ArmorSubcategoryView: View {
    @Binding var selectedSubcategory: ArmorSubcategory
    let onSubcategorySelected: (ArmorSubcategory) -> Void

    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        let theme = themeManager.activeTheme

        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ArmorSubcategory.allCases) { subcategory in
                    SubcategoryCard(
                        title: subcategory.rawValue.localized,
                        icon: subcategory.icon,
                        color: subcategory.color,
                        isSelected: selectedSubcategory == subcategory
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedSubcategory = subcategory
                            onSubcategorySelected(subcategory)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Consumable Subcategory View

struct ConsumableSubcategoryView: View {
    @Binding var selectedSubcategory: ConsumableSubcategory
    let onSubcategorySelected: (ConsumableSubcategory) -> Void

    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        let theme = themeManager.activeTheme

        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ConsumableSubcategory.allCases) { subcategory in
                    SubcategoryCard(
                        title: subcategory.rawValue.localized,
                        icon: subcategory.icon,
                        color: subcategory.color,
                        isSelected: selectedSubcategory == subcategory
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedSubcategory = subcategory
                            onSubcategorySelected(subcategory)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Subcategory Card

struct SubcategoryCard: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let onTap: () -> Void

    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        let theme = themeManager.activeTheme

        VStack(spacing: 6) {
            // Subcategory icon
            ZStack {
                Circle()
                    .fill(isSelected ? color.opacity(0.2) : theme.primaryColor)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? color : Color.clear, lineWidth: 2)
                    )

                if icon.hasPrefix("icon_") {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundColor(isSelected ? color : theme.textColor)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isSelected ? color : theme.textColor)
                }
            }

            // Subcategory name
            Text(title)
                .font(.appFont(size: 10, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? color : theme.textColor.opacity(0.7))
                .lineLimit(1)
                .multilineTextAlignment(.center)
                .frame(width: 60)
        }
        .padding(.vertical, 6)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Helper Functions

/// Determines if a shop category is a gear category (should show rarity)
func isGearCategory(_ category: EnhancedShopCategory) -> Bool {
    switch category {
    case .weapons, .armor, .wings, .pets:
        return true
    case .consumables:
        return false
    }
}
