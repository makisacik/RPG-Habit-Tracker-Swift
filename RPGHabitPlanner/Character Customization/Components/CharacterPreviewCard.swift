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

    init(customization: CharacterCustomization?, size: CGFloat, showShadow: Bool = true) {
        self.customization = customization
        self.size = size
        self.showShadow = showShadow
    }

    var body: some View {
        if let customization = customization {
            CharacterFullPreview(customization: customization, size: size)
                .environmentObject(ThemeManager.shared)
                .shadow(radius: showShadow ? 8 : 0)
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
                .fill(theme.cardBackgroundColor)
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
                        Text(customization.outfit.displayName)
                            .font(.appFont(size: 8))
                            .foregroundColor(theme.textColor.opacity(0.6))
                    }
                }

                // Character info
                VStack(spacing: 2) {
                    Text("Custom Hero")
                        .font(.appFont(size: 12, weight: .bold))
                        .foregroundColor(theme.textColor)

                    Text(customization.weapon.displayName)
                        .font(.appFont(size: 10))
                        .foregroundColor(theme.textColor.opacity(0.7))
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
            // Wings (Accessory) - Draw first so it appears behind everything
            if let accessory = customization.accessory,
               [.wingsWhite, .wingsRed, .wingsBat].contains(accessory) {
                Image(accessory.rawValue)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: size * 0.95)
            }

            // Body
            Image(customization.bodyType.rawValue)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: size * 0.95)

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
            Image(customization.outfit.rawValue)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: size * 0.95)

            // Weapon
            Image(customization.weapon.rawValue)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: size * 0.95)

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

            // Other Accessories (non-wings, non-glasses) - Draw last so they appear on top
            if let accessory = customization.accessory,
               ![.wingsWhite, .wingsRed, .wingsBat, .eyeglassRed, .eyeglassBlue, .eyeglassGray].contains(accessory) {
                Image(accessory.rawValue)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: size * 0.95)
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
