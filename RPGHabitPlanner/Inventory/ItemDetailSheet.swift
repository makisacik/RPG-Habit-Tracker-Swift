//
//  ItemDetailSheet.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI

struct ItemDetailSheet: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var inventoryManager: InventoryManager
    @Environment(\.dismiss) private var dismiss

    let item: Item
    @State private var isUsingItem = false
    @State private var showSuccessMessage = false
    @State private var showErrorMessage = false
    @State private var errorMessage = ""

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
                    Button(String(localized: "close")) {
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
                        Button("equip".localized) {
                            Task {
                                await equipItem()
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
                        message: canEquipItem ? String(localized: "item_equipped_successfully") : String(localized: "item_used_successfully")
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
    }

    // MARK: - Helper Methods

    private func getItemRarity() -> ItemRarity? {
        return item.rarity
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
                        self.errorMessage = error?.localizedDescription ?? String(localized: "failed_to_use_item")
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
            errorMessage = String(localized: "item_not_found_in_inventory")
            showErrorMessage = true

            // Auto-dismiss error after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                showErrorMessage = false
            }
        }
    }

    private func equipItem() {
        guard canEquipItem else { return }

        isUsingItem = true

        // Find the corresponding ItemEntity in inventory
        if let itemEntity = inventoryManager.inventoryItems.first(where: { $0.iconName == item.iconName }) {
            inventoryManager.equipItem(itemEntity) { success, error in
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
                        self.errorMessage = error?.localizedDescription ?? String(localized: "failed_to_equip_item")
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
            errorMessage = String(localized: "item_not_found_in_inventory")
            showErrorMessage = true

            // Auto-dismiss error after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                showErrorMessage = false
            }
        }
    }
}
