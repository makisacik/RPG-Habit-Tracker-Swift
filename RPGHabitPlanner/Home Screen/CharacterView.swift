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
    @State private var refreshTrigger = false
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
                        CompactBoostersSectionView(
                            boosterManager: boosterManager,
                            theme: theme
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
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
            inventoryManager.refreshInventory()
        }
    }

    private func fetchCharacterCustomization() {
        if let customizationEntity = customizationService.fetchCustomization(for: user) {
            self.characterCustomization = customizationEntity.toCharacterCustomization()
            print("✅ CharacterView: Loaded character customization")
            print("🔧 CharacterView: Current outfit: \(characterCustomization?.outfit?.rawValue ?? "nil")")
        } else {
            // Try to migrate from UserDefaults if no Core Data customization exists
            let customizationManager = CharacterCustomizationManager()
            if let migratedEntity = customizationService.migrateFromUserDefaults(for: user, manager: customizationManager) {
                self.characterCustomization = migratedEntity.toCharacterCustomization()
                print("✅ CharacterView: Successfully migrated character customization from UserDefaults to Core Data")
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
    @StateObject private var backgroundManager = CharacterBackgroundManager.shared
    @State private var showBackgroundSelectionModal = false
    
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
                        slotType: "gear_slot_head".localized,
                        iconName: "icon_helmet",
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
                        slotType: "gear_slot_outfit".localized,
                        iconName: "icon_armor",
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
                        slotType: "gear_slot_wings".localized,
                        iconName: "icon_wing",
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
                VStack(spacing: 8) {
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
                        if let backgroundImageName = backgroundManager.getBackgroundImageName() {
                            GeometryReader { proxy in
                                Image(backgroundImageName)
                                    .resizable()
                                    .scaledToFill() // covers the whole card
                                    .frame(width: proxy.size.width, height: proxy.size.height)
                                    .clipped() // remove the overflow from scaledToFill
                                    .opacity(0.30)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: corner))
                        }

                        CharacterDisplayView(
                            customization: characterCustomization,
                            size: 200,
                            showShadow: true,
                            hideHairWithHelmet: true
                        )
                        .id("character-display-\(characterCustomization?.shield?.rawValue ?? "nil")-\(characterCustomization?.pet?.rawValue ?? "nil")")
                        .offset(y: 70)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(theme.borderColor.opacity(0.12), lineWidth: 1)
                    )
                    .frame(width: 200, height: 270)

                    // Action Buttons
                    HStack(spacing: 12) {
                        Button(action: {
                            showCustomizationModal = true
                        }) {
                            Image(systemName: "paintbrush.fill")
                                .font(.system(size: 16))
                                .foregroundColor(theme.textColor.opacity(0.7))
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle()
                                        .fill(theme.cardBackgroundColor)
                                )
                        }

                        Button(action: {
                            showBackgroundSelectionModal = true
                        }) {
                            Image(systemName: "photo.fill")
                                .font(.system(size: 16))
                                .foregroundColor(theme.textColor.opacity(0.7))
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle()
                                        .fill(theme.cardBackgroundColor)
                                )
                        }
                    }
                }

                // Right Equipment Slots
                VStack(spacing: 16) {
                    EquipmentSlotView(
                        slotType: "gear_slot_weapon".localized,
                        iconName: "icon_sword",
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
                        slotType: "gear_slot_shield".localized,
                        iconName: "icon_shield",
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
                        slotType: "gear_slot_pet".localized,
                        iconName: "pawprint.fill",
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
        .frame(height: 320)
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
        .sheet(isPresented: $showBackgroundSelectionModal) {
            CharacterBackgroundSelectionView()
                .environmentObject(themeManager)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
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


// MARK: - Notification Names
extension Notification.Name {
    static let characterCustomizationUpdated = Notification.Name("characterCustomizationUpdated")
    static let navigateToShopTab = Notification.Name("navigateToShopTab")
}
