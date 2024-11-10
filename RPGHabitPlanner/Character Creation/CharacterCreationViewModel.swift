//
//  CharacterCreationViewModel.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import SwiftUI

class CharacterCreationViewModel: ObservableObject {
    @Published var selectedClass: CharacterClass?
    @Published var availableWeapons: [String] = []
    @Published var selectedWeapon: String?
    
    private let weapons: [CharacterClass: [String]] = [
        .knight: ["sword-broad", "sword-long", "sword-double"],
        .assassin: ["dagger-golden", "dagger-long", "dagger-double"],
        .archer: ["bow", "crossbow"],
        .wizard: ["staff", "spellbook"]
    ]
    
    func selectClass(_ characterClass: CharacterClass) {
        selectedClass = characterClass
        availableWeapons = weapons[characterClass] ?? []
        selectedWeapon = nil
    }
}
