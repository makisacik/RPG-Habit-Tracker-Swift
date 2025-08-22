//
//  CharacterCustomizationStepView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 7.01.2025.
//

import SwiftUI

struct CharacterCustomizationStepView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    let theme: Theme
    @StateObject private var characterCreationViewModel = CharacterCreationViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // Use the new carousel-based character creation view
            CharacterCreationView(
                viewModel: characterCreationViewModel,
                isCharacterCreated: .constant(false)
            )
            .environmentObject(ThemeManager.shared)
            .padding(.top, 16) // Add padding between progress dots and content
            .padding(.bottom, 16) // Add padding between content and navigation buttons
            .onChange(of: characterCreationViewModel.currentCustomization) { customization in
                coordinator.updateCharacterCustomization(customization)
            }
            .onChange(of: characterCreationViewModel.isCustomizationComplete) { isComplete in
                if isComplete {
                    coordinator.markCharacterCustomizationComplete()
                }
            }
        }
        .onAppear {
            // Update coordinator with current customization and mark as complete since defaults are set
            coordinator.updateCharacterCustomization(characterCreationViewModel.currentCustomization)
            if characterCreationViewModel.isCustomizationComplete {
                coordinator.markCharacterCustomizationComplete()
            }
        }
    }
}
