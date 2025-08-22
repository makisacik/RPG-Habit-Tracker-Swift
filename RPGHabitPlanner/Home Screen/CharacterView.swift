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
        }
        .onReceive(NotificationCenter.default.publisher(for: .boostersUpdated)) { _ in
            print("🔄 CharacterView: Received boostersUpdated notification")
            refreshTrigger.toggle()
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

    var body: some View {
        let theme = themeManager.activeTheme

        ZStack {
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

            VStack(spacing: 16) {
                // Use reusable character display component with larger size
                CharacterDisplayView(
                    customization: characterCustomization,
                    size: 200,
                    showShadow: true
                )

                VStack(spacing: 8) {
                    Text(user.nickname ?? "Unknown")
                        .font(.appFont(size: 28, weight: .black))
                        .foregroundColor(theme.textColor)

                    Text("Custom Character")
                        .font(.appFont(size: 18))
                        .foregroundColor(theme.textColor)

                    // Customize Button
                    Button(action: {
                        showCustomizationModal = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 16))
                            Text("Customize")
                                .font(.appFont(size: 14, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(theme.primaryColor)
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 20)
        }
        .frame(height: 320)
        .clipped()
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
    let theme: Theme

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Inventory")
                    .font(.appFont(size: 20, weight: .bold))
                    .foregroundColor(theme.textColor)
                Spacer()
                Text("\(inventoryManager.inventoryItems.count) items")
                    .font(.appFont(size: 14))
                    .foregroundColor(theme.textColor.opacity(0.7))
            }

            if inventoryManager.inventoryItems.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "bag")
                        .font(.system(size: 32))
                        .foregroundColor(theme.textColor.opacity(0.5))
                    Text("No items yet")
                        .font(.appFont(size: 16))
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
                        ForEach(inventoryManager.inventoryItems.prefix(5), id: \.id) { item in
                            ItemCard(item: item, theme: theme)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

// MARK: - Item Card
struct ItemCard: View {
    let item: ItemEntity
    let theme: Theme

    var body: some View {
        VStack(spacing: 8) {
            if let iconName = item.iconName {
                Image(iconName)
                    .resizable()
                    .frame(width: 32, height: 32)
            } else {
                Image(systemName: "questionmark.circle")
                    .font(.system(size: 32))
                    .foregroundColor(theme.textColor.opacity(0.5))
            }

            Text(item.name ?? "Unknown")
                .font(.appFont(size: 12, weight: .medium))
                .foregroundColor(theme.textColor)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(theme.backgroundColor.opacity(0.7))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
        .frame(width: 80)
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
                        .frame(height: 120)

                    // Hair
                    Image(customizationManager.currentCustomization.hairStyle.rawValue)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 120)

                    // Eyes
                    Image(customizationManager.currentCustomization.eyeColor.rawValue)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 120)
                }

                Text("Preview")
                    .font(.appFont(size: 16, weight: .medium))
                    .foregroundColor(theme.textColor)
            }
            .padding()
        }
        .frame(height: 180)
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
                        CustomizationOptionCard(
                            option: CustomizationOption(
                                id: bodyType.rawValue,
                                name: bodyType.displayName,
                                imageName: bodyType.previewImageName,
                                isPremium: bodyType.isPremium,
                                isUnlocked: true
                            ),
                            isSelected: customizationManager.currentCustomization.bodyType == bodyType,
                            onTap: {
                                customizationManager.updateBodyType(bodyType)
                                checkForChanges()
                            },
                            theme: theme
                        )
                    }
                case .hairStyle:
                    ForEach(HairStyle.allCases, id: \.self) { hairStyle in
                        CustomizationOptionCard(
                            option: CustomizationOption(
                                id: hairStyle.rawValue,
                                name: hairStyle.displayName,
                                imageName: hairStyle.previewImageName,
                                isPremium: hairStyle.isPremium,
                                isUnlocked: true
                            ),
                            isSelected: customizationManager.currentCustomization.hairStyle == hairStyle,
                            onTap: {
                                customizationManager.updateHairStyle(hairStyle)
                                checkForChanges()
                            },
                            theme: theme
                        )
                    }
                case .hairColor:
                    ForEach(HairColor.allCases, id: \.self) { hairColor in
                        CustomizationOptionCard(
                            option: CustomizationOption(
                                id: hairColor.rawValue,
                                name: hairColor.displayName,
                                imageName: hairColor.previewImageName,
                                isPremium: hairColor.isPremium,
                                isUnlocked: true
                            ),
                            isSelected: customizationManager.currentCustomization.hairColor == hairColor,
                            onTap: {
                                customizationManager.updateHairColor(hairColor)
                                checkForChanges()
                            },
                            theme: theme
                        )
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
        
        // Dismiss the view
        dismiss()
    }
}
