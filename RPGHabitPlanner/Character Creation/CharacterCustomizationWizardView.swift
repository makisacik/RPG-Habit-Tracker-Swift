//
//  CharacterCustomizationWizardView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 7.01.2025.
//

import SwiftUI

// MARK: - Customization Wizard Steps

enum CustomizationWizardStep: Int, CaseIterable {
    case bodyType = 0
    case skinColor = 1
    case hairStyle = 2
    case hairColor = 3
    case eyeColor = 4
    case outfit = 5
    case weapon = 6
    case accessory = 7
    
    var title: String {
        switch self {
        case .bodyType: return "Choose Body Type"
        case .skinColor: return "Select Skin Color"
        case .hairStyle: return "Pick Hair Style"
        case .hairColor: return "Choose Hair Color"
        case .eyeColor: return "Select Eye Color"
        case .outfit: return "Choose Outfit"
        case .weapon: return "Pick Your Weapon"
        case .accessory: return "Add Accessories"
        }
    }
    
    var category: AssetCategory {
        switch self {
        case .bodyType: return .bodyType
        case .skinColor: return .skinColor
        case .hairStyle: return .hairStyle
        case .hairColor: return .hairColor
        case .eyeColor: return .eyeColor
        case .outfit: return .outfit
        case .weapon: return .weapon
        case .accessory: return .accessory
        }
    }
    
    var isOptional: Bool {
        return self == .accessory
    }
}

// MARK: - Character Customization Wizard View

struct CharacterCustomizationWizardView: View {
    @ObservedObject var viewModel: CharacterCreationViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var currentStep: CustomizationWizardStep = .bodyType
    @State private var selectedAssets: [AssetCategory: AssetItem] = [:]
    
    private let assetManager = CharacterAssetManager.shared
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        VStack(spacing: 20) {
            // Progress indicator
            CustomizationProgressView(
                currentStep: currentStep.rawValue,
                totalSteps: CustomizationWizardStep.allCases.count - 1
            )
            
            // Current step view
            CustomizationStepView(
                title: currentStep.title,
                category: currentStep.category,
                selectedAsset: selectedAssets[currentStep.category],
                availableAssets: getAvailableAssets(for: currentStep.category),
                onAssetSelected: { asset in
                    selectedAssets[currentStep.category] = asset
                    updateCustomization()
                }
            )
            
            Spacer()
            
            // Navigation buttons
            CustomizationNavigationButtons(
                canGoBack: currentStep.rawValue > 0,
                canGoForward: canProceedToNext(),
                onBack: previousStep,
                onForward: nextStep
            )
        }
        .padding()
        .onAppear {
            initializeDefaultSelections()
        }
    }
    
    // MARK: - Navigation Methods
    
    private func nextStep() {
        guard canProceedToNext() else { return }
        
        if currentStep.rawValue < CustomizationWizardStep.allCases.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep = CustomizationWizardStep(rawValue: currentStep.rawValue + 1) ?? currentStep
            }
        } else {
            // Wizard complete
            finalizeCustomization()
        }
    }
    
    private func previousStep() {
        if currentStep.rawValue > 0 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep = CustomizationWizardStep(rawValue: currentStep.rawValue - 1) ?? currentStep
            }
        }
    }
    
    private func canProceedToNext() -> Bool {
        // Optional steps (like accessories) can always proceed
        if currentStep.isOptional {
            return true
        }
        
        // Required steps need a selection
        return selectedAssets[currentStep.category] != nil
    }
    
    // MARK: - Asset Management
    
    private func getAvailableAssets(for category: AssetCategory) -> [AssetItem] {
        let allAssets = assetManager.getAvailableAssets(for: category)
        
        // For now, show all assets as available (will be filtered by ownership later)
        return allAssets.map { asset in
            var mutableAsset = asset
            mutableAsset.isUnlocked = true // Temporary - will be based on actual ownership
            return mutableAsset
        }
    }
    
    private func initializeDefaultSelections() {
        // Initialize with default values
        let defaultCustomization = CharacterCustomization()
        
        selectedAssets[.bodyType] = AssetItem(
            id: defaultCustomization.bodyType.rawValue,
            name: defaultCustomization.bodyType.displayName,
            imageName: defaultCustomization.bodyType.rawValue,
            category: .bodyType,
            rarity: .common,
            isUnlocked: true
        )
        
        selectedAssets[.skinColor] = AssetItem(
            id: defaultCustomization.skinColor.rawValue,
            name: defaultCustomization.skinColor.displayName,
            imageName: "",
            category: .skinColor,
            rarity: .common,
            isUnlocked: true
        )
        
        selectedAssets[.hairStyle] = AssetItem(
            id: defaultCustomization.hairStyle.rawValue,
            name: defaultCustomization.hairStyle.displayName,
            imageName: defaultCustomization.hairStyle.rawValue,
            category: .hairStyle,
            rarity: .common,
            isUnlocked: true
        )
        
        selectedAssets[.hairColor] = AssetItem(
            id: defaultCustomization.hairColor.rawValue,
            name: defaultCustomization.hairColor.displayName,
            imageName: "",
            category: .hairColor,
            rarity: .common,
            isUnlocked: true
        )
        
        selectedAssets[.eyeColor] = AssetItem(
            id: defaultCustomization.eyeColor.rawValue,
            name: defaultCustomization.eyeColor.displayName,
            imageName: defaultCustomization.eyeColor.rawValue,
            category: .eyeColor,
            rarity: .common,
            isUnlocked: true
        )
        
        selectedAssets[.outfit] = AssetItem(
            id: defaultCustomization.outfit.rawValue,
            name: defaultCustomization.outfit.displayName,
            imageName: defaultCustomization.outfit.rawValue,
            category: .outfit,
            rarity: .common,
            isUnlocked: true
        )
        
        selectedAssets[.weapon] = AssetItem(
            id: defaultCustomization.weapon.rawValue,
            name: defaultCustomization.weapon.displayName,
            imageName: defaultCustomization.weapon.rawValue,
            category: .weapon,
            rarity: .common,
            isUnlocked: true
        )
        
        updateCustomization()
    }
    
    private func updateCustomization() {
        var customization = CharacterCustomization()
        
        // Update customization based on selected assets
        if let bodyTypeAsset = selectedAssets[.bodyType],
           let bodyType = BodyType(rawValue: bodyTypeAsset.id) {
            customization.bodyType = bodyType
        }
        
        if let skinColorAsset = selectedAssets[.skinColor],
           let skinColor = SkinColor(rawValue: skinColorAsset.id) {
            customization.skinColor = skinColor
        }
        
        if let hairStyleAsset = selectedAssets[.hairStyle],
           let hairStyle = HairStyle(rawValue: hairStyleAsset.id) {
            customization.hairStyle = hairStyle
        }
        
        if let hairColorAsset = selectedAssets[.hairColor],
           let hairColor = HairColor(rawValue: hairColorAsset.id) {
            customization.hairColor = hairColor
        }
        
        if let eyeColorAsset = selectedAssets[.eyeColor],
           let eyeColor = EyeColor(rawValue: eyeColorAsset.id) {
            customization.eyeColor = eyeColor
        }
        
        if let outfitAsset = selectedAssets[.outfit],
           let outfit = Outfit(rawValue: outfitAsset.id) {
            customization.outfit = outfit
        }
        
        if let weaponAsset = selectedAssets[.weapon],
           let weapon = CharacterWeapon(rawValue: weaponAsset.id) {
            customization.weapon = weapon
        }
        
        if let accessoryAsset = selectedAssets[.accessory],
           let accessory = Accessory(rawValue: accessoryAsset.id) {
            customization.accessory = accessory
        }
        
        // Update the view model
        viewModel.updateCustomization(customization)
    }
    
    private func finalizeCustomization() {
        // Mark customization as complete
        viewModel.isCustomizationComplete = true
    }
}

// MARK: - Character Preview View

struct CharacterFullPreview: View {
    let customization: CharacterCustomization
    let size: CGFloat
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.primaryColor)
                .frame(width: size, height: size)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            
            // Character layers (simplified rendering)
            VStack {
                // Body
                if !customization.bodyType.rawValue.isEmpty {
                    AsyncImage(url: Bundle.main.url(forResource: customization.bodyType.rawValue, withExtension: nil)) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        Rectangle()
                            .fill(customization.skinColor.color)
                    }
                    .frame(width: size * 0.8, height: size * 0.8)
                }
                
                Text(customization.bodyType.displayName)
                    .font(.appFont(size: 12))
                    .foregroundColor(theme.textColor.opacity(0.7))
            }
        }
    }
}