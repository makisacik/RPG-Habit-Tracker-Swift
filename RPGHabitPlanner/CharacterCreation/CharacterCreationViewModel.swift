//
//  CharacterCreationViewModel.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import SwiftUI

class CharacterCreationViewModel: ObservableObject {
    // New customization properties
    @Published var currentCustomization = CharacterCustomization()
    @Published var isCustomizationComplete: Bool = false
    @Published var nickname: String = ""
    @Published var isCharacterCreated: Bool = false
    
    // Services
    private let userManager = UserManager()
    private let customizationService = CharacterCustomizationService()
    private let customizationItemService = CustomizationItemService()
    private let presetService = CharacterPresetService()

    func confirmSelection() {
        // Use new customization system
        saveUserWithCustomization { [weak self] error in
            if let error = error {
                print("Failed to save user: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self?.isCharacterCreated = true
                }
            }
        }
    }
    
    // MARK: - New Customization Methods
    
    func updateCustomization(_ customization: CharacterCustomization) {
        self.currentCustomization = customization
        checkCustomizationComplete()
    }
    
    // MARK: - Individual Update Methods for Carousel Interface
    
    func updateBodyType(_ bodyType: BodyType) {
        currentCustomization.bodyType = bodyType
        checkCustomizationComplete()
    }
    
    func updateSkinColor(_ skinColor: SkinColor) {
        currentCustomization.skinColor = skinColor
        checkCustomizationComplete()
    }
    
    func updateHairStyle(_ hairStyle: HairStyle) {
        currentCustomization.hairStyle = hairStyle
        checkCustomizationComplete()
    }
    
    func updateHairColor(_ hairColor: HairColor) {
        currentCustomization.hairColor = hairColor
        checkCustomizationComplete()
    }
    
    func updateEyeColor(_ eyeColor: EyeColor) {
        currentCustomization.eyeColor = eyeColor
        checkCustomizationComplete()
    }
    
    func updateOutfit(_ outfit: Outfit) {
        currentCustomization.outfit = outfit
        checkCustomizationComplete()
    }
    
    func updateWeapon(_ weapon: CharacterWeapon) {
        currentCustomization.weapon = weapon
        checkCustomizationComplete()
    }
    
    func updateAccessory(_ accessory: Accessory?) {
        currentCustomization.accessory = accessory
        checkCustomizationComplete()
    }
    
    private func checkCustomizationComplete() {
        // Check if all required customization options are selected
        let isComplete = !currentCustomization.bodyType.rawValue.isEmpty &&
                        !currentCustomization.skinColor.rawValue.isEmpty &&
                        !currentCustomization.hairStyle.rawValue.isEmpty &&
                        !currentCustomization.hairColor.rawValue.isEmpty &&
                        !currentCustomization.eyeColor.rawValue.isEmpty &&
                        !currentCustomization.outfit.rawValue.isEmpty &&
                        !currentCustomization.weapon.rawValue.isEmpty
        
        isCustomizationComplete = isComplete
    }
    
    func saveUserWithCustomization(completion: @escaping (Error?) -> Void) {
        // First create the user
        userManager.saveUserWithCustomization(
            nickname: nickname,
            customization: currentCustomization
        ) { [weak self] user, error in
            if let error = error {
                completion(error)
                return
            }
            
            guard let user = user, let self = self else {
                completion(NSError(domain: "CharacterCreation", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create user"]))
                return
            }
            
            // Create customization entity
            _ = self.customizationService.createCustomization(for: user, customization: self.currentCustomization)
            
            // Populate default items
            self.customizationItemService.populateDefaultItems(for: user)
            
            // Create default preset
            _ = self.presetService.createDefaultPreset(for: user, customization: self.currentCustomization)
            
            completion(nil)
        }
    }
    
    func resetCustomization() {
        currentCustomization = CharacterCustomization()
        isCustomizationComplete = false
    }
}
