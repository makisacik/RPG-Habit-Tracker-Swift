//
//  OnboardingCoordinator.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 7.01.2025.
//

import SwiftUI

// MARK: - Onboarding Coordinator

class OnboardingCoordinator: ObservableObject {
    @Published var currentStep: OnboardingStep = .welcome
    @Published var isOnboardingCompleted: Bool = false

    // Character customization data
    @Published var nickname: String = ""
    @Published var characterCustomization = CharacterCustomization()
    @Published var isCharacterCustomizationComplete: Bool = false

    // Services
    private let userManager = UserManager()
    private let customizationManager = CharacterCustomizationManager()

    var canProceedToNextStep: Bool {
        switch currentStep {
        case .welcome:
            return true
        case .characterCustomization:
            return isCharacterCustomizationComplete
        case .nickname:
            return !nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .final:
            return true
        }
    }

    func nextStep() {
        // Dismiss keyboard before navigation
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

        guard let currentIndex = OnboardingStep.allCases.firstIndex(of: currentStep),
              currentIndex < OnboardingStep.allCases.count - 1 else { return }

        let nextStep = OnboardingStep.allCases[currentIndex + 1]

        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = nextStep
        }

        // Show keyboard when navigating to nickname step
        if nextStep == .nickname {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                // Find and focus the text field in the nickname step
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    window.makeKey()
                    // Trigger focus on the text field
                    NotificationCenter.default.post(name: NSNotification.Name("FocusNicknameTextField"), object: nil)
                }
            }
        }
    }

    func previousStep() {
        // Dismiss keyboard before navigation
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

        guard let currentIndex = OnboardingStep.allCases.firstIndex(of: currentStep),
              currentIndex > 0 else { return }

        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = OnboardingStep.allCases[currentIndex - 1]
        }
    }

    func completeOnboarding() {
        // Save character customization data
        customizationManager.currentCustomization = characterCustomization
        customizationManager.saveCustomization()

        // Save user with new customization system
        userManager.saveUser(
            nickname: nickname,
            characterClass: "Custom",
            weapon: characterCustomization.weapon.rawValue
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

    func updateCharacterCustomization(_ customization: CharacterCustomization) {
        self.characterCustomization = customization
    }

    func markCharacterCustomizationComplete() {
        self.isCharacterCustomizationComplete = true
    }
}

// MARK: - Onboarding Steps

enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case characterCustomization = 1
    case nickname = 2
    case final = 3

    var title: String {
        switch self {
        case .welcome: return "Welcome"
        case .characterCustomization: return "Customize Character"
        case .nickname: return "Choose Name"
        case .final: return "Ready"
        }
    }
}
