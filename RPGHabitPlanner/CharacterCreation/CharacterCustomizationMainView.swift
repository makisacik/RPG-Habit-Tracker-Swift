//
//  CharacterCustomizationView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import SwiftUI

// Note: This file contains the legacy character customization view
// The new system uses CharacterCustomizationWizardView

struct CharacterCustomizationView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var customizationManager = CharacterCustomizationManager()
    @Binding var isCustomizationCompleted: Bool
    @State private var selectedCategory: CustomizationCategory = .bodyType

    private let categories: [CustomizationCategory] = [
        .bodyType, .hairStyle, .hairColor, .eyeColor, .outfit, .weapon, .accessory
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

                // Continue Button
                continueButtonView(theme: theme)
            }
            .padding()
        }
    }

    // MARK: - Header View
    @ViewBuilder
    private func headerView(theme: Theme) -> some View {
        VStack(spacing: 16) {
            Image("banner_hanging")
                .resizable()
                .frame(height: 60)
                .overlay(
                    Text("customizeYourHero".localized)
                        .font(.appFont(size: 18, weight: .black))
                        .foregroundColor(theme.textColor)
                        .padding(.top, 10)
                )

            Text("createYourUniqueCharacter".localized)
                .font(.appFont(size: 16))
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
                    // Wings (Accessory) - Draw first so it appears behind everything
                    if let accessory = customizationManager.currentCustomization.accessory {
                        Image(accessory.rawValue)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 120)
                    }

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
                        .colorMultiply(customizationManager.currentCustomization.hairColor.color)

                    // Eyes
                    Image(customizationManager.currentCustomization.eyeColor.rawValue)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 120)

                    // Outfit
                    if let outfit = customizationManager.currentCustomization.outfit {
                        Image(outfit.rawValue)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 120)
                    }

                    // Weapon
                    if let weapon = customizationManager.currentCustomization.weapon {
                        Image(weapon.rawValue)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 120)
                    }

                    // Wings - Draw first so they appear behind everything
                    if let wings = customizationManager.currentCustomization.wings {
                        Image(wings.rawValue)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 120)
                    }

                    // Other Accessories - Draw last so they appear on top
                    if let accessory = customizationManager.currentCustomization.accessory {
                        Image(accessory.rawValue)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 120)
                    }
                }

                Text("preview".localized)
                    .font(.appFont(size: 14, weight: .medium))
                    .foregroundColor(theme.textColor.opacity(0.7))
            }
            .padding(20)
        }
        .frame(height: 180)
        .padding(.bottom, 20)
    }

    // MARK: - Category Selector View
    @ViewBuilder
    private func categorySelectorView(theme: Theme) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    CategoryButton(
                        category: category,
                        isSelected: selectedCategory == category,
                        theme: theme
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(.bottom, 20)
    }

    // MARK: - Options Grid View
    @ViewBuilder
    private func optionsGridView(theme: Theme) -> some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                ForEach(getOptionsForCategory(), id: \.id) { option in
                    OptimizedCustomizationOptionCard(
                        option: option,
                        isSelected: isOptionSelected(option),
                        theme: theme
                    ) {
                        handleOptionSelection(option)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .frame(maxHeight: 300)
    }

    // MARK: - Continue Button View
    @ViewBuilder
    private func continueButtonView(theme: Theme) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isCustomizationCompleted = true
            }
        }) {
            Text("continueButton".localized)
                .font(.appFont(size: 18, weight: .bold))
                .foregroundColor(theme.buttonTextColor)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [theme.gradientStart, theme.gradientEnd]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: theme.primaryColor.opacity(0.3), radius: 8, x: 0, y: 4)
                )
        }
        .padding(.top, 20)
    }

    // MARK: - Helper Methods
    private func getOptionsForCategory() -> [CustomizationOption] {
        let optionsMap: [CustomizationCategory: [CustomizationOption]] = [
            .bodyType: BodyType.allCases.map { CustomizationOption(id: $0.rawValue, name: $0.displayName, imageName: $0.rawValue, previewImage: $0.previewImageName, isPremium: $0.isPremium, isUnlocked: true) },

            .hairStyle: HairStyle.allCases.map { CustomizationOption(id: $0.rawValue, name: $0.displayName, imageName: $0.rawValue, previewImage: $0.previewImageName, isPremium: $0.isPremium, isUnlocked: true) },
            .hairBackStyle: HairBackStyle.allCases.map { CustomizationOption(id: $0.rawValue, name: $0.displayName, imageName: $0.rawValue, previewImage: $0.previewImageName, isPremium: $0.isPremium, isUnlocked: true) },
            .hairColor: HairColor.allCases.map { CustomizationOption(id: $0.rawValue, name: $0.displayName, imageName: $0.rawValue, previewImage: $0.previewImageName, isPremium: false, isUnlocked: true) },
            .eyeColor: EyeColor.allCases.map { CustomizationOption(id: $0.rawValue, name: $0.displayName, imageName: $0.rawValue, previewImage: $0.previewImageName, isPremium: $0.isPremium, isUnlocked: true) },
            .outfit: Outfit.allCases.map { CustomizationOption(id: $0.rawValue, name: $0.displayName, imageName: $0.rawValue, previewImage: $0.previewImageName, isPremium: $0.isPremium, isUnlocked: true) },
            .weapon: CharacterWeapon.allCases.map { CustomizationOption(id: $0.rawValue, name: $0.displayName, imageName: $0.rawValue, previewImage: $0.previewImageName, isPremium: $0.isPremium, isUnlocked: true) },
            .accessory: Accessory.allCases.map { CustomizationOption(id: $0.rawValue, name: $0.displayName, imageName: $0.rawValue, previewImage: $0.previewImageName, isPremium: $0.isPremium, isUnlocked: true) },
            .mustache: Mustache.allCases.map { CustomizationOption(id: $0.rawValue, name: $0.displayName, imageName: $0.rawValue, previewImage: $0.previewImageName, isPremium: $0.isPremium, isUnlocked: true) },
            .flower: Flower.allCases.map { CustomizationOption(id: $0.rawValue, name: $0.displayName, imageName: $0.rawValue, previewImage: $0.previewImageName, isPremium: $0.isPremium, isUnlocked: true) }
        ]
        return optionsMap[selectedCategory] ?? []
    }

    private func isOptionSelected(_ option: CustomizationOption) -> Bool {
        let selectedValueMap: [CustomizationCategory: String?] = [
            .bodyType: customizationManager.currentCustomization.bodyType.rawValue,

            .hairStyle: customizationManager.currentCustomization.hairStyle.rawValue,
            .hairBackStyle: customizationManager.currentCustomization.hairBackStyle?.rawValue,
            .hairColor: customizationManager.currentCustomization.hairColor.rawValue,
            .eyeColor: customizationManager.currentCustomization.eyeColor.rawValue,
            .outfit: customizationManager.currentCustomization.outfit?.rawValue,
            .weapon: customizationManager.currentCustomization.weapon?.rawValue,
            .accessory: customizationManager.currentCustomization.accessory?.rawValue,
            .mustache: customizationManager.currentCustomization.mustache?.rawValue,
            .flower: customizationManager.currentCustomization.flower?.rawValue
        ]
        return selectedValueMap[selectedCategory] == option.id
    }

    private func handleOptionSelection(_ option: CustomizationOption) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            let updateActionMap: [CustomizationCategory: (String) -> Void] = [
                .bodyType: { optionId in
                    if let bodyType = BodyType(rawValue: optionId) {
                        customizationManager.updateBodyType(bodyType)
                    }
                },

                .hairStyle: { optionId in
                    if let hairStyle = HairStyle(rawValue: optionId) {
                        customizationManager.updateHairStyle(hairStyle)
                    }
                },
                .hairBackStyle: { optionId in
                    if let hairBackStyle = HairBackStyle(rawValue: optionId) {
                        customizationManager.updateHairBackStyle(hairBackStyle)
                    }
                },
                .hairColor: { optionId in
                    if let hairColor = HairColor(rawValue: optionId) {
                        customizationManager.updateHairColor(hairColor)
                    }
                },
                .eyeColor: { optionId in
                    if let eyeColor = EyeColor(rawValue: optionId) {
                        customizationManager.updateEyeColor(eyeColor)
                    }
                },
                .outfit: { optionId in
                    if let outfit = Outfit(rawValue: optionId) {
                        customizationManager.updateOutfit(outfit)
                    }
                },
                .weapon: { optionId in
                    if let weapon = CharacterWeapon(rawValue: optionId) {
                        customizationManager.updateWeapon(weapon)
                    }
                },
                .accessory: { optionId in
                    if let accessory = Accessory(rawValue: optionId) {
                        customizationManager.updateAccessory(accessory)
                    }
                },
                .mustache: { optionId in
                    if let mustache = Mustache(rawValue: optionId) {
                        customizationManager.updateMustache(mustache)
                    }
                },
                .flower: { optionId in
                    if let flower = Flower(rawValue: optionId) {
                        customizationManager.updateFlower(flower)
                    }
                }
            ]

            updateActionMap[selectedCategory]?(option.id)
        }
    }
}

// MARK: - Supporting Types and Views

enum CustomizationCategory: String, CaseIterable {
    case bodyType = "BodyType"
    case hairStyle = "HairStyle"
    case hairBackStyle = "HairBackStyle"
    case hairColor = "HairColor"
    case eyeColor = "EyeColor"
    case outfit = "Outfit"
    case weapon = "Weapon"
    case accessory = "Accessory"
    case mustache = "Mustache"
    case flower = "Flower"

    var title: String {
        return displayName
    }

    var displayName: String {
        switch self {
        case .bodyType: return "body_type".localized
        case .hairStyle: return "hair_style".localized
        case .hairBackStyle: return "hair_back_style".localized
        case .hairColor: return "hair_color".localized
        case .eyeColor: return "eye_color".localized
        case .outfit: return "outfit".localized
        case .weapon: return "weapon".localized
        case .accessory: return "accessory".localized
        case .mustache: return "mustache".localized
        case .flower: return "flower".localized
        }
    }

    var icon: String {
        switch self {
        case .bodyType: return "person.fill"
        case .hairStyle: return "scissors"
        case .hairBackStyle: return "scissors"
        case .hairColor: return "paintbrush.fill"
        case .eyeColor: return "eye.fill"
        case .outfit: return "icon_armor"
        case .weapon: return "icon_sword"
        case .accessory: return "crown.fill"
        case .mustache: return "mustache"
        case .flower: return "leaf.fill"
        }
    }
}


struct CategoryButton: View {
    let category: CustomizationCategory
    let isSelected: Bool
    let theme: Theme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                if category.icon.hasPrefix("icon_") {
                    Image(category.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(isSelected ? theme.buttonTextColor : theme.textColor)
                } else {
                    Image(systemName: category.icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(isSelected ? theme.buttonTextColor : theme.textColor)
                }

                Text(category.displayName)
                    .font(.appFont(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? theme.buttonTextColor : theme.textColor)
            }
            .frame(width: 80, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? theme.primaryColor : theme.cardBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? theme.primaryColor : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct OptimizedCustomizationOptionCard: View {
    let option: CustomizationOption
    let isSelected: Bool
    let theme: Theme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    if !option.imageName.isEmpty {
                        OptimizedImageLoader(imageName: option.imageName, height: 40)
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: 30))
                            .foregroundColor(theme.textColor.opacity(0.5))
                    }
                }

                Text(option.name)
                    .font(.appFont(size: 10, weight: .medium))
                    .foregroundColor(theme.textColor)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? theme.primaryColor.opacity(0.2) : theme.cardBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? theme.primaryColor : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(option.isUnlocked ? 1.0 : 0.5)
    }
}


// MARK: - Character Preview (Legacy)
// Note: CustomizedCharacterPreviewCard is now defined in CustomizedCharacterPreviewCard.swift

// MARK: - Memory-Efficient Character View
struct OptimizedCharacterView: View {
    let customization: CharacterCustomization
    @State private var cachedImage: UIImage?

    var body: some View {
        Group {
            if let cachedImage = cachedImage {
                Image(uiImage: cachedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                // Fallback while loading
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        ProgressView()
                            .scaleEffect(0.8)
                    )
            }
        }
        .onAppear {
            generateCharacterImage()
        }
        .onChange(of: customization) { _ in
            generateCharacterImage()
        }
    }

    private func generateCharacterImage() {
        DispatchQueue.global(qos: .userInitiated).async {
            let image = createCharacterImage()
            DispatchQueue.main.async {
                self.cachedImage = image
            }
        }
    }

    private func createCharacterImage() -> UIImage? {
        let size = CGSize(width: 240, height: 240) // Fixed size for consistency
        UIGraphicsBeginImageContextWithOptions(size, false, 2.0) // 2x scale for retina

        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        // Clear background
        context.setFillColor(UIColor.clear.cgColor)
        context.fill(CGRect(origin: .zero, size: size))

        // Draw wings first (if present) so they appear behind everything
        if let wings = customization.wings {
            let wingsImage = ImageCache.shared.getImage(for: wings.rawValue) ?? UIImage(named: wings.rawValue)
            if let wingsImage = wingsImage {
                drawImage(wingsImage, in: CGRect(origin: .zero, size: size), tintColor: nil)
            }
        }

        // Draw character layers in order
        var layers: [(String, Color?)] = [
            (customization.bodyType.rawValue, nil),
            (customization.hairStyle.rawValue, customization.hairColor.color)
        ]
        
        // Add outfit if present
        if let outfit = customization.outfit {
            layers.append((outfit.rawValue, nil))
        }
        
        // Add weapon if present
        if let weapon = customization.weapon {
            layers.append((weapon.rawValue, nil))
        }

        for (imageName, tintColor) in layers {
            // Try cache first, then load from bundle
            let image = ImageCache.shared.getImage(for: imageName) ?? UIImage(named: imageName)
            if let image = image {
                drawImage(image, in: CGRect(origin: .zero, size: size), tintColor: tintColor)
            }
        }

        // Draw other accessories last so they appear on top
        if let accessory = customization.accessory {
            let accessoryImage = ImageCache.shared.getImage(for: accessory.rawValue) ?? UIImage(named: accessory.rawValue)
            if let accessoryImage = accessoryImage {
                drawImage(accessoryImage, in: CGRect(origin: .zero, size: size), tintColor: nil)
            }
        }

        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return result
    }

    private func drawImage(_ image: UIImage, in rect: CGRect, tintColor: Color?) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.saveGState()

        // Apply tint if specified
        if let tintColor = tintColor {
            context.setBlendMode(.multiply)
            context.setFillColor(UIColor(tintColor).cgColor)
            context.fill(rect)
        }

        // Draw image
        image.draw(in: rect, blendMode: .normal, alpha: 1.0)

        context.restoreGState()
    }
}

// MARK: - String Extensions
extension String {
    static let createYourUniqueCharacter = "createYourUniqueCharacter"
    static let preview = "preview"
    static let yourCharacter = "yourCharacter"
    static let customized = "customized"
}
