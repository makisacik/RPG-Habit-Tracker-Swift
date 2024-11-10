//
//  CharacterCreationViewModel.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import SwiftUI

class CharacterCreationViewModel: ObservableObject {
    @Published var selectedClass: CharacterClass = .knight {
        didSet {
            updateAvailableWeapons()
        }
    }
    @Published var availableWeapons: [String] = []
    @Published var selectedWeapon = "sword-broad"
    
    init() {
        updateAvailableWeapons()
    }
    
    private let weapons: [CharacterClass: [String]] = [
        .knight: ["sword-broad", "sword-long", "sword-double"],
        .assassin: ["dagger-golden", "dagger-long", "dagger-double"],
        .archer: ["bow", "crossbow"],
        .wizard: ["staff", "spellbook"]
    ]
    
    private func updateAvailableWeapons() {
        availableWeapons = weapons[selectedClass] ?? []
        selectedWeapon = availableWeapons.first ?? "" // Set to the first available weapon
    }
    
    var previousClass: CharacterClass? {
        guard let index = CharacterClass.allCases.firstIndex(of: selectedClass),
            index > 0 else { return nil }
        return CharacterClass.allCases[index - 1]
    }
    
    var nextClass: CharacterClass? {
        guard let index = CharacterClass.allCases.firstIndex(of: selectedClass),
            index < CharacterClass.allCases.count - 1 else { return nil }
        return CharacterClass.allCases[index + 1]
    }
    
    func previousWeaponName(for weapon: String) -> String? {
        guard let index = availableWeapons.firstIndex(of: weapon), index > 0 else { return nil }
        return availableWeapons[index - 1]
    }

    func nextWeaponName(for weapon: String) -> String? {
        guard let index = availableWeapons.firstIndex(of: weapon), index < availableWeapons.count - 1 else { return nil }
        return availableWeapons[index + 1]
    }
}
