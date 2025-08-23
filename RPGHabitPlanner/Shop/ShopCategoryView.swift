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
    case weapons = "Weapons"
    case armor = "Armor"
    case accessories = "Accessories"
    case pets = "Pets"
    
    // Functional categories
    case potions = "Potions"
    case boosts = "Boosts"
    case special = "Specials"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .weapons: return "sword.fill"
        case .armor: return "shield.fill"
        case .accessories: return "crown.fill"
        case .pets: return "pawprint.fill"
        case .potions: return "drop.fill"
        case .boosts: return "bolt.fill"
        case .special: return "star.fill"
        }
    }

    var color: Color {
        switch self {
        case .weapons: return .red
        case .armor: return .blue
        case .accessories: return .orange
        case .pets: return .brown
        case .potions: return .pink
        case .boosts: return .yellow
        case .special: return .indigo
        }
    }

    var assetCategory: AssetCategory? {
        switch self {
        case .weapons: return .weapon
        case .armor: return .outfit
        case .accessories: return .accessory
        case .pets: return .pet
        default: return nil
        }
    }

    var isCustomizationCategory: Bool {
        return assetCategory != nil
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

                Image(systemName: category.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isSelected ? category.color : theme.textColor)
            }

            // Category name
            Text(category.rawValue)
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
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.primaryColor)
                    .frame(height: 120)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(item.rarity.borderColor, lineWidth: 2)
                    )

                // Rarity glow effect
                if item.rarity != .common {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(item.rarity.glowColor)
                        .frame(height: 120)
                        .blur(radius: 4)
                }

                // Simple image loading with caching
                Group {
                    if let image = cachedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .scaleEffect(isHovered ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: isHovered)
                    } else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: theme.textColor.opacity(0.6)))
                            .frame(width: 80, height: 80)
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
            VStack(spacing: 6) {
                // Item name
                Text(item.name)
                    .font(.appFont(size: 14, weight: .bold))
                    .foregroundColor(theme.textColor)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)

                // Rarity badge
                RarityBadge(rarity: item.rarity.toAssetRarity)

                // Price and purchase button
                HStack {
                    // Price
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.yellow)
                        Text("\(ShopManager.shared.getDisplayPrice(for: item))")
                            .font(.appFont(size: 12, weight: .bold))
                            .foregroundColor(canAfford ? theme.textColor : .red)
                    }

                    Spacer()

                    // Purchase button
                    Button(action: onPurchase) {
                        Text("Buy")
                            .font(.appFont(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(canAfford ? .green : .gray)
                            )
                    }
                    .disabled(!canAfford)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.cardBackgroundColor)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
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
        // Check cache first
        if let cachedImage = ImageCache.shared.getImage(for: item.iconName) {
            self.cachedImage = cachedImage
            return
        }

        // Load image asynchronously
        DispatchQueue.global(qos: .userInitiated).async {
            if let image = UIImage(named: item.iconName) {
                // Cache the image
                ImageCache.shared.setImage(image, for: item.iconName)

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
                    Text("Filters")
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
                    // Rarity filter
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Rarity")
                            .font(.appFont(size: 14, weight: .bold))
                            .foregroundColor(theme.textColor)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                // All option
                                FilterChip(
                                    text: "All",
                                    isSelected: selectedRarity == nil,
                                    color: .gray
                                ) {
                                        selectedRarity = nil
                                        onFilterChanged()
                                }

                                // Rarity options
                                ForEach(ItemRarity.allCases, id: \.self) { rarity in
                                    FilterChip(
                                        text: rarity.rawValue,
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

                    // Affordability filter
                    Toggle("Show only affordable items", isOn: $showOnlyAffordable)
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
                    Text("Item Preview")
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
                            if let image = UIImage(named: item.iconName) {
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

                        RarityBadge(rarity: item.rarity.toAssetRarity)

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
                        Text("Cancel")
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
                            Text("Buy for \(ShopManager.shared.getDisplayPrice(for: item))")
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
