//
//  OnboardingFlowView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 7.01.2025.
//

import SwiftUI

struct OnboardingFlowView: View {
    @StateObject private var coordinator = OnboardingCoordinator()
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var isOnboardingCompleted: Bool

    var body: some View {
        let theme = themeManager.activeTheme

        ZStack {
            // Background
            theme.backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress indicator
                OnboardingProgressIndicator(
                    currentStep: coordinator.currentStep,
                    totalSteps: OnboardingStep.allCases.count,
                    theme: theme
                )
                .padding(.horizontal, 20)
                .padding(.top, 20)

                // Content area
                TabView(selection: $coordinator.currentStep) {
                    WelcomeStepView(coordinator: coordinator, theme: theme)
                        .tag(OnboardingStep.welcome)

                    CharacterCustomizationStepView(coordinator: coordinator, theme: theme)
                        .tag(OnboardingStep.characterCustomization)

                    NicknameStepView(coordinator: coordinator, theme: theme)
                        .tag(OnboardingStep.nickname)

                    TitleSelectionStepView(coordinator: coordinator, theme: theme)
                        .tag(OnboardingStep.titleSelection)

                    FinalStepView(coordinator: coordinator, theme: theme)
                        .tag(OnboardingStep.final)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: coordinator.currentStep)

                // Navigation buttons
                OnboardingNavigationButtons(
                    coordinator: coordinator,
                    isOnboardingCompleted: $isOnboardingCompleted,
                    theme: theme
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .onChange(of: coordinator.isOnboardingCompleted) { completed in
            if completed {
                withAnimation(.easeInOut(duration: 0.8)) {
                    isOnboardingCompleted = true
                }
            }
        }
    }
}

// MARK: - Progress Indicator

struct OnboardingProgressIndicator: View {
    let currentStep: OnboardingStep
    let totalSteps: Int
    let theme: Theme

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Circle()
                    .fill(index <= OnboardingStep.allCases.firstIndex(of: currentStep) ?? 0 ?
                          theme.accentColor : theme.textColor.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .scaleEffect(index == OnboardingStep.allCases.firstIndex(of: currentStep) ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentStep)
            }
        }
    }
}

// MARK: - Navigation Buttons

struct OnboardingNavigationButtons: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    @Binding var isOnboardingCompleted: Bool
    let theme: Theme

    var body: some View {
        HStack {
            // Back button
            if coordinator.currentStep != .welcome {
                Button(action: {
                    coordinator.previousStep()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                        Text("Back")
                            .font(.appFont(size: 16, weight: .medium))
                    }
                    .foregroundColor(theme.textColor)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(theme.primaryColor.opacity(0.8))
                    )
                }
            }

            Spacer()

            // Next/Complete button
            Button(action: {
                if coordinator.currentStep == .final {
                    coordinator.completeOnboarding()
                } else {
                    coordinator.nextStep()
                }
            }) {
                HStack(spacing: 8) {
                    Text(coordinator.currentStep == .final ? "Start Adventure" : "Next")
                        .font(.appFont(size: 16, weight: .medium))
                    Image(systemName: coordinator.currentStep == .final ? "play.fill" : "chevron.right")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(coordinator.canProceedToNextStep ? theme.accentColor : theme.accentColor.opacity(0.5))
                )
            }
            .disabled(!coordinator.canProceedToNextStep)
        }
    }
}
