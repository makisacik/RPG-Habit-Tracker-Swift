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

    let item: ItemEntity
    @State private var isUsingItem = false
    @State private var showSuccessMessage = false
    @State private var showErrorMessage = false
    @State private var errorMessage = ""
    private var itemDefinition: Item? {
        guard let iconName = item.iconName else { return nil }
        return ItemDatabase.shared.findItem(byIconName: iconName)
    }

    private var canUseItem: Bool {
        guard let definition = itemDefinition else { return false }
        return definition.itemType == .consumable || definition.itemType == .booster
    }

    private var canEquipItem: Bool {
        guard let definition = itemDefinition else { return false }
        return definition.itemType == .gear
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
                            itemDefinition: itemDefinition,
                            theme: theme
                        )

                        // Item Effects (if any)
                        if let definition = itemDefinition, let effects = definition.effects, !effects.isEmpty {
                            ItemEffectsView(effects: effects, theme: theme)
                        }

                        // Usage Information
                        if let definition = itemDefinition {
                            UsageInfoView(definition: definition, theme: theme)
                        }

                        Spacer(minLength: 50)
                    }
                    .padding()
                }
            }
            .navigationTitle("Item Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(theme.textColor)
                }

                if canUseItem {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Use") {
                            useItem()
                        }
                        .foregroundColor(theme.textColor)
                        .disabled(isUsingItem)
                    }
                }

                if canEquipItem {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Equip") {
                            equipItem()
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
                        message: canEquipItem ? "Item equipped successfully!" : "Item used successfully!"
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
        if let rarityString = item.rarity {
            return ItemRarity(rawValue: rarityString)
        }
        return itemDefinition?.rarity
    }

    private func useItem() {
        guard canUseItem else { return }

        isUsingItem = true

        inventoryManager.useItem(item) { success, error in
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
                    self.errorMessage = error?.localizedDescription ?? "Failed to use item"
                    self.showErrorMessage = true

                    // Auto-dismiss error after 3 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        self.showErrorMessage = false
                    }
                }
            }
        }
    }

    private func equipItem() {
        guard canEquipItem else { return }

        isUsingItem = true

        inventoryManager.equipItem(item) { success, error in
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
                    self.errorMessage = error?.localizedDescription ?? "Failed to equip item"
                    self.showErrorMessage = true

                    // Auto-dismiss error after 3 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        self.showErrorMessage = false
                    }
                }
            }
        }
    }
}

#Preview {
    ItemDetailSheet(item: ItemEntity())
        .environmentObject(ThemeManager.shared)
        .environmentObject(InventoryManager.shared)
}
