//
//  CharacterTestView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI

struct CharacterTestView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedBody = 0
    @State private var selectedHair = 0
    @State private var selectedEyes = 0
    @State private var selectedEyeglass = 0
    @State private var selectedOutfit = 0
    @State private var selectedSword = 0
    @State private var selectedHelmet = 0
    @State private var selectedWings = 0
    @State private var selectedCheek = 0
    @State private var selectedEyelashes = 0
    @State private var isCharacterVisible = false
    
    // Available options for each category with descriptive names
    private let bodyOptions = [
        (0, "Default"),
        (1, "White Skin")
    ]

    private let hairOptions = [
        (0, "None"),
        (1, "Brown 1"),
        (2, "Brown 2"),
        (3, "Punk")
    ]

    private let eyesOptions = [
        (0, "Default"),
        (1, "Blue"),
        (2, "Green"),
        (3, "Brown")
    ]

    private let eyeglassOptions = [
        (0, "None"),
        (1, "Red"),
        (2, "Blue"),
        (3, "Gray")
    ]

    private let outfitOptions = [
        (0, "None"),
        (1, "Iron"),
        (2, "Assassin"),
        (3, "Bat"),
        (4, "Dress"),
        (5, "Fire 1"),
        (6, "Simple"),
        (7, "Hoodie Green"),
        (8, "Red")
    ]

    private let swordOptions = [
        (0, "None"),
        (1, "Axish"),
        (2, "Dagger Wood"),
        (3, "Mace"),
        (4, "Copper"),
        (5, "Dagger"),
        (6, "Deadly"),
        (7, "Firelord"),
        (8, "Iron")
    ]

    private let helmetOptions = [
        (0, "None"),
        (1, "Red")
    ]

    private let wingsOptions = [
        (0, "None"),
        (1, "White")
    ]

    private let cheekOptions = [
        (0, "None"),
        (1, "Blush")
    ]

    private let eyelashesOptions = [
        (0, "None"),
        (1, "Eyelashes")
    ]
    
    private var characterLayeredView: some View {
        ZStack {
            // 1. Base character body (bottom layer)
            if selectedBody == 0 {
                Image("char_body")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 400)
            } else {
                Image("char_body_white_skin")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 400)
            }
            
            // 2. Character outfit (on top of body)
            if selectedOutfit > 0 {
                let outfitNames = ["iron", "asassin", "bat", "dress", "fire_1", "simple", "hoodie_green", "red"]
                Image("char_outfit_\(outfitNames[selectedOutfit - 1])")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 400)
            }
            
            // 3. Character hair (on top of outfit)
            if selectedHair > 0 {
                if selectedHair == 3 {
                    Image("char_hair_punk")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 400, height: 400)
                } else {
                    Image("char_hair_brown_\(selectedHair)")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 400, height: 400)
                }
            }
            
            // 4. Character eyes (on top of hair)
            if selectedEyes > 0 {
                Image("char_eyeball_\(["blue", "green", "brown"][selectedEyes - 1])")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 400)
            }
            
            // 5. Character eyelashes (on top of eyes)
            if selectedEyelashes > 0 {
                Image("char_eye_lashes")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 400)
            }
            
            // 6. Character cheek blush (on top of eyelashes)
            if selectedCheek > 0 {
                Image("char_cheek_blush")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 400)
            }
            
            // 7. Character helmet (on top of face features)
            if selectedHelmet > 0 {
                Image("char_helmet_red")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 400)
            }
            
            // 8. Character weapon (held in hand, on top of outfit)
            if selectedSword > 0 {
                let swordNames = ["axish", "dagger_wood", "mace", "copper", "dagger", "deadly", "firelord", "iron"]
                Image("char_sword_\(swordNames[selectedSword - 1])")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 400)
            }
            
            // 9. Character eyeglasses (on top of face, under helmet)
            if selectedEyeglass > 0 {
                let eyeglassNames = ["red", "blue", "gray"]
                Image("char_eyeglass_\(eyeglassNames[selectedEyeglass - 1])")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 400)
            }
            
            // 10. Character wings (back accessory, on top of everything)
            if selectedWings > 0 {
                Image("char_wings_white")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 400)
            }
        }
        .drawingGroup() // Renders the ZStack as a single layer for better performance
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
                            if isCharacterVisible {
                                characterLayeredView
                                .shadow(radius: 8)
                                .padding(.vertical, 20)
                                .transition(.opacity.combined(with: .scale))
                            } else {
                                // Placeholder while loading
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(theme.primaryColor.opacity(0.3))
                                    .frame(width: 400, height: 400)
                                    .padding(.vertical, 20)
                            }
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
                            
                            // Body Selection
                            CustomizationSection(
                                title: "Body",
                                selectedOption: selectedBody,
                                options: bodyOptions,
                                theme: theme
                            ) { newSelection in
                                selectedBody = newSelection
                            }
                            
                            // Hair Selection
                            CustomizationSection(
                                title: "Hair Style",
                                selectedOption: selectedHair,
                                options: hairOptions,
                                theme: theme
                            ) { newSelection in
                                selectedHair = newSelection
                            }
                            
                            // Eyes Selection
                            CustomizationSection(
                                title: "Eye Color",
                                selectedOption: selectedEyes,
                                options: eyesOptions,
                                theme: theme
                            ) { newSelection in
                                selectedEyes = newSelection
                            }
                            
                            // Eyelashes Selection
                            CustomizationSection(
                                title: "Eyelashes",
                                selectedOption: selectedEyelashes,
                                options: eyelashesOptions,
                                theme: theme
                            ) { newSelection in
                                selectedEyelashes = newSelection
                            }
                            
                            // Cheek Selection
                            CustomizationSection(
                                title: "Cheek",
                                selectedOption: selectedCheek,
                                options: cheekOptions,
                                theme: theme
                            ) { newSelection in
                                selectedCheek = newSelection
                            }
                            
                            // Outfit Selection
                            CustomizationSection(
                                title: "Outfit",
                                selectedOption: selectedOutfit,
                                options: outfitOptions,
                                theme: theme
                            ) { newSelection in
                                selectedOutfit = newSelection
                            }
                            
                            // Helmet Selection
                            CustomizationSection(
                                title: "Helmet",
                                selectedOption: selectedHelmet,
                                options: helmetOptions,
                                theme: theme
                            ) { newSelection in
                                selectedHelmet = newSelection
                            }
                            
                            // Sword Selection
                            CustomizationSection(
                                title: "Weapon",
                                selectedOption: selectedSword,
                                options: swordOptions,
                                theme: theme
                            ) { newSelection in
                                selectedSword = newSelection
                            }
                            
                            // Wings Selection
                            CustomizationSection(
                                title: "Wings",
                                selectedOption: selectedWings,
                                options: wingsOptions,
                                theme: theme
                            ) { newSelection in
                                selectedWings = newSelection
                            }
                            
                            // Eyeglasses Selection
                            CustomizationSection(
                                title: "Eyeglasses",
                                selectedOption: selectedEyeglass,
                                options: eyeglassOptions,
                                theme: theme
                            ) { newSelection in
                                selectedEyeglass = newSelection
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Current Selection Info
                        VStack(spacing: 12) {
                            Text(String.currentSelection.localized)
                                .font(.appFont(size: 18, weight: .medium))
                                .foregroundColor(theme.textColor)
                            
                            VStack(spacing: 8) {
                                InfoRow(label: "Body", value: bodyOptions[selectedBody].1)
                                InfoRow(label: "Hair", value: hairOptions[selectedHair].1)
                                InfoRow(label: "Eyes", value: eyesOptions[selectedEyes].1)
                                InfoRow(label: "Eyelashes", value: eyelashesOptions[selectedEyelashes].1)
                                InfoRow(label: "Cheek", value: cheekOptions[selectedCheek].1)
                                InfoRow(label: "Outfit", value: outfitOptions[selectedOutfit].1)
                                InfoRow(label: "Helmet", value: helmetOptions[selectedHelmet].1)
                                InfoRow(label: "Weapon", value: swordOptions[selectedSword].1)
                                InfoRow(label: "Wings", value: wingsOptions[selectedWings].1)
                                InfoRow(label: "Eyeglasses", value: eyeglassOptions[selectedEyeglass].1)
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
            .onAppear {
                // Delay character loading to reduce initial memory usage
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isCharacterVisible = true
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct CustomizationSection: View {
    let title: String
    let selectedOption: Int
    let options: [(Int, String)]
    let theme: Theme
    let onSelectionChanged: (Int) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.appFont(size: 16, weight: .medium))
                .foregroundColor(theme.textColor)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(options, id: \.0) { option in
                    Button(action: {
                        onSelectionChanged(option.0)
                    }) {
                        VStack(spacing: 4) {
                            Text("\(option.0)")
                                .font(.appFont(size: 14, weight: .medium))
                                .foregroundColor(selectedOption == option.0 ? .white : theme.textColor)
                            
                            Text(option.1)
                                .font(.appFont(size: 10))
                                .foregroundColor(selectedOption == option.0 ? .white.opacity(0.8) : theme.textColor.opacity(0.7))
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                        }
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedOption == option.0 ? theme.accentColor : theme.primaryColor.opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedOption == option.0 ? theme.accentColor : theme.accentColor.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                }
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
