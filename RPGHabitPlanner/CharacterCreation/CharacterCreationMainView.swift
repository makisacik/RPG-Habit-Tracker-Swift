//
//  CharacterCreationView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import SwiftUI

struct CharacterCreationView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var viewModel: CharacterCreationViewModel
    @Binding var isCharacterCreated: Bool

    @State private var currentSectionIndex = 0

    private let categories: [CustomizationCategory] = [
        .bodyType, .hairStyle, .hairColor, .eyeColor, .outfit, .weapon, .accessory
    ]

    var body: some View {
        let theme = themeManager.activeTheme
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [theme.primaryColor, theme.secondaryColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: theme.shadowColor, radius: 8, x: 0, y: 4)

            VStack(spacing: 12) {
                // Header
                CharacterCreationHeaderView(theme: theme)

                // Character Preview
                CharacterPreviewSectionView(
                    customization: viewModel.currentCustomization,
                    theme: theme
                )

                // Section Navigation
                SectionNavigationView(
                    currentIndex: $currentSectionIndex,
                    sections: categories,
                    theme: theme
                )

                // Current Section Content
                CurrentSectionContentView(
                    currentIndex: currentSectionIndex,
                    categories: categories,
                    viewModel: viewModel,
                    theme: theme
                )

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 20)
        }
    }
}

// MARK: - Header View
struct CharacterCreationHeaderView: View {
    let theme: Theme

    var body: some View {
        VStack(spacing: 8) {
            Text("createYourCharacter".localized)
                .font(.custom("Quicksand-Bold", size: 24))
                .foregroundColor(theme.textColor)

            Text("createYourUniqueCharacter".localized)
                .font(.custom("Quicksand-Regular", size: 16))
                .foregroundColor(theme.textColor.opacity(0.7))
        }
    }
}

// MARK: - Character Preview Section
struct CharacterPreviewSectionView: View {
    let customization: CharacterCustomization
    let theme: Theme

    var body: some View {
        VStack(spacing: 0) {
            Text("preview".localized)
                .font(.custom("Quicksand-Bold", size: 18))
                .foregroundColor(theme.textColor)
                .padding(.bottom, 4)

            CharacterFullPreview(customization: customization, size: 280)
                .environmentObject(ThemeManager.shared)
        }
    }
}

// MARK: - Section Navigation
struct SectionNavigationView: View {
    @Binding var currentIndex: Int
    let sections: [CustomizationCategory]
    let theme: Theme

    var body: some View {
        HStack {
            // Left Arrow
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentIndex = (currentIndex - 1 + sections.count) % sections.count
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(theme.accentColor)
                    .frame(width: 44, height: 44)
                    .background(theme.cardBackgroundColor)
                    .clipShape(Circle())
            }

            // Section Title
            Text(sections[currentIndex].title)
                .font(.custom("Quicksand-Bold", size: 18))
                .foregroundColor(theme.textColor)
                .frame(maxWidth: .infinity)

            // Right Arrow
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentIndex = (currentIndex + 1) % sections.count
                }
            }) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(theme.accentColor)
                    .frame(width: 44, height: 44)
                    .background(theme.cardBackgroundColor)
                    .clipShape(Circle())
            }
        }
    }
}

// MARK: - Current Section Content
struct CurrentSectionContentView: View {
    let currentIndex: Int
    let categories: [CustomizationCategory]
    @ObservedObject var viewModel: CharacterCreationViewModel
    let theme: Theme

    var body: some View {
        let currentSection = categories[currentIndex]

        VStack(spacing: 12) {
            switch currentSection {
            case .bodyType:
                BodyTypeSectionView(viewModel: viewModel, theme: theme)
            case .hairStyle:
                HairstyleSectionView(viewModel: viewModel, theme: theme)
            case .hairBackStyle:
                HairBackStyleSectionView(viewModel: viewModel, theme: theme)
            case .hairColor:
                HairColorSectionView(viewModel: viewModel, theme: theme)
            case .eyeColor:
                EyeColorSectionView(viewModel: viewModel, theme: theme)
            case .outfit:
                OutfitSectionView(viewModel: viewModel, theme: theme)
            case .weapon:
                WeaponSectionView(viewModel: viewModel, theme: theme)
            case .accessory:
                AccessoriesSectionView(viewModel: viewModel, theme: theme)
            case .mustache:
                MustacheSectionView(viewModel: viewModel, theme: theme)
            case .flower:
                FlowerSectionView(viewModel: viewModel, theme: theme)
            }
        }
        .frame(maxHeight: 200)
    }
}

// MARK: - Section Implementations
struct BodyTypeSectionView: View {
    @ObservedObject var viewModel: CharacterCreationViewModel
    let theme: Theme

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 5), spacing: 8) {
            ForEach(BodyType.allCases, id: \.self) { bodyType in
                BodyTypeOptionCard(
                    bodyType: bodyType,
                    isSelected: viewModel.currentCustomization.bodyType == bodyType,
                    theme: theme
                ) {
                        viewModel.updateBodyType(bodyType)
                }
            }
        }
    }
}

// MARK: - Body Type Option Card
struct BodyTypeOptionCard: View {
    let bodyType: BodyType
    let isSelected: Bool
    let theme: Theme
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                // Body color circle - smaller size
                Circle()
                    .fill(bodyType.color)
                    .frame(width: 35, height: 35)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? theme.accentColor : theme.textColor.opacity(0.2), lineWidth: isSelected ? 3 : 2)
                    )
                    .shadow(color: isSelected ? theme.accentColor.opacity(0.3) : Color.black.opacity(0.1), radius: isSelected ? 4 : 2)
            }
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? theme.accentColor.opacity(0.1) : theme.cardBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? theme.accentColor : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}


struct HairstyleSectionView: View {
    @ObservedObject var viewModel: CharacterCreationViewModel
    let theme: Theme

    // Define the default hair styles to show (one for each hair type)
    private var defaultHairStyles: [HairStyle] {
        return [
            .hair1Black,   // Hair Style 1 - Default black
            .hair3Black,   // Hair Style 3 - Default black
            .hair4Black,   // Hair Style 4 - Default black
            .hair5Black,   // Hair Style 5 - Default black
            .hair10Brown,  // Hair Style 10 - Default brown
            .hair11Brown,  // Hair Style 11 - Default brown
            .hair12Black,  // Hair Style 12 - Default black
            .hair13Red     // Hair Style 13 - Default red
        ]
    }

    var body: some View {
        ScrollView(showsIndicators: true) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                ForEach(defaultHairStyles, id: \.self) { hairStyle in
                    let isSelected = viewModel.currentCustomization.hairStyle.hairType == hairStyle.hairType

                    HairStyleCard(
                        hairStyle: hairStyle,
                        isSelected: isSelected,
                        onTap: {
                            viewModel.updateHairStyleAndColor(hairStyle)
                        },
                        theme: theme
                    )
                }
            }
            .padding(.horizontal, 12)
        }
    }
}

// MARK: - Hair Style Card
struct HairStyleCard: View {
    let hairStyle: HairStyle
    let isSelected: Bool
    let onTap: () -> Void
    let theme: Theme

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Hair style image
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.cardBackgroundColor)
                        .frame(width: 80, height: 80)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? theme.accentColor : theme.borderColor.opacity(0.3), lineWidth: isSelected ? 3 : 1)
                        )
                        .shadow(color: theme.shadowColor, radius: 4, x: 0, y: 2)

                    if !hairStyle.previewImageName.isEmpty {
                        Image(hairStyle.previewImageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: 30))
                            .foregroundColor(theme.textColor.opacity(0.5))
                    }

                    // Premium indicator
                    if hairStyle.isPremium {
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.yellow)
                                    .padding(4)
                                    .background(Circle().fill(.black.opacity(0.7)))
                            }
                            Spacer()
                        }
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EyeColorSectionView: View {
    @ObservedObject var viewModel: CharacterCreationViewModel
    let theme: Theme

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
            ForEach(EyeColor.allCases, id: \.self) { eyeColor in
                CustomizationOptionCard(
                    option: CustomizationOption(
                        id: eyeColor.rawValue,
                        name: eyeColor.displayName,
                        imageName: eyeColor.previewImageName,
                        isPremium: eyeColor.isPremium,
                        isUnlocked: true
                    ),
                    isSelected: viewModel.currentCustomization.eyeColor == eyeColor,
                    onTap: {
                        viewModel.updateEyeColor(eyeColor)
                    },
                    theme: theme
                )
            }
        }
    }
}

struct AccessoriesSectionView: View {
    @ObservedObject var viewModel: CharacterCreationViewModel
    let theme: Theme

    // Filter to only show glasses accessories
    private var availableAccessories: [Accessory] {
        return [.eyeglassRed, .eyeglassBlue, .eyeglassGray]
    }

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
            ForEach(availableAccessories, id: \.self) { accessory in
                CustomizationOptionCard(
                    option: CustomizationOption(
                        id: accessory.rawValue,
                        name: accessory.displayName,
                        imageName: accessory.previewImageName,
                        isPremium: accessory.isPremium,
                        isUnlocked: true
                    ),
                    isSelected: viewModel.currentCustomization.accessory == accessory,
                    onTap: {
                        viewModel.updateAccessory(accessory)
                    },
                    theme: theme
                )
            }
        }
    }
}


// MARK: - Additional Section Views
struct OutfitSectionView: View {
    @ObservedObject var viewModel: CharacterCreationViewModel
    let theme: Theme

    // Filter to only show villager outfits
    private var availableOutfits: [Outfit] {
        return [.outfitVillager, .outfitVillagerBlue]
    }

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
            ForEach(availableOutfits, id: \.self) { outfit in
                CustomizationOptionCard(
                    option: CustomizationOption(
                        id: outfit.rawValue,
                        name: outfit.displayName,
                        imageName: outfit.previewImageName,
                        isPremium: outfit.isPremium,
                        isUnlocked: true
                    ),
                    isSelected: viewModel.currentCustomization.outfit == outfit,
                    onTap: {
                        viewModel.updateOutfit(outfit)
                    },
                    theme: theme
                )
            }
        }
    }
}

struct WeaponSectionView: View {
    @ObservedObject var viewModel: CharacterCreationViewModel
    let theme: Theme

    // Filter to only show basic weapons
    private var availableWeapons: [CharacterWeapon] {
        return [.swordWood, .swordIron]
    }

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
            ForEach(availableWeapons, id: \.self) { weapon in
                CustomizationOptionCard(
                    option: CustomizationOption(
                        id: weapon.rawValue,
                        name: weapon.displayName,
                        imageName: weapon.previewImageName,
                        isPremium: weapon.isPremium,
                        isUnlocked: true
                    ),
                    isSelected: viewModel.currentCustomization.weapon == weapon,
                    onTap: {
                        viewModel.updateWeapon(weapon)
                    },
                    theme: theme
                )
            }
        }
    }
}


struct HairColorSectionView: View {
    @ObservedObject var viewModel: CharacterCreationViewModel
    let theme: Theme
    
    // Get available colors for the current hair style
    private var availableColors: [HairColor] {
        let currentHairType = viewModel.currentCustomization.hairStyle.hairType
        return HairStyle.getAvailableColorsForType(currentHairType)
    }
    
    var body: some View {
        VStack {
            if availableColors.isEmpty {
                Text("No colors available for this hair style")
                    .font(.custom("Quicksand-Regular", size: 14))
                    .foregroundColor(theme.textColor.opacity(0.7))
                    .padding()
            } else if availableColors.count == 1 {
                // If only one color is available, show it as selected
                HStack {
                    Spacer()
                    HairColorOptionCard(
                        hairColor: availableColors[0],
                        isSelected: true,
                        theme: theme
                    ) {
                        viewModel.updateHairColor(availableColors[0], updateHairStyle: true)
                    }
                    Spacer()
                }
            } else {
                // Dynamic grid based on number of colors
                let columns = min(availableColors.count, 4)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: columns), spacing: 12) {
                    ForEach(availableColors, id: \.self) { hairColor in
                        HairColorOptionCard(
                            hairColor: hairColor,
                            isSelected: viewModel.currentCustomization.hairColor == hairColor,
                            theme: theme
                        ) {
                            viewModel.updateHairColor(hairColor, updateHairStyle: true)
                        }
                    }
                }
            }
        }
        .onAppear {
            // Auto-select the first available color if current color is not available
            if !availableColors.isEmpty && !availableColors.contains(viewModel.currentCustomization.hairColor) {
                viewModel.updateHairColor(availableColors[0], updateHairStyle: true)
            }
        }
        .onChange(of: availableColors) { newColors in
            // Auto-select the first available color if current color is not available
            if !newColors.isEmpty && !newColors.contains(viewModel.currentCustomization.hairColor) {
                viewModel.updateHairColor(newColors[0], updateHairStyle: true)
            }
        }
    }
}

// MARK: - Hair Color Option Card
struct HairColorOptionCard: View {
    let hairColor: HairColor
    let isSelected: Bool
    let theme: Theme
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                // Hair color circle
                Circle()
                    .fill(hairColor.color)
                    .frame(width: 35, height: 35)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? theme.accentColor : theme.textColor.opacity(0.2), lineWidth: isSelected ? 3 : 2)
                    )
                    .shadow(color: isSelected ? theme.accentColor.opacity(0.3) : Color.black.opacity(0.1), radius: isSelected ? 4 : 2)
            }
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? theme.accentColor.opacity(0.1) : theme.cardBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? theme.accentColor : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct HairBackStyleSectionView: View {
    @ObservedObject var viewModel: CharacterCreationViewModel
    let theme: Theme

    // Filter to show a few hair back styles
    private var availableHairBacks: [HairBackStyle] {
        return [.hair2BackBrown, .hair6BackBrown, .hair7BackBrown, .hair8BackBrown]
    }

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
            ForEach(availableHairBacks, id: \.self) { hairBack in
                CustomizationOptionCard(
                    option: CustomizationOption(
                        id: hairBack.rawValue,
                        name: hairBack.displayName,
                        imageName: hairBack.previewImageName,
                        isPremium: hairBack.isPremium,
                        isUnlocked: true
                    ),
                    isSelected: viewModel.currentCustomization.hairBackStyle == hairBack,
                    onTap: {
                        viewModel.updateHairBackStyle(hairBack)
                    },
                    theme: theme
                )
            }
        }
    }
}

struct MustacheSectionView: View {
    @ObservedObject var viewModel: CharacterCreationViewModel
    let theme: Theme

    // Filter to show a few mustache styles
    private var availableMustaches: [Mustache] {
        return [.mustache1Brown, .mustache1Black, .mustache2Brown, .mustache2Black]
    }

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
            ForEach(availableMustaches, id: \.self) { mustache in
                CustomizationOptionCard(
                    option: CustomizationOption(
                        id: mustache.rawValue,
                        name: mustache.displayName,
                        imageName: mustache.previewImageName,
                        isPremium: mustache.isPremium,
                        isUnlocked: true
                    ),
                    isSelected: viewModel.currentCustomization.mustache == mustache,
                    onTap: {
                        viewModel.updateMustache(mustache)
                    },
                    theme: theme
                )
            }
        }
    }
}

struct FlowerSectionView: View {
    @ObservedObject var viewModel: CharacterCreationViewModel
    let theme: Theme

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
            ForEach(Flower.allCases, id: \.self) { flower in
                CustomizationOptionCard(
                    option: CustomizationOption(
                        id: flower.rawValue,
                        name: flower.displayName,
                        imageName: flower.previewImageName,
                        isPremium: flower.isPremium,
                        isUnlocked: true
                    ),
                    isSelected: viewModel.currentCustomization.flower == flower,
                    onTap: {
                        viewModel.updateFlower(flower)
                    },
                    theme: theme
                )
            }
        }
    }
}

// MARK: - Supporting Types and Views
