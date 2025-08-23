//
//  CharacterView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 5.08.2025.
//

import SwiftUI

struct CharacterView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var healthManager = HealthManager.shared
    @StateObject private var inventoryManager = InventoryManager.shared
    @StateObject private var boosterManager = BoosterManager.shared
    @State private var showBoosterInfo = false
    @State private var refreshTrigger = false
    @State private var showShop = false
    @State private var showCustomizationModal = false
    @State private var characterCustomization: CharacterCustomization?
    let user: UserEntity

    private let customizationService = CharacterCustomizationService()

    var body: some View {
        let theme = themeManager.activeTheme

        ZStack {
            theme.backgroundColor
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    CharacterSectionView(
                        user: user,
                        characterCustomization: characterCustomization,
                        showCustomizationModal: $showCustomizationModal
                    )

                    VStack(spacing: 12) {
                        // Health Bar
                        HealthBarView(healthManager: healthManager, size: .large, showShineAnimation: false)
                            .padding(.horizontal)

                        // Level and Experience
                        LevelExperienceView(user: user, theme: theme)

                        // Inventory Section
                        InventorySectionView(
                            inventoryManager: inventoryManager,
                            theme: theme
                        )

                        // Boosters Section
                        BoostersSectionView(
                            boosterManager: boosterManager,
                            showBoosterInfo: $showBoosterInfo,
                            theme: theme
                        )

                        // Shop Button
                        ShopButtonView(showShop: $showShop, theme: theme)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
        .sheet(isPresented: $showShop) {
            NavigationStack {
                ShopView()
                    .environmentObject(themeManager)
            }
        }
        .sheet(isPresented: $showCustomizationModal) {
            CharacterTabCustomizationView(user: user)
                .environmentObject(themeManager)
        }
        .onAppear {
            fetchCharacterCustomization()
            // Refresh inventory to ensure we have items to test with
            inventoryManager.refreshInventory()
            // Ensure GearManager is initialized and refresh character customization
            let gearManager = GearManager.shared
            // Force refresh character customization from gear
            gearManager.refreshCharacterCustomizationFromGear(for: user)
        }
        .onChange(of: showCustomizationModal) { isPresented in
            // Refresh character customization when modal is dismissed
            if !isPresented {
                fetchCharacterCustomization()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .boostersUpdated)) { _ in
            print("🔄 CharacterView: Received boostersUpdated notification")
            refreshTrigger.toggle()
        }
        .onReceive(NotificationCenter.default.publisher(for: .characterCustomizationUpdated)) { _ in
            print("🔄 CharacterView: Received characterCustomizationUpdated notification")
            fetchCharacterCustomization()
        }
        .onReceive(NotificationCenter.default.publisher(for: .gearUpdated)) { _ in
            print("🔄 CharacterView: Received gearUpdated notification")
            fetchCharacterCustomization()
        }
    }

    private func fetchCharacterCustomization() {
        if let customizationEntity = customizationService.fetchCustomization(for: user) {
            self.characterCustomization = customizationEntity.toCharacterCustomization()
            print("✅ CharacterView: Loaded character customization")
        } else {
            // Create default customization if none exists
            let defaultCustomization = CharacterCustomization()
            self.characterCustomization = defaultCustomization

            // Save the default customization
            if let _ = customizationService.createCustomization(for: user, customization: defaultCustomization) {
                print("✅ CharacterView: Created default character customization")
            } else {
                print("❌ CharacterView: Failed to create default character customization")
            }
        }
    }

    /// Refreshes character customization data
    private func refreshCharacterCustomization() {
        fetchCharacterCustomization()
    }
}

// MARK: - Character Section View
struct CharacterSectionView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let user: UserEntity
    let characterCustomization: CharacterCustomization?
    @Binding var showCustomizationModal: Bool
    @State private var showGearMenu = false
    @State private var selectedGearCategory: GearCategory = .head
    @State private var pendingGearCategory: GearCategory?
    @StateObject private var gearManager = GearManager.shared
    
    // Add a computed property to ensure we always have the correct category
    private var currentGearCategory: GearCategory {
        return selectedGearCategory
    }

    var body: some View {
        let theme = themeManager.activeTheme

        ZStack {
            // Background with particles
            ParticleBackground(
                color: Color.blue.opacity(0.2),
                count: 15,
                sizeRange: 8...16,
                speedRange: 12...20
            )

            ParticleBackground(
                color: Color.blue.opacity(0.3),
                count: 20,
                sizeRange: 5...10,
                speedRange: 6...12
            )

            HStack(spacing: 20) {
                // Left Equipment Slots
                VStack(spacing: 16) {
                    EquipmentSlotView(
                        slotType: "HEAD",
                        iconName: "helmet",
                        isEquipped: gearManager.getEquippedItem(for: .head) != nil,
                        equippedItem: gearManager.getEquippedItem(for: .head),
                        theme: theme
                    ) {
                            print("⛑️ Head slot tapped - setting category to .head")
                            pendingGearCategory = .head
                            selectedGearCategory = .head
                            print("🎯 Pending category set to: \(pendingGearCategory?.rawValue ?? "nil")")
                            showGearMenu = true
                    }

                    EquipmentSlotView(
                        slotType: "OUTFIT",
                        iconName: "tshirt",
                        isEquipped: gearManager.getEquippedItem(for: .outfit) != nil,
                        equippedItem: gearManager.getEquippedItem(for: .outfit),
                        theme: theme
                    ) {
                            print("👕 Outfit slot tapped - setting category to .outfit")
                            pendingGearCategory = .outfit
                            selectedGearCategory = .outfit
                            print("🎯 Pending category set to: \(pendingGearCategory?.rawValue ?? "nil")")
                            showGearMenu = true
                    }

                    EquipmentSlotView(
                        slotType: "WING",
                        iconName: "wing",
                        isEquipped: gearManager.getEquippedItem(for: .wings) != nil,
                        equippedItem: gearManager.getEquippedItem(for: .wings),
                        theme: theme
                    ) {
                            print("🦅 Wing slot tapped - setting category to .wings")
                            pendingGearCategory = .wings
                            selectedGearCategory = .wings
                            print("🎯 Pending category set to: \(pendingGearCategory?.rawValue ?? "nil")")
                            showGearMenu = true
                    }
                }

                // Center Character Display
                VStack(spacing: 16) {
                    // Character Display
                    // Character Display
                    // Character Display (fills perfectly with .scaledToFill)
                    ZStack {
                        let corner: CGFloat = 16

                        // Card background
                        RoundedRectangle(cornerRadius: corner)
                            .fill(theme.cardBackgroundColor.opacity(0.8))
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)

                        // Background image sized to the container, then clipped
                        GeometryReader { proxy in
                            Image("char_background")
                                .resizable()
                                .scaledToFill() // covers the whole card
                                .frame(width: proxy.size.width, height: proxy.size.height)
                                .clipped() // remove the overflow from scaledToFill
                                .opacity(0.30)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: corner))
                        .overlay(
                            RoundedRectangle(cornerRadius: corner)
                                .stroke(theme.borderColor.opacity(0.12), lineWidth: 1)
                        )

                        CharacterDisplayView(
                            customization: characterCustomization,
                            size: 200,
                            showShadow: true
                        )
                        .id("character-display-\(characterCustomization?.shield?.rawValue ?? "nil")-\(characterCustomization?.pet?.rawValue ?? "nil")")
                        .offset(y: 70)
                    }
                    .frame(width: 200, height: 270)


                    // Character Stats
                    VStack(spacing: 8) {
                        HStack {
                            Text("DAMAGE")
                                .font(.appFont(size: 14, weight: .bold))
                                .foregroundColor(.yellow)
                            Spacer()
                            Text("\(gearManager.characterStats.totalDamage)")
                                .font(.appFont(size: 16, weight: .bold))
                                .foregroundColor(.yellow)
                        }

                        HStack {
                            Text("ARMOR")
                                .font(.appFont(size: 14, weight: .bold))
                                .foregroundColor(.yellow)
                            Spacer()
                            Text("\(gearManager.characterStats.totalArmor)")
                                .font(.appFont(size: 16, weight: .bold))
                                .foregroundColor(.yellow)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(theme.backgroundColor.opacity(0.7))
                    )

                    // Action Buttons
                    HStack(spacing: 12) {
                        Button(action: {
                            showCustomizationModal = true
                        }) {
                            Text("SKINS")
                                .font(.appFont(size: 12, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(theme.primaryColor)
                                )
                        }

                        Button(action: {
                            // TODO: Show stats
                        }) {
                            Text("STATS")
                                .font(.appFont(size: 12, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(theme.primaryColor)
                                )
                        }
                    }
                }

                // Right Equipment Slots
                VStack(spacing: 16) {
                    EquipmentSlotView(
                        slotType: "WEAPON",
                        iconName: "sword",
                        isEquipped: gearManager.getEquippedItem(for: .weapon) != nil,
                        equippedItem: gearManager.getEquippedItem(for: .weapon),
                        theme: theme
                    ) {
                            print("⚔️ Weapon slot tapped - setting category to .weapon")
                            pendingGearCategory = .weapon
                            selectedGearCategory = .weapon
                            print("🎯 Pending category set to: \(pendingGearCategory?.rawValue ?? "nil")")
                            showGearMenu = true
                    }

                    EquipmentSlotView(
                        slotType: "SHIELD",
                        iconName: "shield",
                        isEquipped: gearManager.getEquippedItem(for: .shield) != nil,
                        equippedItem: gearManager.getEquippedItem(for: .shield),
                        theme: theme
                    ) {
                            print("🛡️ Shield slot tapped - setting category to .shield")
                            pendingGearCategory = .shield
                            selectedGearCategory = .shield
                            print("🎯 Pending category set to: \(pendingGearCategory?.rawValue ?? "nil")")
                            showGearMenu = true
                    }

                    EquipmentSlotView(
                        slotType: "PET",
                        iconName: "pawprint",
                        isEquipped: gearManager.getEquippedItem(for: .pet) != nil,
                        equippedItem: gearManager.getEquippedItem(for: .pet),
                        theme: theme
                    ) {
                            print("🐾 Pet slot tapped - setting category to .pet")
                            pendingGearCategory = .pet
                            selectedGearCategory = .pet
                            print("🎯 Pending category set to: \(pendingGearCategory?.rawValue ?? "nil")")
                            showGearMenu = true
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .frame(height: 400)
        .clipped()
        .sheet(isPresented: $showGearMenu) {
            GearMenuView(gearCategory: pendingGearCategory ?? selectedGearCategory, user: user)
                .environmentObject(themeManager)
                .environmentObject(InventoryManager.shared)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .onAppear {
                    print("🎯 Sheet presented with category: \(pendingGearCategory?.rawValue ?? selectedGearCategory.rawValue)")
                }
        }
        .onChange(of: showGearMenu) { isPresented in
            if !isPresented {
                // Reset pending category when sheet is dismissed
                pendingGearCategory = nil
                print("🎯 Sheet dismissed, pending category reset")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .gearUpdated)) { _ in
            // Refresh equipment display when gear is updated
            print("🔄 CharacterSectionView: Received gearUpdated notification")
        }
        .onReceive(NotificationCenter.default.publisher(for: .characterCustomizationUpdated)) { _ in
            // Refresh character display when customization is updated
            print("🔄 CharacterSectionView: Received characterCustomizationUpdated notification")
        }
    }
}

// MARK: - Equipment Slot View
struct EquipmentSlotView: View {
    let slotType: String
    let iconName: String
    let isEquipped: Bool
    let equippedItem: ItemEntity?
    let theme: Theme
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    // Slot background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(theme.backgroundColor.opacity(0.7))
                        .frame(width: 60, height: 60)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isEquipped ? theme.accentColor : theme.borderColor.opacity(0.5), lineWidth: isEquipped ? 2 : 1)
                        )

                    // Equipment icon or placeholder
                    if isEquipped, let equippedItem = equippedItem, let iconName = equippedItem.iconName {
                        // Show actual equipped item icon
                        Image(iconName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                    } else if isEquipped {
                        // Fallback to system icon if no custom icon
                        Image(systemName: iconName)
                            .font(.system(size: 24))
                            .foregroundColor(theme.textColor)
                    } else {
                        // Placeholder for unequipped slot
                        Image(systemName: iconName)
                            .font(.system(size: 20))
                            .foregroundColor(theme.textColor.opacity(0.3))
                    }
                }

                Text(slotType)
                    .font(.appFont(size: 10, weight: .medium))
                    .foregroundColor(theme.textColor.opacity(0.8))
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Level Experience View
struct LevelExperienceView: View {
    let user: UserEntity
    let theme: Theme

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image("icon_star_fill")
                    .resizable()
                    .frame(width: 18, height: 18)
                Text("\(String.level.localized) \(user.level)")
                    .font(.appFont(size: 18))
                    .foregroundColor(theme.textColor)
                Spacer()
            }

            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(theme.backgroundColor.opacity(0.7))
                    .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
                    .frame(height: 22)

                GeometryReader { geometry in
                    let expRatio = min(CGFloat(user.exp) / 100.0, 1.0)
                    if expRatio > 0 {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(LinearGradient(
                                colors: [theme.primaryColor, theme.primaryColor.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: geometry.size.width * expRatio, height: 22)
                            .animation(.easeInOut(duration: 0.5), value: expRatio)
                    }
                }
                .frame(height: 22)

                HStack {
                    Text("\(user.exp)/100")
                        .font(.appFont(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                    Spacer()
                }
                .padding(.horizontal, 8)
            }
        }
    }
}


// MARK: - Inventory Section View
struct InventorySectionView: View {
    @ObservedObject var inventoryManager: InventoryManager
    @State private var selectedCategory: InventoryCategory = .gear
    @State private var showFullInventory = false
    let theme: Theme

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Inventory")
                    .font(.appFont(size: 20, weight: .bold))
                    .foregroundColor(theme.textColor)
                Spacer()
                Button(action: {
                    showFullInventory = true
                }) {
                    Text("View All")
                        .font(.appFont(size: 14, weight: .medium))
                        .foregroundColor(theme.accentColor)
                }
            }

            // Category Selector
            CategorySelectorView(selectedCategory: $selectedCategory, theme: theme)

            // Items Preview
            ItemsPreviewView(
                category: selectedCategory,
                inventoryManager: inventoryManager,
                theme: theme
            )
        }
        .sheet(isPresented: $showFullInventory) {
            NavigationStack {
                InventoryView()
                    .environmentObject(ThemeManager.shared)
                    .environmentObject(InventoryManager.shared)
            }
        }
    }
}

// MARK: - Items Preview View
struct ItemsPreviewView: View {
    let category: InventoryCategory
    @ObservedObject var inventoryManager: InventoryManager
    let theme: Theme

    var filteredItems: [ItemEntity] {
        switch category {
        case .gear:
            return inventoryManager.inventoryItems.filter { inventoryManager.isGear($0) }
        case .others:
            return inventoryManager.inventoryItems.filter {
                inventoryManager.isConsumable($0) || inventoryManager.isBooster($0) || inventoryManager.isCollectible($0)
            }
        case .accessories:
            return inventoryManager.inventoryItems.filter { inventoryManager.isAccessory($0) }
        }
    }

    var body: some View {
        if filteredItems.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 24))
                    .foregroundColor(theme.textColor.opacity(0.5))
                Text("No \(category.rawValue.lowercased()) items")
                    .font(.appFont(size: 14))
                    .foregroundColor(theme.textColor.opacity(0.7))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.backgroundColor.opacity(0.7))
            )
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(filteredItems.prefix(6), id: \.id) { item in
                        CompactItemCard(item: item, theme: theme)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Compact Item Card
struct CompactItemCard: View {
    let item: ItemEntity
    let theme: Theme

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                if let iconName = item.iconName {
                    Image(iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                } else {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 32))
                        .foregroundColor(theme.textColor.opacity(0.5))
                }
            }

            Text(item.name ?? "Unknown")
                .font(.appFont(size: 10, weight: .medium))
                .foregroundColor(theme.textColor)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(theme.backgroundColor.opacity(0.7))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
        .frame(width: 70, height: 70)
    }
}

// MARK: - Boosters Section View
struct BoostersSectionView: View {
    @ObservedObject var boosterManager: BoosterManager
    @Binding var showBoosterInfo: Bool
    let theme: Theme

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Active Boosters")
                    .font(.appFont(size: 20, weight: .bold))
                    .foregroundColor(theme.textColor)
                Spacer()
                Button(action: {
                    showBoosterInfo = true
                }) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 16))
                        .foregroundColor(theme.textColor.opacity(0.7))
                }
            }

            if boosterManager.activeBoosters.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "bolt.slash")
                        .font(.system(size: 32))
                        .foregroundColor(theme.textColor.opacity(0.5))
                    Text("No active boosters")
                        .font(.appFont(size: 16))
                        .foregroundColor(theme.textColor.opacity(0.7))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.backgroundColor.opacity(0.7))
                )
            } else {
                VStack(spacing: 8) {
                    ForEach(boosterManager.activeBoosters, id: \.id) { booster in
                        BoosterCard(booster: booster, theme: theme)
                    }
                }
            }
        }
        .sheet(isPresented: $showBoosterInfo) {
            BoosterInfoModalView()
                .environmentObject(ThemeManager.shared)
        }
    }
}

// MARK: - Booster Card
struct BoosterCard: View {
    let booster: BoosterEffect
    let theme: Theme

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "bolt.fill")
                .font(.system(size: 20))
                .foregroundColor(.yellow)

            VStack(alignment: .leading, spacing: 4) {
                Text(booster.sourceName)
                    .font(.appFont(size: 14, weight: .medium))
                    .foregroundColor(theme.textColor)

                Text(booster.type.description)
                    .font(.appFont(size: 12))
                    .foregroundColor(theme.textColor.opacity(0.7))
            }

            Spacer()

            if let remainingTime = booster.remainingTime {
                Text("\(Int(remainingTime))s")
                    .font(.appFont(size: 12, weight: .medium))
                    .foregroundColor(theme.textColor.opacity(0.8))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(theme.backgroundColor.opacity(0.7))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
}

// MARK: - Shop Button View
struct ShopButtonView: View {
    @Binding var showShop: Bool
    let theme: Theme

    var body: some View {
        Button(action: {
            showShop = true
        }) {
            HStack(spacing: 8) {
                Image(systemName: "cart.fill")
                    .font(.system(size: 16))
                Text("Visit Shop")
                    .font(.appFont(size: 16, weight: .medium))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(theme.primaryColor)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Color Option Card
struct ColorOptionCard: View {
    let color: Color
    let isSelected: Bool
    let onTap: () -> Void
    let theme: Theme

    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Color circle
                Circle()
                    .fill(color)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? theme.accentColor : theme.borderColor.opacity(0.3), lineWidth: isSelected ? 3 : 1)
                    )
                    .shadow(color: theme.shadowColor, radius: 4, x: 0, y: 2)

                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}


// MARK: - Particle Background

struct ParticleBackground: View {
    var color: Color
    var count: Int
    var sizeRange: ClosedRange<CGFloat>
    var speedRange: ClosedRange<Double>

    var body: some View {
        GeometryReader { geo in
            ForEach(0..<count, id: \.self) { _ in
                let size = CGFloat.random(in: sizeRange)
                let xPos = CGFloat.random(in: 0...geo.size.width)

                let startY = CGFloat.random(in: geo.size.height...(geo.size.height + 100))

                let endYPosition: CGFloat = -geo.size.height * 1.5

                let speed = Double.random(in: speedRange) * 1.8

                Circle()
                    .fill(color)
                    .frame(width: size, height: size)
                    .position(x: xPos, y: startY)
                    .modifier(VerticalFloat(from: startY, to: endYPosition, duration: speed))
            }
        }
    }
}

struct VerticalFloat: ViewModifier {
    @State private var y: CGFloat
    var endYPosition: CGFloat
    var duration: Double

    init(from startY: CGFloat, to endY: CGFloat, duration: Double) {
        self._y = State(initialValue: startY)
        self.endYPosition = endY
        self.duration = duration
    }

    func body(content: Content) -> some View {
        content
            .offset(y: y)
            .onAppear {
                withAnimation(Animation.linear(duration: duration).repeatForever(autoreverses: false)) {
                    y = endYPosition
                }
            }
    }
}

// MARK: - Character Tab Customization View
struct CharacterTabCustomizationView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    @StateObject private var customizationManager = CharacterCustomizationManager()
    @State private var selectedCategory: CustomizationCategory = .bodyType
    @State private var originalCustomization: CharacterCustomization?
    @State private var hasChanges = false
    @State private var selectedHairType: String = "hair1" // Track selected hair type for color filtering
    let user: UserEntity

    // Only include allowed categories for character tab customization
    private let allowedCategories: [CustomizationCategory] = [
        .bodyType, .hairStyle, .hairColor, .eyeColor
    ]

    var body: some View {
        let theme = themeManager.activeTheme

        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.backgroundColor)

            VStack(spacing: 0) {
                // Header
                headerView(theme: theme)

                // Character Preview
                characterPreviewView(theme: theme)

                // Category Selector
                categorySelectorView(theme: theme)

                // Options Grid
                optionsGridView(theme: theme)

                // Save Button
                saveButtonView(theme: theme)
            }
            .padding()
        }
        .onAppear {
            loadCurrentCustomization()
        }
    }

    // MARK: - Header View
    @ViewBuilder
    private func headerView(theme: Theme) -> some View {
        VStack(spacing: 16) {
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .font(.appFont(size: 16, weight: .medium))
                .foregroundColor(theme.textColor.opacity(0.7))

                Spacer()

                Text("Customize Character")
                    .font(.appFont(size: 18, weight: .bold))
                    .foregroundColor(theme.textColor)

                Spacer()

                Button("Save") {
                    saveCustomization()
                }
                .font(.appFont(size: 16, weight: .medium))
                .foregroundColor(hasChanges ? theme.accentColor : theme.textColor.opacity(0.3))
                .disabled(!hasChanges)
            }
            .padding(.horizontal)

            Text("Customize your character's appearance")
                .font(.appFont(size: 14))
                .foregroundColor(theme.textColor.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, 20)
    }

    // MARK: - Character Preview View
    @ViewBuilder
    private func characterPreviewView(theme: Theme) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.cardBackgroundColor)
                .shadow(color: theme.textColor.opacity(0.1), radius: 8, x: 0, y: 4)

            VStack(spacing: 12) {
                // Character Image Stack
                ZStack {
                    // Body
                    Image(customizationManager.currentCustomization.bodyType.rawValue)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 240) // 2x bigger (was 120)

                    // Hair - Use the actual hair style image (not tinted)
                    Image(customizationManager.currentCustomization.hairStyle.rawValue)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 240) // 2x bigger (was 120)

                    // Eyes
                    Image(customizationManager.currentCustomization.eyeColor.rawValue)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 240) // 2x bigger (was 120)
                }

                Text("Preview")
                    .font(.appFont(size: 16, weight: .medium))
                    .foregroundColor(theme.textColor)
            }
            .padding()
        }
        .frame(height: 300) // Increased container height to accommodate larger character
    }

    // MARK: - Category Selector View
    @ViewBuilder
    private func categorySelectorView(theme: Theme) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(allowedCategories, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                    }) {
                        Text(category.title)
                            .font(.appFont(size: 14, weight: .medium))
                            .foregroundColor(selectedCategory == category ? theme.accentColor : theme.textColor.opacity(0.7))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selectedCategory == category ? theme.accentColor.opacity(0.2) : Color.clear)
                            )
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
    }

    // MARK: - Options Grid View
    @ViewBuilder
    private func optionsGridView(theme: Theme) -> some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                switch selectedCategory {
                case .bodyType:
                    ForEach(BodyType.allCases, id: \.self) { bodyType in
                        ColorOptionCard(
                            color: bodyType.color,
                            isSelected: customizationManager.currentCustomization.bodyType == bodyType,
                            onTap: {
                                customizationManager.updateBodyType(bodyType)
                                checkForChanges()
                            },
                            theme: theme
                        )
                    }
                case .hairStyle:
                    // Show unique hair types (not individual color variants) - ordered from 1 to 13
                    ForEach(HairStyle.uniqueHairTypes.sorted { hairType1, hairType2 in
                        let num1 = Int(hairType1.replacingOccurrences(of: "hair", with: "")) ?? 0
                        let num2 = Int(hairType2.replacingOccurrences(of: "hair", with: "")) ?? 0
                        return num1 < num2
                    }, id: \.self) { hairType in
                        let defaultStyle = HairStyle.getDefaultStyle(for: hairType)
                        CustomizationOptionCard(
                            option: CustomizationOption(
                                id: hairType,
                                name: "", // Empty name to hide text
                                imageName: defaultStyle.previewImageName,
                                isPremium: false,
                                isUnlocked: true
                            ),
                            isSelected: selectedHairType == hairType,
                            onTap: {
                                selectedHairType = hairType
                                // Update to the default style for this hair type
                                let newStyle = HairStyle.getDefaultStyle(for: hairType)
                                customizationManager.updateHairStyle(newStyle)
                                checkForChanges()
                            },
                            theme: theme
                        )
                    }
                case .hairColor:
                    // Show available colors for the selected hair type
                    ForEach(HairStyle.getAvailableColorsForType(selectedHairType), id: \.self) { hairColor in
                        // Find the hair style for this type and color
                        if let hairStyle = HairStyle.getStyle(for: selectedHairType, color: hairColor) {
                            ColorOptionCard(
                                color: hairColor.color,
                                isSelected: customizationManager.currentCustomization.hairStyle == hairStyle,
                                onTap: {
                                    customizationManager.updateHairStyle(hairStyle)
                                    checkForChanges()
                                },
                                theme: theme
                            )
                        }
                    }
                case .eyeColor:
                    ForEach(EyeColor.allCases, id: \.self) { eyeColor in
                        CustomizationOptionCard(
                            option: CustomizationOption(
                                id: eyeColor.rawValue,
                                name: eyeColor.displayName,
                                imageName: eyeColor.previewImageName,
                                isPremium: eyeColor.isPremium,
                                isUnlocked: true
                            ),
                            isSelected: customizationManager.currentCustomization.eyeColor == eyeColor,
                            onTap: {
                                customizationManager.updateEyeColor(eyeColor)
                                checkForChanges()
                            },
                            theme: theme
                        )
                    }
                default:
                    EmptyView()
                }
            }
            .padding(.horizontal)
        }
        .frame(maxHeight: 300)
    }

    // MARK: - Save Button View
    @ViewBuilder
    private func saveButtonView(theme: Theme) -> some View {
        Button(action: {
            saveCustomization()
        }) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18))
                Text("Save Changes")
                    .font(.appFont(size: 16, weight: .medium))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(hasChanges ? theme.accentColor : theme.textColor.opacity(0.3))
            )
        }
        .disabled(!hasChanges)
        .padding(.horizontal)
        .padding(.top, 20)
    }

    // MARK: - Helper Methods
    private func loadCurrentCustomization() {
        // Load current customization from service
        let customizationService = CharacterCustomizationService()
        if let entity = customizationService.fetchCustomization(for: user) {
            let currentCustomization = entity.toCharacterCustomization()
            customizationManager.currentCustomization = currentCustomization
            originalCustomization = currentCustomization

            // Set the selected hair type based on current hair style
            selectedHairType = currentCustomization.hairStyle.hairType
        } else {
            // If no customization exists, create a default one and save it
            let defaultCustomization = CharacterCustomization()
            customizationManager.currentCustomization = defaultCustomization
            originalCustomization = defaultCustomization
            selectedHairType = defaultCustomization.hairStyle.hairType

            // Save the default customization
            _ = customizationService.createCustomization(for: user, customization: defaultCustomization)
        }
    }

    private func checkForChanges() {
        guard let original = originalCustomization else { return }
        let current = customizationManager.currentCustomization

        hasChanges = original.bodyType != current.bodyType ||
                    original.hairStyle != current.hairStyle ||
                    original.hairColor != current.hairColor ||
                    original.eyeColor != current.eyeColor
    }

    private func saveCustomization() {
        guard hasChanges else { return }

        // Create a new customization that preserves outfit, weapon, accessory
        var updatedCustomization = customizationManager.currentCustomization

        // Preserve the original outfit, weapon, and accessory if they exist
        if let original = originalCustomization {
            updatedCustomization.outfit = original.outfit
            updatedCustomization.weapon = original.weapon
            updatedCustomization.accessory = original.accessory
            updatedCustomization.mustache = original.mustache
            updatedCustomization.flower = original.flower
            updatedCustomization.hairBackStyle = original.hairBackStyle
        }

        // Save the updated customization
        let customizationService = CharacterCustomizationService()
        _ = customizationService.updateCustomization(for: user, customization: updatedCustomization)

        // Post notification to refresh character view
        NotificationCenter.default.post(name: .characterCustomizationUpdated, object: nil)

        // Dismiss the view
        dismiss()
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let characterCustomizationUpdated = Notification.Name("characterCustomizationUpdated")
}
