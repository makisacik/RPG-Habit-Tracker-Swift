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
    
    private let sections = CustomizationStep.allCases

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
                    sections: sections,
                    theme: theme
                )
                
                // Current Section Content
                CurrentSectionContentView(
                    currentIndex: currentSectionIndex,
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
    let sections: [CustomizationStep]
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
    @ObservedObject var viewModel: CharacterCreationViewModel
    let theme: Theme
    
    var body: some View {
        let currentSection = CustomizationStep.allCases[currentIndex]
        
        VStack(spacing: 12) {
            switch currentSection {
            case .skinColor:
                SkinColorSectionView(viewModel: viewModel, theme: theme)
            case .hairstyle:
                HairstyleSectionView(viewModel: viewModel, theme: theme)
            case .eyeColor:
                EyeColorSectionView(viewModel: viewModel, theme: theme)
            case .outfit:
                OutfitSectionView(viewModel: viewModel, theme: theme)
            case .weapon:
                WeaponSectionView(viewModel: viewModel, theme: theme)
            case .accessory:
                AccessoriesSectionView(viewModel: viewModel, theme: theme)
            }
        }
        .frame(maxHeight: 200)
    }
}

// MARK: - Section Implementations
struct SkinColorSectionView: View {
    @ObservedObject var viewModel: CharacterCreationViewModel
    let theme: Theme
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
            ForEach(SkinColor.allCases, id: \.self) { skinColor in
                SkinColorOptionCard(
                    skinColor: skinColor,
                    isSelected: viewModel.currentCustomization.skinColor == skinColor,
                    theme: theme
                ) {
                    // Map skin color to body type and update
                    let bodyType = mapSkinColorToBodyType(skinColor)
                    viewModel.updateBodyType(bodyType)
                    viewModel.updateSkinColor(skinColor)
                }
            }
        }
    }
    
    // Helper function to map skin color to body type
    private func mapSkinColorToBodyType(_ skinColor: SkinColor) -> BodyType {
        switch skinColor {
        case .light: return .body1
        case .medium: return .body2
        case .dark: return .body3
        case .tan: return .body4
        case .olive: return .body5
        }
    }
}

// MARK: - Skin Color Option Card
struct SkinColorOptionCard: View {
    let skinColor: SkinColor
    let isSelected: Bool
    let theme: Theme
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Skin color circle
                Circle()
                    .fill(skinColor.color)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? theme.accentColor : theme.textColor.opacity(0.2), lineWidth: isSelected ? 3 : 2)
                    )
                    .shadow(color: isSelected ? theme.accentColor.opacity(0.3) : Color.black.opacity(0.1), radius: isSelected ? 4 : 2)
                
                // Skin color name
                Text(skinColor.displayName)
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
    
    // Filter to only show simple and hoodie outfits
    private var availableOutfits: [Outfit] {
        return [.simple, .hoodie]
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

    // Filter to only show wooden and steel daggers
    private var availableWeapons: [CharacterWeapon] {
        return [.swordDaggerWood, .swordDagger]
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
