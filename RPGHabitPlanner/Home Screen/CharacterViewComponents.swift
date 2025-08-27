//
//  CharacterViewComponents.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 5.08.2025.
//

import SwiftUI
import CoreData

// MARK: - Inventory Categories

enum InventoryCategory: String, CaseIterable {
    case head = "head"
    case weapon = "weapon"
    case shield = "shield"
    case outfit = "outfit"
    case pet = "pet"
    case wings = "wings"
    case others = "others"

    var localizedName: String {
        switch self {
        case .head: return "head".localized
        case .weapon: return "weapon".localized
        case .shield: return "shield".localized
        case .outfit: return "outfit".localized
        case .pet: return "pet".localized
        case .wings: return "wings".localized
        case .others: return "others".localized
        }
    }

    var icon: String {
        switch self {
        case .head: return "icon_helmet"
        case .weapon: return "icon_sword"
        case .shield: return "icon_shield"
        case .outfit: return "icon_armor"
        case .pet: return "pawprint.fill"
        case .wings: return "icon_wing"
        case .others: return "flask.fill"
        }
    }

    var description: String {
        switch self {
        case .head: return "inventory_category_head_description".localized
        case .weapon: return "inventory_category_weapon_description".localized
        case .shield: return "inventory_category_shield_description".localized
        case .outfit: return "inventory_category_outfit_description".localized
        case .pet: return "inventory_category_pet_description".localized
        case .wings: return "inventory_category_wings_description".localized
        case .others: return "inventory_category_others_description".localized
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
                            if category.icon.hasPrefix("icon_") {
                                Image(category.icon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                                    .foregroundColor(selectedCategory == category ? theme.accentColor : theme.textColor.opacity(0.7))
                            } else {
                                Image(systemName: category.icon)
                                    .font(.system(size: 16))
                                    .foregroundColor(selectedCategory == category ? theme.accentColor : theme.textColor.opacity(0.7))
                            }

                            Text(category.localizedName)
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
                    if isEquipped, let equippedItem = equippedItem, let previewImage = equippedItem.previewImage {
                        // Show preview image for equipped item
                        Image(previewImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                    } else if isEquipped {
                        // Fallback to system icon if no custom icon
                        if iconName.hasPrefix("icon_") {
                            Image(iconName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundColor(theme.textColor)
                        } else {
                            Image(systemName: iconName)
                                .font(.system(size: 24))
                                .foregroundColor(theme.textColor)
                        }
                    } else {
                        // Placeholder for unequipped slot
                        if iconName.hasPrefix("icon_") {
                            Image(iconName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(theme.textColor.opacity(0.3))
                        } else {
                            Image(systemName: iconName)
                                .font(.system(size: 20))
                                .foregroundColor(theme.textColor.opacity(0.3))
                        }
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
                Text("\("level".localized) \(user.level)")
                    .font(.appFont(size: 18))
                    .foregroundColor(theme.textColor)
                Spacer()
            }

            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(theme.secondaryColor.opacity(0.7))
                    .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
                    .frame(height: 22)

                GeometryReader { geometry in
                    let levelingSystem = LevelingSystem.shared
                    let totalExperience = levelingSystem.calculateTotalExperience(level: Int(user.level), experienceInLevel: Int(user.exp))
                    let progress = levelingSystem.calculateLevelProgress(totalExperience: totalExperience, currentLevel: Int(user.level))
                    let expRatio = min(CGFloat(progress), 1.0)
                    
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
                    let levelingSystem = LevelingSystem.shared
                    let experienceRequiredForNextLevel = levelingSystem.experienceRequiredForNextLevel(from: Int(user.level))
                    Text("\(user.exp)/\(experienceRequiredForNextLevel)")
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
    @State private var selectedCategory: InventoryCategory = .head

    let theme: Theme

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("inventory".localized)
                    .font(.appFont(size: 20, weight: .bold))
                    .foregroundColor(theme.textColor)
                Spacer()
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
    }
}

// MARK: - Items Preview View
struct ItemsPreviewView: View {
    let category: InventoryCategory
    @ObservedObject var inventoryManager: InventoryManager
    let theme: Theme
    @State private var refreshTrigger = false

    // Define grid columns for inventory layout
    private let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 4), count: 4)

    var filteredItems: [ItemEntity] {
        switch category {
        case .head, .weapon, .shield, .outfit, .pet, .wings:
            return inventoryManager.inventoryItems.filter { item in
                guard inventoryManager.isGear(item) else { return false }
                if let gearCategory = inventoryManager.getGearCategory(item) {
                    let targetCategory: GearCategory
                    switch category {
                    case .head: targetCategory = .head
                    case .weapon: targetCategory = .weapon
                    case .shield: targetCategory = .shield
                    case .outfit: targetCategory = .outfit
                    case .pet: targetCategory = .pet
                    case .wings: targetCategory = .wings
                    case .others: return false
                    }
                    return gearCategory == targetCategory
                }
                return false
            }
        case .others:
            return inventoryManager.inventoryItems.filter {
                inventoryManager.isConsumable($0) || inventoryManager.isBooster($0) || inventoryManager.isCollectible($0)
            }
        }
    }

    var body: some View {
        Group {
            if filteredItems.isEmpty {
                VStack(spacing: 8) {
                    if category.icon.hasPrefix("icon_") {
                        Image(category.icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(theme.textColor.opacity(0.5))
                    } else {
                        Image(systemName: category.icon)
                            .font(.system(size: 24))
                            .foregroundColor(theme.textColor.opacity(0.5))
                    }
                    
                    Text("no_items_for_category".localized(with: category.localizedName))
                        .font(.appFont(size: 14))
                        .foregroundColor(theme.textColor.opacity(0.7))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.backgroundColor.opacity(0.7))
                )
            } else {
                // Inventory Grid Layout
                LazyVGrid(columns: columns, spacing: 4) {
                    ForEach(filteredItems.prefix(4), id: \.id) { item in
                        InventoryGridItemView(item: item, theme: theme)
                    }

                    // Add empty slots to complete the first row (4 slots total)
                    ForEach(0..<max(0, 4 - filteredItems.count), id: \.self) { _ in
                        EmptyInventorySlotView(theme: theme)
                    }
                    
                    // Show additional items if there are more than 4
                    if filteredItems.count > 4 {
                        ForEach(Array(filteredItems.dropFirst(4).prefix(8)), id: \.id) { item in
                            InventoryGridItemView(item: item, theme: theme)
                        }
                        
                        // Add empty slots to complete additional rows if needed
                        let remainingSlots = max(0, 12 - filteredItems.count)
                        ForEach(0..<remainingSlots, id: \.self) { _ in
                            EmptyInventorySlotView(theme: theme)
                        }
                    }
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.surfaceColor.opacity(0.6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(theme.borderColor.opacity(0.3), lineWidth: 1)
                        )
                )
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .languageChanged)) { _ in
            // Trigger a refresh when language changes
            refreshTrigger.toggle()
        }
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

// MARK: - Health Bar Section (matching home view hero section)
struct HealthBarSection: View {
    @ObservedObject var healthManager: HealthManager
    let theme: Theme

    var body: some View {
        VStack(spacing: 4) {
            healthBarHeader(healthManager: healthManager, theme: theme)
            healthBarVisual(healthManager: healthManager)
        }
    }

    @ViewBuilder
    private func healthBarHeader(healthManager: HealthManager, theme: Theme) -> some View {
        HStack {
            Image(systemName: "heart.fill")
                .font(.system(size: 12))
                .foregroundColor(.red)
            Text("health".localized)
                .font(.appFont(size: 12, weight: .bold))
                .foregroundColor(theme.textColor)
            Spacer()
            Text("\(healthManager.currentHealth)/\(healthManager.maxHealth)")
                .font(.appFont(size: 11, weight: .black))
                .foregroundColor(theme.textColor)
        }
    }

    @ViewBuilder
    private func healthBarVisual(healthManager: HealthManager) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.red.opacity(0.2))
                    .frame(height: 12)

                let healthPercentage = healthManager.getHealthPercentage()
                let healthGradient = LinearGradient(
                    colors: [Color.red, Color.red.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                RoundedRectangle(cornerRadius: 6)
                    .fill(healthGradient)
                    .frame(width: geometry.size.width * healthPercentage, height: 12)
                    .animation(.easeOut(duration: 0.5), value: healthPercentage)
            }
        }
        .frame(height: 12)
    }
}

// MARK: - Experience Bar Section (matching home view hero section)
struct ExperienceBarSection: View {
    let user: UserEntity
    let theme: Theme

    var body: some View {
        VStack(spacing: 4) {
            experienceBarHeader(user: user, theme: theme)
            experienceBarVisual(user: user, theme: theme)
        }
    }

    @ViewBuilder
    private func experienceBarHeader(user: UserEntity, theme: Theme) -> some View {
        HStack {
            Image("icon_lightning")
                .resizable()
                .frame(width: 12, height: 12)
                .foregroundColor(.yellow)
            Text("experience".localized)
                .font(.appFont(size: 12, weight: .bold))
                .foregroundColor(theme.textColor)
            Spacer()
            let levelingSystem = LevelingSystem.shared
            let expRequiredForNextLevel = levelingSystem.experienceRequiredForNextLevel(from: Int(user.level))
            Text("\(user.exp)/\(expRequiredForNextLevel)")
                .font(.appFont(size: 11, weight: .black))
                .foregroundColor(theme.textColor)
        }
    }

    @ViewBuilder
    private func experienceBarVisual(user: UserEntity, theme: Theme) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(theme.secondaryColor.opacity(0.7))
                    .frame(height: 12)

                let levelingSystem = LevelingSystem.shared
                let totalExperience = levelingSystem.calculateTotalExperience(level: Int(user.level), experienceInLevel: Int(user.exp))
                let progress = levelingSystem.calculateLevelProgress(totalExperience: totalExperience, currentLevel: Int(user.level))
                let expRatio = min(CGFloat(progress), 1.0)
                let expGradient = LinearGradient(
                    colors: [Color.green, Color.green.opacity(0.7)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                RoundedRectangle(cornerRadius: 6)
                    .fill(expGradient)
                    .frame(width: geometry.size.width * expRatio, height: 12)
                    .animation(.easeInOut(duration: 0.5), value: expRatio)
            }
        }
        .frame(height: 12)
    }
}
