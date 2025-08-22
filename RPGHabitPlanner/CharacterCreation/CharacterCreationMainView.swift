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
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
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
            VStack(spacing: 8) {
                // Body color circle
                Circle()
                    .fill(bodyType.color)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? theme.accentColor : theme.textColor.opacity(0.2), lineWidth: isSelected ? 3 : 2)
                    )
                    .shadow(color: isSelected ? theme.accentColor.opacity(0.3) : Color.black.opacity(0.1), radius: isSelected ? 4 : 2)
                
                // Body type name
                Text(bodyType.displayName)
                    .font(.custom("Quicksand-Medium", size: 12))
                    .foregroundColor(theme.textColor)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(height: 80)
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
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
            ForEach(HairStyle.allCases, id: \.self) { hairStyle in
                CustomizationOptionCard(
                    option: CustomizationOption(
                        id: hairStyle.rawValue,
                        name: hairStyle.displayName,
                        imageName: hairStyle.previewImageName,
                        isPremium: hairStyle.isPremium,
                        isUnlocked: true
                    ),
                    isSelected: viewModel.currentCustomization.hairStyle == hairStyle,
                    onTap: {
                        viewModel.updateHairStyle(hairStyle)
                    },
                    theme: theme
                )
            }
        }
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
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
            ForEach(HairColor.allCases, id: \.self) { hairColor in
                CustomizationOptionCard(
                    option: CustomizationOption(
                        id: hairColor.rawValue,
                        name: hairColor.displayName,
                        imageName: hairColor.previewImageName,
                        isPremium: hairColor.isPremium,
                        isUnlocked: true
                    ),
                    isSelected: viewModel.currentCustomization.hairColor == hairColor,
                    onTap: {
                        viewModel.updateHairColor(hairColor)
                    },
                    theme: theme
                )
            }
        }
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
