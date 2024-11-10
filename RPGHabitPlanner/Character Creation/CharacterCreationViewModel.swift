//
//  CharacterCreationViewModel.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import SwiftUI

class CharacterCreationViewModel: ObservableObject {
    @Published var selectedClass: CharacterClass = .knight
    @Published var availableWeapons: [String] = []
    @Published var selectedWeapon = "sword-broad"
    
    init() {
        selectClass(.knight)
        selectedWeapon = "sword-broad"
    }
    
    private let weapons: [CharacterClass: [String]] = [
        .knight: ["sword-broad", "sword-long", "sword-double"],
        .assassin: ["dagger-golden", "dagger-long", "dagger-double"],
        .archer: ["bow", "crossbow"],
        .wizard: ["staff", "spellbook"]
    ]
    
    func selectClass(_ characterClass: CharacterClass) {
        selectedClass = characterClass
        availableWeapons = weapons[characterClass] ?? []
    }
    
    func previousClassName(for characterClass: CharacterClass) -> String {
        guard let index = CharacterClass.allCases.firstIndex(of: characterClass) else { return "" }
        let previousIndex = (index - 1 + CharacterClass.allCases.count) % CharacterClass.allCases.count
        return CharacterClass.allCases[previousIndex].rawValue
    }
    
    func nextClassName(for characterClass: CharacterClass) -> String {
        guard let index = CharacterClass.allCases.firstIndex(of: characterClass) else { return "" }
        let nextIndex = (index + 1) % CharacterClass.allCases.count
        return CharacterClass.allCases[nextIndex].rawValue
    }
    
    func previousWeaponName(for weapon: String) -> String {
        guard let index = availableWeapons.firstIndex(of: weapon) else { return "" }
        let previousIndex = (index - 1 + availableWeapons.count) % availableWeapons.count
        return availableWeapons[previousIndex]
    }

    func nextWeaponName(for weapon: String) -> String {
        guard let index = availableWeapons.firstIndex(of: weapon) else { return "" }
        let nextIndex = (index + 1) % availableWeapons.count
        return availableWeapons[nextIndex]
    }
}
