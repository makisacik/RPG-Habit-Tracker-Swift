//
//  CharacterCustomizationManager.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import Foundation
import SwiftUI

class CharacterCustomizationManager: ObservableObject {
    @Published var currentCustomization: CharacterCustomization
    @Published var ownedItems: Set<String> = []
    
    private let userDefaults = UserDefaults.standard
    private let customizationKey = "CharacterCustomization"
    private let ownedItemsKey = "OwnedCharacterItems"
    
    init() {
        // Load saved customization or use default
        if let data = userDefaults.data(forKey: customizationKey),
           let customization = try? JSONDecoder().decode(CharacterCustomization.self, from: data) {
            self.currentCustomization = customization
        } else {
            self.currentCustomization = CharacterCustomization()
        }
        
        // Load owned items
        if let ownedItemsArray = userDefaults.array(forKey: ownedItemsKey) as? [String] {
            self.ownedItems = Set(ownedItemsArray)
        } else {
            // Add default items to owned items
            self.ownedItems = getDefaultOwnedItems()
        }
    }
    
    // MARK: - Default Items
    private func getDefaultOwnedItems() -> Set<String> {
        var defaultItems: Set<String> = []
        
        // Add all body types
        for bodyType in BodyType.allCases {
            defaultItems.insert(bodyType.rawValue)
        }
        
        // Add all hair styles
        for hairStyle in HairStyle.allCases {
            defaultItems.insert(hairStyle.rawValue)
        }
        
        // Add all eye colors
        for eyeColor in EyeColor.allCases {
            defaultItems.insert(eyeColor.rawValue)
        }
        
        // Add all outfits
        for outfit in Outfit.allCases {
            defaultItems.insert(outfit.rawValue)
        }
        
        // Add all weapons
        for weapon in CharacterWeapon.allCases {
            defaultItems.insert(weapon.rawValue)
        }
        
        // Add all accessories
        for accessory in Accessory.allCases {
            defaultItems.insert(accessory.rawValue)
        }
        
        return defaultItems
    }
    
    // MARK: - Save/Load Methods
    func saveCustomization() {
        if let data = try? JSONEncoder().encode(currentCustomization) {
            userDefaults.set(data, forKey: customizationKey)
        }
    }
    
    func loadCustomization() {
        if let data = userDefaults.data(forKey: customizationKey),
           let customization = try? JSONDecoder().decode(CharacterCustomization.self, from: data) {
            self.currentCustomization = customization
        }
    }
    
    func saveOwnedItems() {
        let ownedItemsArray = Array(ownedItems)
        userDefaults.set(ownedItemsArray, forKey: ownedItemsKey)
    }
    
    // MARK: - Item Management
    func ownsItem(_ itemId: String) -> Bool {
        return ownedItems.contains(itemId)
    }
    
    func addItem(_ itemId: String) {
        ownedItems.insert(itemId)
        saveOwnedItems()
    }
    
    func removeItem(_ itemId: String) {
        ownedItems.remove(itemId)
        saveOwnedItems()
    }
    
    // MARK: - Customization Methods
    func updateBodyType(_ bodyType: BodyType) {
        currentCustomization.bodyType = bodyType
        saveCustomization()
    }
    
    func updateSkinColor(_ skinColor: SkinColor) {
        currentCustomization.skinColor = skinColor
        saveCustomization()
    }
    
    func updateHairStyle(_ hairStyle: HairStyle) {
        currentCustomization.hairStyle = hairStyle
        saveCustomization()
    }
    
    func updateHairColor(_ hairColor: HairColor) {
        currentCustomization.hairColor = hairColor
        saveCustomization()
    }
    
    func updateEyeColor(_ eyeColor: EyeColor) {
        currentCustomization.eyeColor = eyeColor
        saveCustomization()
    }
    
    func updateOutfit(_ outfit: Outfit) {
        currentCustomization.outfit = outfit
        saveCustomization()
    }
    
    func updateWeapon(_ weapon: CharacterWeapon) {
        currentCustomization.weapon = weapon
        saveCustomization()
    }
    
    func updateAccessory(_ accessory: Accessory?) {
        currentCustomization.accessory = accessory
        saveCustomization()
    }
    
    // MARK: - Validation Methods
    func canUseBodyType(_ bodyType: BodyType) -> Bool {
        return ownsItem(bodyType.rawValue)
    }
    
    func canUseHairStyle(_ hairStyle: HairStyle) -> Bool {
        return ownsItem(hairStyle.rawValue)
    }
    
    func canUseEyeColor(_ eyeColor: EyeColor) -> Bool {
        return ownsItem(eyeColor.rawValue)
    }
    
    func canUseOutfit(_ outfit: Outfit) -> Bool {
        return ownsItem(outfit.rawValue)
    }
    
    func canUseWeapon(_ weapon: CharacterWeapon) -> Bool {
        return ownsItem(weapon.rawValue)
    }
    
    func canUseAccessory(_ accessory: Accessory) -> Bool {
        return ownsItem(accessory.rawValue)
    }
    
    // MARK: - Available Items
    var availableBodyTypes: [BodyType] {
        return BodyType.allCases.filter { canUseBodyType($0) }
    }
    
    var availableHairStyles: [HairStyle] {
        return HairStyle.allCases.filter { canUseHairStyle($0) }
    }
    
    var availableEyeColors: [EyeColor] {
        return EyeColor.allCases.filter { canUseEyeColor($0) }
    }
    
    var availableOutfits: [Outfit] {
        return Outfit.allCases.filter { canUseOutfit($0) }
    }
    
    var availableWeapons: [CharacterWeapon] {
        return CharacterWeapon.allCases.filter { canUseWeapon($0) }
    }
    
    var availableAccessories: [Accessory] {
        return Accessory.allCases.filter { canUseAccessory($0) }
    }
    
    // MARK: - Premium Items
    var premiumBodyTypes: [BodyType] {
        return BodyType.allCases.filter { $0.isPremium && !canUseBodyType($0) }
    }
    
    var premiumHairStyles: [HairStyle] {
        return HairStyle.allCases.filter { $0.isPremium && !canUseHairStyle($0) }
    }
    
    var premiumEyeColors: [EyeColor] {
        return EyeColor.allCases.filter { $0.isPremium && !canUseEyeColor($0) }
    }
    
    var premiumOutfits: [Outfit] {
        return Outfit.allCases.filter { $0.isPremium && !canUseOutfit($0) }
    }
    
    var premiumWeapons: [CharacterWeapon] {
        return CharacterWeapon.allCases.filter { $0.isPremium && !canUseWeapon($0) }
    }
    
    var premiumAccessories: [Accessory] {
        return Accessory.allCases.filter { $0.isPremium && !canUseAccessory($0) }
    }
    
    // MARK: - Reset Methods
    func resetToDefaults() {
        currentCustomization = CharacterCustomization()
        saveCustomization()
    }
    
    func resetOwnedItems() {
        ownedItems = getDefaultOwnedItems()
        saveOwnedItems()
    }
}
