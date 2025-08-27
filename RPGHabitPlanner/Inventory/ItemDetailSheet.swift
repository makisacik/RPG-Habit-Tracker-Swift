//
//  ItemDetailSheet.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI
import CoreData

struct ItemDetailSheet: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var inventoryManager: InventoryManager
    @Environment(\.dismiss) private var dismiss

    let item: Item
    @State private var isUsingItem = false
    @State private var showSuccessMessage = false
    @State private var showErrorMessage = false
    @State private var errorMessage = ""
    @State private var currentUser: UserEntity?
    @State private var isItemEquipped = false

    private var canUseItem: Bool {
        return item.itemType == .consumable || item.itemType == .booster
    }

    private var canEquipItem: Bool {
        return item.itemType == .gear
    }

    var body: some View {
        let theme = themeManager.activeTheme

        NavigationView {
            ZStack {
                theme.backgroundColor
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // Compact Item Header with Image, Type, and Description
                        CompactItemHeaderView(
                            item: item,
                            theme: theme
                        )

                        // Item Effects (if any)
                        if let effects = item.effects, !effects.isEmpty {
                            ItemEffectsView(effects: effects, theme: theme)
                        }

                        // Usage Information
                        UsageInfoView(definition: item, theme: theme)

                        Spacer(minLength: 50)
                    }
                    .padding()
                }
            }
            .navigationTitle("item_details".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("close".localized) {
                        dismiss()
                    }
                    .foregroundColor(theme.textColor)
                }

                if canUseItem {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("use".localized) {
                            Task {
                                await useItem()
                            }
                        }
                        .foregroundColor(theme.textColor)
                        .disabled(isUsingItem)
                    }
                }

                if canEquipItem {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(isItemEquipped ? "unequip".localized : "equip".localized) {
                            Task {
                                if isItemEquipped {
                                    await unequipItem()
                                } else {
                                    await equipItem()
                                }
                            }
                        }
                        .foregroundColor(theme.textColor)
                        .disabled(isUsingItem)
                    }
                }
            }
        }
        .overlay(
            // Success Message
            Group {
                if showSuccessMessage {
                    SuccessMessageOverlay(
                        theme: theme,
                        message: canEquipItem ?
                            (isItemEquipped ? "item_unequipped_successfully".localized : "item_equipped_successfully".localized) :
                            "item_used_successfully".localized
                    )
                }
            }
        )
        .overlay(
            // Error Message
            Group {
                if showErrorMessage {
                    ErrorMessageOverlay(errorMessage: errorMessage, theme: theme)
                }
            }
        )
        .animation(.easeInOut(duration: 0.3), value: showSuccessMessage)
        .animation(.easeInOut(duration: 0.3), value: showErrorMessage)
        .onAppear {
            loadUserAndCheckEquipmentStatus()
        }
        .onReceive(NotificationCenter.default.publisher(for: .gearUpdated)) { _ in
            // Refresh equipment status when gear is updated
            checkEquipmentStatus()
        }
    }

    // MARK: - Helper Methods

    private func getItemRarity() -> ItemRarity? {
        return item.rarity
    }

    private func loadUserAndCheckEquipmentStatus() {
        let userManager = UserManager()
        userManager.fetchUser { user, _ in
            DispatchQueue.main.async {
                if let user = user {
                    self.currentUser = user
                    self.checkEquipmentStatus()
                }
            }
        }
    }

    private func checkEquipmentStatus() {
        guard let itemEntity = inventoryManager.inventoryItems.first(where: { $0.iconName == item.iconName }) else {
            isItemEquipped = false
            return
        }

        isItemEquipped = GearManager.shared.isItemEquipped(itemEntity)
    }

    private func useItem() {
        guard canUseItem else { return }

        isUsingItem = true

        // Find the corresponding ItemEntity in inventory
        if let itemEntity = inventoryManager.inventoryItems.first(where: { $0.iconName == item.iconName }) {
            inventoryManager.useItem(itemEntity) { success, error in
                DispatchQueue.main.async {
                    self.isUsingItem = false

                    if success {
                        self.showSuccessMessage = true

                        // Auto-dismiss after 2 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            self.showSuccessMessage = false
                            self.dismiss()
                        }
                    } else {
                        self.errorMessage = error?.localizedDescription ?? "failed_to_use_item".localized
                        self.showErrorMessage = true

                        // Auto-dismiss error after 3 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            self.showErrorMessage = false
                        }
                    }
                }
            }
                } else {
            // Item not found in inventory
            isUsingItem = false
            errorMessage = "item_not_found_in_inventory".localized
            showErrorMessage = true

            // Auto-dismiss error after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                showErrorMessage = false
            }
        }
    }

    private func equipItem() {
        guard canEquipItem, let user = currentUser else { return }

        isUsingItem = true

        // Find the corresponding ItemEntity in inventory
        if let itemEntity = inventoryManager.inventoryItems.first(where: { $0.iconName == item.iconName }) {
            // Get the gear category for this item
            guard let gearCategory = getGearCategory(for: itemEntity) else {
                isUsingItem = false
                errorMessage = "invalid_gear_category".localized
                showErrorMessage = true
                return
            }

            // Use GearManager to equip the item
            GearManager.shared.equipItem(itemEntity, to: gearCategory, for: user)

            // Update UI
            DispatchQueue.main.async {
                self.isUsingItem = false
                self.showSuccessMessage = true
                self.checkEquipmentStatus()

                // Auto-dismiss after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.showSuccessMessage = false
                    self.dismiss()
                }
            }
        } else {
            // Item not found in inventory
            isUsingItem = false
            errorMessage = "item_not_found_in_inventory".localized
            showErrorMessage = true

            // Auto-dismiss error after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                showErrorMessage = false
            }
        }
    }

    private func unequipItem() {
        guard canEquipItem, let user = currentUser else { return }

        isUsingItem = true

        // Find the corresponding ItemEntity in inventory
        if let itemEntity = inventoryManager.inventoryItems.first(where: { $0.iconName == item.iconName }) {
            // Get the gear category for this item
            guard let gearCategory = getGearCategory(for: itemEntity) else {
                isUsingItem = false
                errorMessage = "invalid_gear_category".localized
                showErrorMessage = true
                return
            }

            // Use GearManager to unequip the item
            GearManager.shared.unequipItem(from: gearCategory, for: user)

            // Update UI
            DispatchQueue.main.async {
                self.isUsingItem = false
                self.showSuccessMessage = true
                self.checkEquipmentStatus()

                // Auto-dismiss after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.showSuccessMessage = false
                    self.dismiss()
                }
            }
        } else {
            // Item not found in inventory
            isUsingItem = false
            errorMessage = "item_not_found_in_inventory".localized
            showErrorMessage = true

            // Auto-dismiss error after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                showErrorMessage = false
            }
        }
    }

    private func getGearCategory(for item: ItemEntity) -> GearCategory? {
        // First try to get from Core Data
        if let gearCategoryString = item.gearCategory {
            return GearCategory(rawValue: gearCategoryString)
        }

        // Fallback to database lookup using icon name
        guard let iconName = item.iconName,
              let itemDefinition = ItemDatabase.findItem(byIconName: iconName) else {
            return nil
        }
        return itemDefinition.gearCategory
    }
}
