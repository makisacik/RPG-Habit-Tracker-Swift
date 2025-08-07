//
//  OnboardingViewModel.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import SwiftUI

enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case characterClass = 1
    case characterCustomization = 2
    case nickname = 3
    case final = 4
}

class OnboardingViewModel: ObservableObject {
    @Published var currentStep: OnboardingStep = .welcome
    @Published var selectedCharacterClass: CharacterClass = .knight
    @Published var selectedWeapon: Weapon = .swordBroad
    @Published var nickname: String = ""
    @Published var isOnboardingCompleted: Bool = false
    
    private let userManager = UserManager()
    
    var canProceedToNextStep: Bool {
        switch currentStep {
        case .welcome:
            return true
        case .characterClass:
            return true
        case .characterCustomization:
            return true
        case .nickname:
            return !nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .final:
            return true
        }
    }
    
    func nextStep() {
        guard let currentIndex = OnboardingStep.allCases.firstIndex(of: currentStep),
              currentIndex < OnboardingStep.allCases.count - 1 else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = OnboardingStep.allCases[currentIndex + 1]
        }
    }
    
    func previousStep() {
        guard let currentIndex = OnboardingStep.allCases.firstIndex(of: currentStep),
              currentIndex > 0 else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = OnboardingStep.allCases[currentIndex - 1]
        }
    }
    
    func completeOnboarding() {
        userManager.saveUser(
            nickname: nickname,
            characterClass: selectedCharacterClass,
            weapon: selectedWeapon
        ) { error in
            if let error = error {
                print("Failed to save user: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self.isOnboardingCompleted = true
                }
            }
        }
    }
    
    func updateAvailableWeapons() {
        let weapons: [CharacterClass: [Weapon]] = [
            .knight: [.swordBroad, .swordLong, .swordDouble],
            .archer: [.bow, .crossbow],
            .elephant: [.bow, .crossbow],
            .ninja: [.bow, .crossbow],
            .octopus: [.bow, .crossbow]
        ]
        
        let availableWeapons = weapons[selectedCharacterClass] ?? []
        if !availableWeapons.contains(selectedWeapon) {
            selectedWeapon = availableWeapons.first ?? .swordBroad
        }
    }
}
