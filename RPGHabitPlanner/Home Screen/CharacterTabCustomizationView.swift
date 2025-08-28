//
//  CharacterTabCustomizationView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 5.08.2025.
//

import SwiftUI

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
        .bodyType, .hairStyle, .hairColor, .eyeColor, .accessory, .mustache, .flower
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
                Button("cancel".localized) {
                    dismiss()
                }
                .font(.appFont(size: 16, weight: .medium))
                .foregroundColor(theme.textColor.opacity(0.7))

                Spacer()

                Text("customize_character".localized)
                    .font(.appFont(size: 18, weight: .bold))
                    .foregroundColor(theme.textColor)

                Spacer()

                Button("save".localized) {
                    saveCustomization()
                }
                .font(.appFont(size: 16, weight: .medium))
                .foregroundColor(hasChanges ? theme.accentColor : theme.textColor.opacity(0.3))
                .disabled(!hasChanges)
            }
            .padding(.horizontal)

            Text("customize_your_character_appearance".localized)
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
                        .frame(height: 312) // 30% bigger (was 240)

                    // Hair - Use the actual hair style image (not tinted)
                    Image(customizationManager.currentCustomization.hairStyle.rawValue)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 312) // 30% bigger (was 240)

                    // Eyes
                    Image(customizationManager.currentCustomization.eyeColor.rawValue)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 312) // 30% bigger (was 240)

                    // Mustache
                    if let mustache = customizationManager.currentCustomization.mustache {
                        Image(mustache.rawValue)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 312)
                    }

                    // Flower
                    if let flower = customizationManager.currentCustomization.flower {
                        Image(flower.rawValue)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 312)
                    }

                    // Glasses (Accessory)
                    if let accessory = customizationManager.currentCustomization.accessory {
                        Image(accessory.rawValue)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 312)
                    }
                }
                .offset(y: -70) // Move character image 70 pixels up

                Text("preview".localized)
                    .font(.appFont(size: 16, weight: .medium))
                    .foregroundColor(theme.textColor)
            }
            .padding()
        }
        .frame(height: 370) // Increased container height to accommodate larger character (30% bigger + 70px offset)
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
                        Text(category.displayName)
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
                                imageName: defaultStyle.rawValue,
                                previewImage: defaultStyle.previewImageName,
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
                                imageName: eyeColor.rawValue,
                                previewImage: eyeColor.previewImageName,
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
                case .accessory:
                    // Show glasses options (filter out non-glasses accessories)
                    ForEach(Accessory.allCases.filter { $0.rawValue.contains("glass") }, id: \.self) { accessory in
                        CustomizationOptionCard(
                            option: CustomizationOption(
                                id: accessory.rawValue,
                                name: accessory.displayName,
                                imageName: accessory.rawValue,
                                previewImage: accessory.previewImageName,
                                isPremium: accessory.isPremium,
                                isUnlocked: true
                            ),
                            isSelected: customizationManager.currentCustomization.accessory == accessory,
                            onTap: {
                                // Toggle accessory - if same one is selected, remove it
                                if customizationManager.currentCustomization.accessory == accessory {
                                    customizationManager.updateAccessory(nil)
                                } else {
                                    customizationManager.updateAccessory(accessory)
                                }
                                checkForChanges()
                            },
                            theme: theme
                        )
                    }
                case .mustache:
                    ForEach(Mustache.allCases, id: \.self) { mustache in
                        CustomizationOptionCard(
                            option: CustomizationOption(
                                id: mustache.rawValue,
                                name: mustache.displayName,
                                imageName: mustache.rawValue,
                                previewImage: mustache.previewImageName,
                                isPremium: mustache.isPremium,
                                isUnlocked: true
                            ),
                            isSelected: customizationManager.currentCustomization.mustache == mustache,
                            onTap: {
                                // Toggle mustache - if same one is selected, remove it
                                if customizationManager.currentCustomization.mustache == mustache {
                                    customizationManager.updateMustache(nil)
                                } else {
                                    customizationManager.updateMustache(mustache)
                                }
                                checkForChanges()
                            },
                            theme: theme
                        )
                    }
                case .flower:
                    ForEach(Flower.allCases, id: \.self) { flower in
                        CustomizationOptionCard(
                            option: CustomizationOption(
                                id: flower.rawValue,
                                name: flower.displayName,
                                imageName: flower.rawValue,
                                previewImage: flower.previewImageName,
                                isPremium: flower.isPremium,
                                isUnlocked: true
                            ),
                            isSelected: customizationManager.currentCustomization.flower == flower,
                            onTap: {
                                // Toggle flower - if same one is selected, remove it
                                if customizationManager.currentCustomization.flower == flower {
                                    customizationManager.updateFlower(nil)
                                } else {
                                    customizationManager.updateFlower(flower)
                                }
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
                Text("save_changes".localized)
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
                    original.eyeColor != current.eyeColor ||
                    original.accessory != current.accessory ||
                    original.mustache != current.mustache ||
                    original.flower != current.flower
    }

    private func saveCustomization() {
        guard hasChanges else { return }

        // Use the current customization from the manager
        let updatedCustomization = customizationManager.currentCustomization

        // Save the updated customization
        let customizationService = CharacterCustomizationService()
        _ = customizationService.updateCustomization(for: user, customization: updatedCustomization)

        // Post notification to refresh character view
        NotificationCenter.default.post(name: .characterCustomizationUpdated, object: nil)

        // Dismiss the view
        dismiss()
    }
}
