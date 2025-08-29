//
//  CharacterPreviewCard.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 7.01.2025.
//

import SwiftUI

// MARK: - Reusable Character Display Component

struct CharacterDisplayView: View {
    let customization: CharacterCustomization?
    let size: CGFloat
    let showShadow: Bool
    let hideHairWithHelmet: Bool

    init(customization: CharacterCustomization?, size: CGFloat, showShadow: Bool = true, hideHairWithHelmet: Bool = false) {
        self.customization = customization
        self.size = size
        self.showShadow = showShadow
        self.hideHairWithHelmet = hideHairWithHelmet
    }

    var body: some View {
        if let customization = customization {
            if hideHairWithHelmet {
                CharacterFullPreviewWithGearLogic(customization: customization, size: size)
                    .environmentObject(ThemeManager.shared)
                    .shadow(radius: showShadow ? 8 : 0)
            } else {
                CharacterFullPreview(customization: customization, size: size)
                    .environmentObject(ThemeManager.shared)
                    .shadow(radius: showShadow ? 8 : 0)
            }
        } else {
            // Fallback to default character body image
            Image("char_body_tan")
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .shadow(radius: showShadow ? 8 : 0)
        }
    }
}

struct CharacterPreviewCard: View {
    let customization: CharacterCustomization
    let theme: Theme
    let size: CGSize

    init(customization: CharacterCustomization, theme: Theme, size: CGSize = CGSize(width: 150, height: 150)) {
        self.customization = customization
        self.theme = theme
        self.size = size
    }

    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 20)
                .fill(theme.secondaryColor)
                .shadow(color: theme.textColor.opacity(0.1), radius: 10, x: 0, y: 5)

            // Character layers
            VStack {
                ZStack {
                    // Body background
                    Circle()
                        .fill(getBodyColor(for: customization.bodyType))
                        .frame(width: size.width * 0.7, height: size.height * 0.7)

                    // Character icon placeholder (simplified for now)
                    VStack(spacing: 4) {
                        // Body type icon
                        Image(systemName: "person.fill")
                            .font(.system(size: size.width * 0.3))
                            .foregroundColor(getBodyColor(for: customization.bodyType).opacity(0.8))

                        // Outfit indicator
                        if let outfit = customization.outfit {
                            Text(outfit.displayName)
                                .font(.appFont(size: 8))
                                .foregroundColor(theme.textColor.opacity(0.6))
                        }
                    }
                }

                // Character info
                VStack(spacing: 2) {
                    Text("custom_hero".localized)
                        .font(.appFont(size: 16, weight: .semibold))
                        .foregroundColor(theme.textColor)

                    if let weapon = customization.weapon {
                        Text(weapon.displayName)
                            .font(.appFont(size: 10))
                            .foregroundColor(theme.textColor.opacity(0.7))
                    }
                }
            }
        }
        .frame(width: size.width, height: size.height)
    }
}

// MARK: - Character Full Preview

struct CharacterFullPreview: View {
    let customization: CharacterCustomization
    let size: CGFloat

    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        let theme = themeManager.activeTheme

        // Character layers (proper layering) - removed background for cleaner look
        ZStack {
            // Wings - Draw first so it appears behind everything
            if let wings = customization.wings {
                Image(wings.rawValue)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: size * 0.95)
            }

            // Body
            Image(customization.bodyType.rawValue)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: size * 0.95)
                .onAppear {
                    print("🎭 CharacterFullPreview: Rendering body: \(customization.bodyType.rawValue)")
                }

            // Hair Back - Draw behind the character
            if let hairBackStyle = customization.hairBackStyle {
                Image(hairBackStyle.rawValue)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: size * 0.95)
            }

            // Hair
            Image(customization.hairStyle.rawValue)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: size * 0.95)

            // Head Gear - Draw after hair but before eyes
            if let headGear = customization.headGear {
                Image(headGear.rawValue)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: size * 0.95)
            }

            // Eyes
            Image(customization.eyeColor.rawValue)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: size * 0.95)

            // Glasses (Accessory) - Draw after eyes
            if let accessory = customization.accessory,
               [.eyeglassRed, .eyeglassBlue, .eyeglassGray].contains(accessory) {
                Image(accessory.rawValue)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: size * 0.95)
            }

            // Outfit
            if let outfit = customization.outfit {
                Image(outfit.rawValue)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: size * 0.95)
                    .onAppear {
                        print("👕 CharacterFullPreview: Rendering outfit: \(outfit.rawValue)")
                    }
            }

            // Weapon
            if let weapon = customization.weapon {
                Image(weapon.rawValue)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: size * 0.95)
            }

            // Shield
            if let shield = customization.shield {
                Image(shield.rawValue)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: size * 0.95)
            }


            // Mustache - Draw after outfit but before other accessories
            if let mustache = customization.mustache {
                Image(mustache.rawValue)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: size * 0.95)
            }

            // Flower - Draw after mustache
            if let flower = customization.flower {
                Image(flower.rawValue)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: size * 0.95)
            }

            // Pet - Draw after other accessories
            if let pet = customization.pet {
                Image(pet.rawValue)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: size * 0.95)
                    .offset(x: 30, y: -25)
            }

            // Other Accessories (non-glasses) - Draw last so they appear on top
            if let accessory = customization.accessory {
                if ![.eyeglassRed, .eyeglassBlue, .eyeglassGray].contains(accessory) {
                    Image(accessory.rawValue)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: size * 0.95)
                }
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Character Full Preview With Gear Logic
struct CharacterFullPreviewWithGearLogic: View {
    let customization: CharacterCustomization
    let size: CGFloat

    var body: some View {
        // Character layers (proper layering) - removed background for cleaner look
        ZStack {
            // Wings - Draw first so it appears behind everything
            if let wings = customization.wings {
                Image(wings.rawValue)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: size * 0.95)
            }

            // Body
            Image(customization.bodyType.rawValue)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: size * 0.95)
                .onAppear {
                    print("🎭 CharacterFullPreviewWithGearLogic: Rendering body: \(customization.bodyType.rawValue)")
                }

            // Hair Back - Draw behind the character (only if no helmet is equipped)
            if let hairBackStyle = customization.hairBackStyle, customization.headGear == nil {
                Image(hairBackStyle.rawValue)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: size * 0.95)
            }

            // Hair - Only show if no helmet is equipped
            if customization.headGear == nil {
                Image(customization.hairStyle.rawValue)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: size * 0.95)
            }

            // Head Gear - Draw after hair but before eyes
            if let headGear = customization.headGear {
                Image(headGear.rawValue)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: size * 0.95)
            }

            // Eyes
            Image(customization.eyeColor.rawValue)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: size * 0.95)

            // Glasses (Accessory) - Draw after eyes (only if no helmet is equipped, except shadow veil)
            if let accessory = customization.accessory,
               [.eyeglassRed, .eyeglassBlue, .eyeglassGray].contains(accessory),
               customization.headGear == nil || customization.headGear?.rawValue == "char_helmet_hood" {
                Image(accessory.rawValue)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: size * 0.95)
            }

            // Outfit - Only show if equipped
            if let outfit = customization.outfit {
                Image(outfit.rawValue)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: size * 0.95)
                    .onAppear {
                        print("👕 CharacterFullPreviewWithGearLogic: Rendering outfit: \(outfit.rawValue)")
                    }
            }

            // Weapon - Only show if equipped
            if let weapon = customization.weapon {
                Image(weapon.rawValue)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: size * 0.95)
            }

            // Shield
            if let shield = customization.shield {
                Image(shield.rawValue)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: size * 0.95)
            }

            // Mustache - Draw after outfit but before other accessories (only if no helmet is equipped, except shadow veil and crimson crest)
            if let mustache = customization.mustache,
               customization.headGear == nil || customization.headGear?.rawValue == "char_helmet_hood" || customization.headGear?.rawValue == "char_helmet_red" {
                Image(mustache.rawValue)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: size * 0.95)
            }

            // Flower - Draw after mustache
            if let flower = customization.flower {
                Image(flower.rawValue)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: size * 0.95)
            }

            // Pet - Draw after other accessories
            if let pet = customization.pet {
                Image(pet.rawValue)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: size * 0.95)
                    .offset(x: 30, y: -25)
            }

            // Other Accessories (non-glasses) - Draw last so they appear on top
            if let accessory = customization.accessory {
                if ![.eyeglassRed, .eyeglassBlue, .eyeglassGray].contains(accessory) {
                    Image(accessory.rawValue)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: size * 0.95)
                }
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Helper Functions

private func getBodyColor(for bodyType: BodyType) -> Color {
    return bodyType.color
}

private func getHairColor(for hairColor: HairColor) -> Color {
    return hairColor.color
}
