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
    @Published var selectedTitle: CharacterTitle = .theBrave
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
        case .titleSelection:
            return true
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
        print("🚀 OnboardingCoordinator: Starting completeOnboarding")
        print("🚀 OnboardingCoordinator: Nickname: \(nickname)")
        print("🚀 OnboardingCoordinator: Character customization: \(characterCustomization)")

        // Save character customization data to UserDefaults (for backward compatibility)
        customizationManager.currentCustomization = characterCustomization
        customizationManager.saveCustomization()
        print("✅ OnboardingCoordinator: Saved to UserDefaults")

        // Save user with new customization system
        userManager.saveUser(
            nickname: nickname,
            title: selectedTitle.rawValue,
            characterClass: "Custom",
            weapon: characterCustomization.weapon.rawValue
        ) { [weak self] error in
            if let error = error {
                print("❌ OnboardingCoordinator: Failed to save user: \(error.localizedDescription)")
            } else {
                print("✅ OnboardingCoordinator: User saved successfully")
                // After user is saved, save character customization to Core Data
                self?.userManager.fetchUser { user, fetchError in
                    if let user = user, fetchError == nil {
                        print("✅ OnboardingCoordinator: Fetched user for customization save")
                        let customizationService = CharacterCustomizationService()
                        if let customizationEntity = customizationService.createCustomization(for: user, customization: self?.characterCustomization ?? CharacterCustomization()) {
                            print("✅ OnboardingCoordinator: Character customization saved to Core Data successfully")
                            print("🔧 OnboardingCoordinator: Created entity with ID: \(customizationEntity.id?.uuidString ?? "nil")")
                        } else {
                            print("❌ OnboardingCoordinator: Failed to create character customization in Core Data")
                        }
                    } else {
                        print("❌ OnboardingCoordinator: Failed to fetch user for customization save: \(fetchError?.localizedDescription ?? "Unknown error")")
                    }

                    // Add onboarding completion items to inventory
                    DispatchQueue.main.async {
                        let inventoryManager = InventoryManager.shared
                        inventoryManager.addOnboardingCompletionItems(characterCustomization: self?.characterCustomization)
                        print("✅ OnboardingCoordinator: Onboarding completion items added to inventory")
                    }

                    DispatchQueue.main.async {
                        print("✅ OnboardingCoordinator: Setting isOnboardingCompleted to true")
                        self?.isOnboardingCompleted = true
                    }
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
    case titleSelection = 3
    case final = 4

    var title: String {
        switch self {
        case .welcome: return "Welcome"
        case .characterCustomization: return "Customize Character"
        case .nickname: return "Choose Name"
        case .titleSelection: return "Choose Title"
        case .final: return "Ready"
        }
    }
}
