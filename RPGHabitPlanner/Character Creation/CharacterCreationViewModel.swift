//
//  CharacterCreationViewModel.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import SwiftUI

class CharacterCreationViewModel: ObservableObject {
    // Legacy properties (kept for compatibility)
    @Published var selectedClass: CharacterClass = .knight {
        didSet {
            updateAvailableWeapons()
        }
    }
    @Published var availableWeapons: [Weapon] = []
    @Published var selectedWeapon: Weapon = .swordBroad
    
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
    
    private let weapons: [CharacterClass: [Weapon]] = [
        .knight: [.swordBroad, .swordLong, .swordDouble],
        .archer: [.bow, .crossbow],
        .elephant: [.bow, .crossbow],
        .ninja: [.bow, .crossbow],
        .octopus: [.bow, .crossbow]
    ]
    
    init() {
        updateAvailableWeapons()
    }
    
    private func updateAvailableWeapons() {
        availableWeapons = weapons[selectedClass] ?? []
        selectedWeapon = availableWeapons.first ?? .swordBroad
    }
    
    var previousClass: CharacterClass? {
        guard let index = CharacterClass.allCases.firstIndex(of: selectedClass), index > 0 else { return nil }
        return CharacterClass.allCases[index - 1]
    }
    
    var nextClass: CharacterClass? {
        guard let index = CharacterClass.allCases.firstIndex(of: selectedClass), index < CharacterClass.allCases.count - 1 else { return nil }
        return CharacterClass.allCases[index + 1]
    }
    
    func selectPreviousClass() {
        if let previousClass = previousClass {
            withAnimation {
                selectedClass = previousClass
            }
        }
    }
    
    func selectNextClass() {
        if let nextClass = nextClass {
            withAnimation {
                selectedClass = nextClass
            }
        }
    }

    func previousWeapon(for weapon: Weapon) -> Weapon? {
        guard let index = availableWeapons.firstIndex(of: weapon), index > 0 else { return nil }
        return availableWeapons[index - 1]
    }
    
    func nextWeapon(for weapon: Weapon) -> Weapon? {
        guard let index = availableWeapons.firstIndex(of: weapon), index < availableWeapons.count - 1 else { return nil }
        return availableWeapons[index + 1]
    }
    
    func selectPreviousWeapon() {
        if let previous = previousWeapon(for: selectedWeapon) {
            withAnimation {
                selectedWeapon = previous
            }
        }
    }

    func selectNextWeapon() {
        if let next = nextWeapon(for: selectedWeapon) {
            withAnimation {
                selectedWeapon = next
            }
        }
    }
    
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
    
    func handleClassSwipe(_ value: CGSize) {
        if value.width < -100 {
            selectNextClass()
        } else if value.width > 100 {
            selectPreviousClass()
        }
    }
    
    func handleWeaponSwipe(_ value: CGSize) {
        if value.width < -100 {
            selectNextWeapon()
        } else if value.width > 100 {
            selectPreviousWeapon()
        }
    }
}
