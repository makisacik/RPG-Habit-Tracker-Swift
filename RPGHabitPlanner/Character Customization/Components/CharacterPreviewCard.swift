//
//  CharacterPreviewCard.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 7.01.2025.
//

import SwiftUI

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
                        .fill(customization.skinColor.color)
                        .frame(width: size.width * 0.7, height: size.height * 0.7)
                    
                    // Character icon placeholder (simplified for now)
                    VStack(spacing: 4) {
                        // Body type icon
                        Image(systemName: "person.fill")
                            .font(.system(size: size.width * 0.3))
                            .foregroundColor(customization.skinColor.color.opacity(0.8))
                        
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
            if let accessory = customization.accessory {
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
                .colorMultiply(customization.skinColor.color)

            // Hair
            Image(customization.hairStyle.rawValue)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: size * 0.95)
                .colorMultiply(customization.hairColor.color)

            // Eyes
            Image(customization.eyeColor.rawValue)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: size * 0.95)

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

            // Other Accessories (non-wings) - Draw last so they appear on top
            if let accessory = customization.accessory,
               accessory != .wingsWhite {
                Image(accessory.rawValue)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: size * 0.95)
            }
        }
        .frame(width: size, height: size)
    }
}
