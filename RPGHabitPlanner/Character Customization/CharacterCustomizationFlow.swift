//
//  CharacterCustomizationFlow.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 7.01.2025.
//

import SwiftUI

struct CharacterCustomizationFlow: View {
    let onCustomizationChanged: (CharacterCustomization) -> Void

    @StateObject private var flowCoordinator = CharacterCustomizationFlowCoordinator()
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        let theme = themeManager.activeTheme

        VStack(spacing: 20) {
            // Progress indicator
            CustomizationProgressView(
                currentStep: flowCoordinator.currentStep.rawValue,
                totalSteps: CustomizationStep.allCases.count - 1,
                theme: theme
            )

            // Current step view
            CustomizationStepView(
                step: flowCoordinator.currentStep,
                selectedCustomization: flowCoordinator.selectedCustomization,
                onSelectionChanged: { customization in
                    flowCoordinator.updateCustomization(customization)
                    onCustomizationChanged(customization)
                },
                theme: theme
            )

            Spacer()

            // Navigation buttons
            CustomizationNavigationButtons(
                canGoBack: flowCoordinator.canGoBack,
                canGoForward: flowCoordinator.canGoForward,
                onBack: flowCoordinator.previousStep,
                onForward: flowCoordinator.nextStep,
                theme: theme
            )
        }
        .padding()
        .onAppear {
            flowCoordinator.initializeDefaultCustomization()
            onCustomizationChanged(flowCoordinator.selectedCustomization)
        }
    }
}

// MARK: - Character Customization Flow Coordinator

class CharacterCustomizationFlowCoordinator: ObservableObject {
    @Published var currentStep: CustomizationStep = .skinColor
    @Published var selectedCustomization = CharacterCustomization()

    private let assetManager = CharacterAssetManager.shared

    var canGoBack: Bool {
        return currentStep.rawValue > 0
    }

    var canGoForward: Bool {
        // Optional steps (like accessories) can always proceed
        if currentStep.isOptional {
            return true
        }

        // Required steps need a valid selection
        return hasValidSelection(for: currentStep)
    }

    func nextStep() {
        guard canGoForward else { return }

        if currentStep.rawValue < CustomizationStep.allCases.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep = CustomizationStep(rawValue: currentStep.rawValue + 1) ?? currentStep
            }
        }
    }

    func previousStep() {
        if canGoBack {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep = CustomizationStep(rawValue: currentStep.rawValue - 1) ?? currentStep
            }
        }
    }

    func updateCustomization(_ customization: CharacterCustomization) {
        selectedCustomization = customization
    }

    func initializeDefaultCustomization() {
        selectedCustomization = CharacterCustomization()
    }

    private func hasValidSelection(for step: CustomizationStep) -> Bool {
        switch step {
        case .skinColor:
            return !selectedCustomization.bodyType.rawValue.isEmpty
        case .hairstyle:
            return !selectedCustomization.hairStyle.rawValue.isEmpty
        case .hairBackStyle:
            return true // Optional
        case .eyeColor:
            return !selectedCustomization.eyeColor.rawValue.isEmpty
        case .outfit:
            return !(selectedCustomization.outfit?.rawValue ?? "").isEmpty
        case .weapon:
            return !(selectedCustomization.weapon?.rawValue ?? "").isEmpty
        case .mustache:
            return true // Optional
        case .flower:
            return true // Optional
        case .accessory:
            return true // Optional
        }
    }
}

// MARK: - Customization Steps

enum CustomizationStep: Int, CaseIterable {
    case skinColor = 0  // renamed from bodyType
    case hairstyle = 1  // renamed from hairStyle
    case hairBackStyle = 2  // new step for hair backs
    case eyeColor = 3   // moved up
    case outfit = 4     // moved up
    case weapon = 5     // moved up
    case mustache = 6   // new step for mustaches
    case flower = 7     // new step for flowers
    case accessory = 8  // moved up

    var title: String {
        switch self {
        case .skinColor: return "select_skin_color".localized
        case .hairstyle: return "choose_hairstyle".localized
        case .hairBackStyle: return "choose_hair_back_style".localized
        case .eyeColor: return "select_eye_color".localized
        case .outfit: return "choose_outfit".localized
        case .weapon: return "pick_your_weapon".localized
        case .mustache: return "add_mustache".localized
        case .flower: return "add_flower".localized
        case .accessory: return "add_accessories".localized
        }
    }

    var category: AssetCategory {
        switch self {
        case .skinColor: return .bodyType  // keep the same category mapping
        case .hairstyle: return .hairStyle
        case .hairBackStyle: return .hairBackStyle
        case .eyeColor: return .eyeColor
        case .outfit: return .outfit
        case .weapon: return .weapon
        case .mustache: return .mustache
        case .flower: return .flower
        case .accessory: return .accessory
        }
    }

    var isOptional: Bool {
        return self == .accessory || self == .mustache || self == .flower || self == .hairBackStyle
    }
}
