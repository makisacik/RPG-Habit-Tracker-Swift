//
//  OnboardingView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var viewModel = OnboardingViewModel()
    @Binding var isOnboardingCompleted: Bool
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    theme.gradientStart.opacity(0.1),
                    theme.backgroundColor,
                    theme.gradientEnd.opacity(0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress indicator
                ProgressIndicator(currentStep: viewModel.currentStep, totalSteps: OnboardingStep.allCases.count, theme: theme)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                // Content area
                TabView(selection: $viewModel.currentStep) {
                    WelcomeStepView(viewModel: viewModel, theme: theme)
                        .tag(OnboardingStep.welcome)
                    
                    CharacterClassStepView(viewModel: viewModel, theme: theme)
                        .tag(OnboardingStep.characterClass)
                    
                    CharacterCustomizationStepView(viewModel: viewModel, theme: theme)
                        .tag(OnboardingStep.characterCustomization)
                    
                    NicknameStepView(viewModel: viewModel, theme: theme)
                        .tag(OnboardingStep.nickname)
                    
                    FinalStepView(viewModel: viewModel, theme: theme)
                        .tag(OnboardingStep.final)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
                
                // Navigation buttons
                NavigationButtonsView(viewModel: viewModel, isOnboardingCompleted: $isOnboardingCompleted, theme: theme)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
        }
        .onChange(of: viewModel.isOnboardingCompleted) { completed in
            if completed {
                withAnimation(.easeInOut(duration: 0.8)) {
                    isOnboardingCompleted = true
                }
            }
        }
    }
}

// MARK: - Progress Indicator
struct ProgressIndicator: View {
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
struct NavigationButtonsView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var isOnboardingCompleted: Bool
    let theme: Theme
    
    var body: some View {
        HStack {
            // Back button
            if viewModel.currentStep != .welcome {
                Button(action: {
                    viewModel.previousStep()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                        Text(String.backButton.localized)
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
                if viewModel.currentStep == .final {
                    viewModel.completeOnboarding()
                } else {
                    viewModel.nextStep()
                }
            }) {
                HStack(spacing: 8) {
                    Text(viewModel.currentStep == .final ? String.startAdventure.localized : String.nextButton.localized)
                        .font(.appFont(size: 16, weight: .bold))
                    
                    if viewModel.currentStep != .final {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .medium))
                    }
                }
                .foregroundColor(theme.buttonTextColor)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [theme.gradientStart, theme.gradientEnd]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: theme.primaryColor.opacity(0.3), radius: 8, x: 0, y: 4)
                )
            }
            .disabled(!viewModel.canProceedToNextStep)
            .opacity(viewModel.canProceedToNextStep ? 1.0 : 0.5)
        }
    }
}

#Preview {
    OnboardingView(isOnboardingCompleted: .constant(false))
        .environmentObject(ThemeManager.shared)
}
