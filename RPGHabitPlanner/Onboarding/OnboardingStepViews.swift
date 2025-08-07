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
                            Text("RPG Habit Planner")
                                .font(.appFont(size: 24, weight: .black))
                                .foregroundColor(theme.textColor)
                                .padding(.top, 15)
                        )
                }
                
                Text("Transform Your Habits Into Epic Adventures")
                    .font(.appFont(size: 28, weight: .bold))
                    .foregroundColor(theme.textColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            // Features list
            VStack(spacing: 16) {
                FeatureRow(icon: "sword.fill", title: "Create Epic Quests", description: "Turn daily tasks into heroic missions", theme: theme)
                FeatureRow(icon: "trophy.fill", title: "Earn Rewards", description: "Level up and unlock achievements", theme: theme)
                FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Track Progress", description: "Watch your character grow stronger", theme: theme)
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Welcome message
            Text("Ready to begin your adventure?")
                .font(.appFont(size: 18, weight: .medium))
                .foregroundColor(theme.textColor.opacity(0.8))
                .padding(.bottom, 20)
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Character Class Step
struct CharacterClassStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let theme: Theme
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 12) {
                Text("Choose Your Hero")
                    .font(.appFont(size: 32, weight: .bold))
                    .foregroundColor(theme.textColor)
                
                Text("Select a character class that matches your playstyle")
                    .font(.appFont(size: 16))
                    .foregroundColor(theme.textColor.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            .padding(.top, 20)
            
            // Character class selection
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                ForEach(CharacterClass.allCases, id: \.self) { characterClass in
                    CharacterClassCard(
                        characterClass: characterClass,
                        isSelected: viewModel.selectedCharacterClass == characterClass,
                        theme: theme
                    ) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            viewModel.selectedCharacterClass = characterClass
                            viewModel.updateAvailableWeapons()
                        }
                    }
                }
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
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 12) {
                Text("Customize Your Hero")
                    .font(.appFont(size: 32, weight: .bold))
                    .foregroundColor(theme.textColor)
                
                Text("Choose your weapon and see your character come to life")
                    .font(.appFont(size: 16))
                    .foregroundColor(theme.textColor.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            .padding(.top, 20)
            
            // Character preview
            CharacterPreviewCard(
                characterClass: viewModel.selectedCharacterClass,
                weapon: viewModel.selectedWeapon,
                theme: theme
            )
            .padding(.horizontal, 20)
            
            // Weapon selection
            VStack(spacing: 16) {
                Text("Select Your Weapon")
                    .font(.appFont(size: 20, weight: .bold))
                    .foregroundColor(theme.textColor)
                
                let availableWeapons = getAvailableWeapons(for: viewModel.selectedCharacterClass)
                HStack(spacing: 20) {
                    ForEach(availableWeapons, id: \.self) { weapon in
                        WeaponCard(
                            weapon: weapon,
                            isSelected: viewModel.selectedWeapon == weapon,
                            theme: theme
                        ) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                viewModel.selectedWeapon = weapon
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
    
    private func getAvailableWeapons(for characterClass: CharacterClass) -> [Weapon] {
        let weapons: [CharacterClass: [Weapon]] = [
            .knight: [.swordBroad, .swordLong, .swordDouble],
            .archer: [.bow, .crossbow],
            .elephant: [.bow, .crossbow],
            .ninja: [.bow, .crossbow],
            .octopus: [.bow, .crossbow]
        ]
        return weapons[characterClass] ?? []
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
                Text("Name Your Hero")
                    .font(.appFont(size: 32, weight: .bold))
                    .foregroundColor(theme.textColor)
                
                Text("Choose a legendary name for your character")
                    .font(.appFont(size: 16))
                    .foregroundColor(theme.textColor.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            .padding(.top, 40)
            
            // Character preview with name
            VStack(spacing: 20) {
                CharacterPreviewCard(
                    characterClass: viewModel.selectedCharacterClass,
                    weapon: viewModel.selectedWeapon,
                    theme: theme
                )
                
                if !viewModel.nickname.isEmpty {
                    Text(viewModel.nickname)
                        .font(.appFont(size: 24, weight: .bold))
                        .foregroundColor(theme.buttonTextColor)
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
                TextField("Enter your hero's name", text: $viewModel.nickname)
                    .font(.appFont(size: 18))
                    .foregroundColor(.black)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.9))
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
                
                Text("Maximum 20 characters")
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
    
    var body: some View {
        VStack(spacing: 40) {
            // Header
            VStack(spacing: 16) {
                Text("Ready for Adventure!")
                    .font(.appFont(size: 32, weight: .bold))
                    .foregroundColor(theme.textColor)
                
                Text("Your hero is ready to begin their journey")
                    .font(.appFont(size: 16))
                    .foregroundColor(theme.textColor.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            .padding(.top, 40)
            
            // Final character preview
            VStack(spacing: 20) {
                CharacterPreviewCard(
                    characterClass: viewModel.selectedCharacterClass,
                    weapon: viewModel.selectedWeapon,
                    theme: theme
                )
                
                VStack(spacing: 8) {
                    Text(viewModel.nickname)
                        .font(.appFont(size: 28, weight: .bold))
                        .foregroundColor(theme.buttonTextColor)
                    
                    Text(viewModel.selectedCharacterClass.displayName)
                        .font(.appFont(size: 18, weight: .medium))
                        .foregroundColor(theme.textColor.opacity(0.8))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.cardBackgroundColor)
                )
            }
            .padding(.horizontal, 20)
            
            // Adventure summary
            VStack(spacing: 16) {
                Text("Your Adventure Awaits")
                    .font(.appFont(size: 20, weight: .bold))
                    .foregroundColor(theme.textColor)
                
                VStack(spacing: 12) {
                    AdventureFeatureRow(icon: "sword.fill", text: "Create quests and complete tasks", theme: theme)
                    AdventureFeatureRow(icon: "trophy.fill", text: "Earn experience and level up", theme: theme)
                    AdventureFeatureRow(icon: "star.fill", text: "Unlock achievements and rewards", theme: theme)
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
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
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.appFont(size: 16, weight: .bold))
                    .foregroundColor(theme.textColor)
                
                Text(description)
                    .font(.appFont(size: 14))
                    .foregroundColor(theme.textColor.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.cardBackgroundColor)
        )
    }
}

struct CharacterClassCard: View {
    let characterClass: CharacterClass
    let isSelected: Bool
    let theme: Theme
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                if let image = UIImage(named: characterClass.iconName) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 60)
                }
                
                Text(characterClass.displayName)
                    .font(.appFont(size: 16, weight: .bold))
                    .foregroundColor(theme.textColor)
            }
            .frame(height: 120)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? theme.cardBackgroundColor.opacity(0.8) : theme.cardBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? theme.primaryColor : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CharacterPreviewCard: View {
    let characterClass: CharacterClass
    let weapon: Weapon
    let theme: Theme
    
    var body: some View {
        VStack(spacing: 16) {
            if let image = UIImage(named: characterClass.iconName) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 120)
            }
            
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("Class")
                        .font(.appFont(size: 12))
                        .foregroundColor(theme.textColor.opacity(0.7))
                    
                    Text(characterClass.displayName)
                        .font(.appFont(size: 16, weight: .bold))
                        .foregroundColor(theme.textColor)
                }
                
                VStack(spacing: 4) {
                    Text("Weapon")
                        .font(.appFont(size: 12))
                        .foregroundColor(theme.textColor.opacity(0.7))
                    
                    Text(weapon.displayName)
                        .font(.appFont(size: 16, weight: .bold))
                        .foregroundColor(theme.textColor)
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(theme.cardBackgroundColor)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

struct WeaponCard: View {
    let weapon: Weapon
    let isSelected: Bool
    let theme: Theme
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                if let image = UIImage(named: weapon.iconName) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 40)
                }
                
                Text(weapon.displayName)
                    .font(.appFont(size: 14, weight: .medium))
                    .foregroundColor(theme.textColor)
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? theme.cardBackgroundColor.opacity(0.8) : theme.cardBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? theme.primaryColor : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
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
