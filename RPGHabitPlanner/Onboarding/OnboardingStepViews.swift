//
//  OnboardingStepViews.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import SwiftUI
import UIKit

// MARK: - Welcome Step
struct WelcomeStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let theme: Theme
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // App icon and title
            VStack(spacing: 20) {
                if let image = UIImage(named: "banner_hanging") {
                    Image(uiImage: image)
                        .resizable()
                        .frame(height: 80)
                        .overlay(
                            Text(String.welcomeToRPGHabitPlanner.localized)
                                .font(.appFont(size: 24, weight: .black))
                                .foregroundColor(theme.textColor)
                                .padding(.top, 15)
                        )
                }
                
                Text(String.transformHabitsIntoEpicAdventures.localized)
                    .font(.appFont(size: 28, weight: .bold))
                    .foregroundColor(theme.textColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            // Features list
            VStack(spacing: 16) {
                FeatureRow(icon: "scroll.fill", title: String.createEpicQuests.localized, description: String.turnDailyTasksIntoHeroicMissions.localized, theme: theme)
                FeatureRow(icon: "trophy.fill", title: String.earnRewards.localized, description: String.levelUpAndUnlockAchievements.localized, theme: theme)
                FeatureRow(icon: "chart.line.uptrend.xyaxis", title: String.trackProgress.localized, description: String.watchYourCharacterGrowStronger.localized, theme: theme)
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Welcome message
            Text(String.readyToBeginAdventure.localized)
                .font(.appFont(size: 18, weight: .medium))
                .foregroundColor(theme.textColor.opacity(0.8))
                .padding(.bottom, 20)
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Character Class Step (Replaced with Customization)
struct CharacterClassStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let theme: Theme
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 12) {
                Text(String.chooseYourHero.localized)
                    .font(.appFont(size: 32, weight: .bold))
                    .foregroundColor(theme.textColor)
                
                Text(String.selectCharacterClassForPlaystyle.localized)
                    .font(.appFont(size: 16))
                    .foregroundColor(theme.textColor.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            .padding(.top, 20)
            
            // Placeholder for character class selection (deprecated)
            VStack(spacing: 20) {
                Text("Character customization has been moved to the next step!")
                    .font(.appFont(size: 18, weight: .medium))
                    .foregroundColor(theme.textColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                Image(systemName: "person.fill.questionmark")
                    .font(.system(size: 60))
                    .foregroundColor(theme.textColor.opacity(0.5))
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
}

// MARK: - Character Customization Step
struct CharacterCustomizationStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let theme: Theme
    @State private var isCustomizationCompleted = false
    
    var body: some View {
        if isCustomizationCompleted {
            // Show completion state
            VStack(spacing: 30) {
                VStack(spacing: 12) {
                    Text(String.customizeYourHero.localized)
                        .font(.appFont(size: 32, weight: .bold))
                        .foregroundColor(theme.textColor)
                    
                    Text("Character customization completed!")
                        .font(.appFont(size: 16))
                        .foregroundColor(theme.textColor.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 20)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                
                Spacer()
            }
        } else {
            // Show character customization view
            CharacterCustomizationOnboardingView(isCustomizationCompleted: $isCustomizationCompleted)
                .environmentObject(ThemeManager.shared)
        }
    }
}

// MARK: - Nickname Step
struct NicknameStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let theme: Theme
    
    var body: some View {
        VStack(spacing: 40) {
            // Header
            VStack(spacing: 16) {
                Text(String.nameYourHero.localized)
                    .font(.appFont(size: 32, weight: .bold))
                    .foregroundColor(theme.textColor)
                
                Text(String.chooseLegendaryNameForCharacter.localized)
                    .font(.appFont(size: 16))
                    .foregroundColor(theme.textColor.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            .padding(.top, 40)
            
            // Character preview with name
            VStack(spacing: 20) {
                CustomizedCharacterPreviewCard(
                    customization: viewModel.customizationManager.currentCustomization,
                    theme: theme
                )
                
                if !viewModel.nickname.isEmpty {
                    Text(viewModel.nickname)
                        .font(.appFont(size: 24, weight: .bold))
                        .foregroundColor(theme.textColor)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(theme.cardBackgroundColor)
                        )
                }
            }
            .padding(.horizontal, 20)
            
            // Nickname input
            VStack(spacing: 16) {
                TextField(String.enterYourHerosName.localized, text: $viewModel.nickname)
                    .font(.appFont(size: 18))
                    .foregroundColor(theme.textColor)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(theme.cardBackgroundColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(theme.primaryColor.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .textFieldStyle(PlainTextFieldStyle())
                    .onChange(of: viewModel.nickname) { newValue in
                        // Limit to 20 characters
                        if newValue.count > 20 {
                            viewModel.nickname = String(newValue.prefix(20))
                        }
                    }
                
                Text(String.maximum20Characters.localized)
                    .font(.appFont(size: 12))
                    .foregroundColor(theme.textColor.opacity(0.5))
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
}

// MARK: - Final Step
struct FinalStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let theme: Theme
    @State private var showCompletionAnimation = false
    @State private var showSparkles = false
    @State private var heroScale: CGFloat = 0.8
    @State private var heroRotation: Double = 0
    @State private var backgroundGlow = false
    
    var body: some View {
        ZStack {
            // Animated background
            if backgroundGlow {
                RadialGradient(
                    gradient: Gradient(colors: [
                        theme.primaryColor.opacity(0.3),
                        theme.backgroundColor,
                        theme.backgroundColor
                    ]),
                    center: .center,
                    startRadius: 50,
                    endRadius: 300
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 2.0), value: backgroundGlow)
            }
            
            VStack(spacing: 40) {
                // Header
                VStack(spacing: 16) {
                    Text(String.readyForAdventure.localized)
                        .font(.appFont(size: 32, weight: .bold))
                        .foregroundColor(theme.textColor)
                        .scaleEffect(showCompletionAnimation ? 1.1 : 1.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showCompletionAnimation)
                    
                    Text(String.yourHeroIsReadyToBeginJourney.localized)
                        .font(.appFont(size: 16))
                        .foregroundColor(theme.textColor.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .opacity(showCompletionAnimation ? 1.0 : 0.8)
                        .animation(.easeInOut(duration: 1.0), value: showCompletionAnimation)
                }
                .padding(.top, 40)
                
                // Final character preview
            VStack(spacing: 20) {
                ZStack {
                    CustomizedCharacterPreviewCard(
                        customization: viewModel.customizationManager.currentCustomization,
                        theme: theme
                    )
                    .scaleEffect(heroScale)
                    .rotationEffect(.degrees(heroRotation))
                    .animation(.spring(response: 0.8, dampingFraction: 0.6), value: heroScale)
                    .animation(.easeInOut(duration: 1.0), value: heroRotation)
                    
                    // Sparkle effects on top
                    if showSparkles {
                        ForEach(0..<8, id: \.self) { index in
                            SparkleView(theme: theme)
                                .offset(
                                    x: CGFloat.random(in: -100...100),
                                    y: CGFloat.random(in: -100...100)
                                )
                                .animation(
                                    .easeInOut(duration: 1.5)
                                    .delay(Double(index) * 0.1),
                                    value: showSparkles
                                )
                        }
                    }
                }
                
                VStack(spacing: 8) {
                    Text(viewModel.nickname)
                        .font(.appFont(size: 28, weight: .bold))
                        .foregroundColor(theme.textColor)
                        .scaleEffect(showCompletionAnimation ? 1.05 : 1.0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: showCompletionAnimation)
                    
                    Text("Adventurer")
                        .font(.appFont(size: 18, weight: .medium))
                        .foregroundColor(theme.textColor.opacity(0.8))
                        .opacity(showCompletionAnimation ? 1.0 : 0.7)
                        .animation(.easeInOut(duration: 0.8), value: showCompletionAnimation)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.cardBackgroundColor)
                )
                .scaleEffect(showCompletionAnimation ? 1.02 : 1.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showCompletionAnimation)
            }
            .padding(.horizontal, 20)
            
            // Adventure summary
            VStack(spacing: 16) {
                Text(String.yourAdventureAwaits.localized)
                    .font(.appFont(size: 20, weight: .bold))
                    .foregroundColor(theme.textColor)
                    .opacity(showCompletionAnimation ? 1.0 : 0.8)
                    .animation(.easeInOut(duration: 1.2), value: showCompletionAnimation)
                
                VStack(spacing: 12) {
                    AdventureFeatureRow(icon: "sword.fill", text: "Create quests and complete tasks", theme: theme)
                        .opacity(showCompletionAnimation ? 1.0 : 0.6)
                        .animation(.easeInOut(duration: 0.8).delay(0.2), value: showCompletionAnimation)
                    AdventureFeatureRow(icon: "trophy.fill", text: "Earn experience and level up", theme: theme)
                        .opacity(showCompletionAnimation ? 1.0 : 0.6)
                        .animation(.easeInOut(duration: 0.8).delay(0.4), value: showCompletionAnimation)
                    AdventureFeatureRow(icon: "star.fill", text: "Unlock achievements and rewards", theme: theme)
                        .opacity(showCompletionAnimation ? 1.0 : 0.6)
                        .animation(.easeInOut(duration: 0.8).delay(0.6), value: showCompletionAnimation)
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
            }
        }
        .onAppear {
            startCompletionAnimation()
        }
    }
    
    private func startCompletionAnimation() {
        // Start background glow
        withAnimation(.easeInOut(duration: 1.0)) {
            backgroundGlow = true
        }
        
        // Start main completion animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                showCompletionAnimation = true
                heroScale = 1.0
            }
        }
        
        // Start sparkles
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeInOut(duration: 0.5)) {
                showSparkles = true
            }
        }
        
        // Hero rotation effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeInOut(duration: 1.0)) {
                heroRotation = 360
            }
        }
    }
}

// MARK: - Sparkle View
struct SparkleView: View {
    let theme: Theme
    @State private var isAnimating = false
    
    var body: some View {
        Image(systemName: "sparkle")
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(theme.primaryColor)
            .scaleEffect(isAnimating ? 1.5 : 0.5)
            .opacity(isAnimating ? 0.0 : 1.0)
            .rotationEffect(.degrees(isAnimating ? 180 : 0))
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}

// MARK: - Supporting Views
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let theme: Theme
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(theme.textColor)
                .frame(width: 40)
                .frame(minWidth: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.appFont(size: 16, weight: .bold))
                    .foregroundColor(theme.textColor)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(description)
                    .font(.appFont(size: 14))
                    .foregroundColor(theme.textColor.opacity(0.7))
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.cardBackgroundColor)
        )
    }
}

// CharacterClassCard removed - no longer needed with new customization system

struct CharacterPreviewCard: View {
    let customization: CharacterCustomization
    let theme: Theme
    
    var body: some View {
        VStack(spacing: 16) {
            // Custom Character Display
            CustomizedCharacterPreviewCard(
                customization: customization,
                theme: theme,
                size: CGSize(width: 120, height: 120)
            )
            
            VStack(spacing: 4) {
                Text(String.character.localized)
                    .font(.appFont(size: 12))
                    .foregroundColor(theme.textColor.opacity(0.7))
                
                Text("Custom Character")
                    .font(.appFont(size: 16, weight: .bold))
                    .foregroundColor(theme.textColor)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(theme.cardBackgroundColor)
                .shadow(color: theme.textColor.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}


struct AdventureFeatureRow: View {
    let icon: String
    let text: String
    let theme: Theme
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(theme.textColor)
            
            Text(text)
                .font(.appFont(size: 14))
                .foregroundColor(theme.textColor.opacity(0.8))
            
            Spacer()
        }
    }
}
