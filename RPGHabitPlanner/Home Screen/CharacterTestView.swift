//
//  CharacterTestView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI

struct CharacterTestView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedHair = 1
    @State private var selectedEyes = 1
    @State private var selectedOutfit = 1
    @State private var selectedSword = 1
    
    // Available options for each category
    private let hairOptions = [1, 2]
    private let eyesOptions = [1]
    private let outfitOptions = [1, 2, 3]
    private let swordOptions = [1, 2]
    
    private var characterLayeredView: some View {
        ZStack {
            // Base character body
            Image("char_body")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            
            // Character hair (on top of body)
            Image("char_hair_\(selectedHair)")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            
            // Character eyes (on top of hair)
            Image("char_eyes_\(selectedEyes)")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            
            // Character outfit (on top of eyes)
            Image("char_outfit_\(selectedOutfit)")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            
            // Character sword (on top of outfit)
            Image("char_sword_\(selectedSword)")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
        }
    }
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        NavigationStack {
            ZStack {
                theme.backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Character Display Section
                        VStack(spacing: 16) {
                            Text(String.characterPreview.localized)
                                .font(.appFont(size: 24, weight: .bold))
                                .foregroundColor(theme.textColor)
                            
                            // Character Image with layered assets
                            characterLayeredView
                            .shadow(radius: 8)
                            .padding(.vertical, 20)
                        }
                        .padding(.horizontal, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(theme.primaryColor.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(theme.accentColor.opacity(0.3), lineWidth: 1)
                                )
                        )
                        
                        // Customization Controls
                        VStack(spacing: 20) {
                            Text(String.customizeCharacter.localized)
                                .font(.appFont(size: 20, weight: .bold))
                                .foregroundColor(theme.textColor)
                            
                            // Hair Selection
                            CustomizationSection(
                                title: String.hairStyle.localized,
                                selectedOption: selectedHair,
                                options: hairOptions,
                                theme: theme
                            ) { newSelection in
                                selectedHair = newSelection
                            }
                            
                            // Eyes Selection
                            CustomizationSection(
                                title: String.eyeStyle.localized,
                                selectedOption: selectedEyes,
                                options: eyesOptions,
                                theme: theme
                            ) { newSelection in
                                selectedEyes = newSelection
                            }
                            
                            // Outfit Selection
                            CustomizationSection(
                                title: String.outfit.localized,
                                selectedOption: selectedOutfit,
                                options: outfitOptions,
                                theme: theme
                            ) { newSelection in
                                selectedOutfit = newSelection
                            }
                            
                            // Sword Selection
                            CustomizationSection(
                                title: String.weapon.localized,
                                selectedOption: selectedSword,
                                options: swordOptions,
                                theme: theme
                            ) { newSelection in
                                selectedSword = newSelection
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Current Selection Info
                        VStack(spacing: 12) {
                            Text(String.currentSelection.localized)
                                .font(.appFont(size: 18, weight: .medium))
                                .foregroundColor(theme.textColor)
                            
                            VStack(spacing: 8) {
                                InfoRow(label: String.hairStyle.localized, value: "\(String.style.localized) \(selectedHair)")
                                InfoRow(label: String.eyeStyle.localized, value: "\(String.style.localized) \(selectedEyes)")
                                InfoRow(label: String.outfit.localized, value: "\(String.style.localized) \(selectedOutfit)")
                                InfoRow(label: String.weapon.localized, value: "\(String.style.localized) \(selectedSword)")
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(theme.primaryColor.opacity(0.1))
                        )
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle(String.characterTest.localized)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Supporting Views

struct CustomizationSection: View {
    let title: String
    let selectedOption: Int
    let options: [Int]
    let theme: Theme
    let onSelectionChanged: (Int) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.appFont(size: 16, weight: .medium))
                .foregroundColor(theme.textColor)
            
            HStack(spacing: 12) {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        onSelectionChanged(option)
                    }) {
                        Text("\(option)")
                            .font(.appFont(size: 16, weight: .medium))
                            .foregroundColor(selectedOption == option ? .white : theme.textColor)
                            .frame(width: 50, height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedOption == option ? theme.accentColor : theme.primaryColor.opacity(0.3))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selectedOption == option ? theme.accentColor : theme.accentColor.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                }
                
                Spacer()
            }
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        let theme = themeManager.activeTheme
        
        HStack {
            Text(label)
                .font(.appFont(size: 14))
                .foregroundColor(theme.textColor.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(.appFont(size: 14, weight: .medium))
                .foregroundColor(theme.textColor)
        }
    }
}

#Preview {
    CharacterTestView()
        .environmentObject(ThemeManager.shared)
}
