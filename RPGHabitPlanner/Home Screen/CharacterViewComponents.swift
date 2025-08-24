//
//  CharacterViewComponents.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 5.08.2025.
//

import SwiftUI

// MARK: - Inventory Categories

enum InventoryCategory: String, CaseIterable {
    case head = "Head"
    case weapon = "Weapon"
    case shield = "Shield"
    case outfit = "Outfit"
    case pet = "Pet"
    case wings = "Wings"
    case others = "Others"

    var icon: String {
        switch self {
        case .head: return "helmet"
        case .weapon: return "sword.fill"
        case .shield: return "shield.fill"
        case .outfit: return "tshirt.fill"
        case .pet: return "pawprint.fill"
        case .wings: return "airplane"
        case .others: return "flask.fill"
        }
    }

    var description: String {
        switch self {
        case .head: return "Helmets and headgear"
        case .weapon: return "Weapons and combat items"
        case .shield: return "Shields and defensive gear"
        case .outfit: return "Clothing and armor"
        case .pet: return "Companion pets"
        case .wings: return "Wings and flight items"
        case .others: return "Boosters, potions, collectibles"
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
    @State private var selectedCategory: InventoryCategory = .head

    let theme: Theme

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Inventory")
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
