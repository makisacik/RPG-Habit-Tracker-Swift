//
//  Themes.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 3.08.2025.
//

import SwiftUI

enum AppTheme: String, CaseIterable, Codable {
    case system
    case light
    case dark
}

struct Theme {
    let backgroundColor: Color
    let textColor: Color
    let primaryColor: Color
    let secondaryColor: Color
    let buttonTextColor: Color
    let cardBackgroundColor: Color
    let accentColor: Color
    let gradientStart: Color
    let gradientEnd: Color
    let buttonPrimary: String
    let paperSimple: String
    let sword: String
    
    // Additional semantic colors for better consistency
    let surfaceColor: Color
    let borderColor: Color
    let shadowColor: Color
    let successColor: Color
    let warningColor: Color
    let errorColor: Color
    let infoColor: Color
    
    static func create(for mode: AppTheme, colorScheme: ColorScheme = .light) -> Theme {
        let resolvedMode: AppTheme
        if mode == .system {
            resolvedMode = (colorScheme == .dark) ? .dark : .light
        } else {
            resolvedMode = mode
        }
        
        switch resolvedMode {
        case .light:
            return Theme(
                backgroundColor: Color(hex: "#F0F0F0"), // Warm cream background
                textColor: Color(hex: "#2D3748"), // Dark charcoal for text
                primaryColor: Color(hex: "#F9F6F7"), // Light gray-blue for cards
                secondaryColor: Color(hex: "#FFFFFF"), // Medium gray-blue for secondary elements
                buttonTextColor: Color.white,
                cardBackgroundColor: Color.white, // Clean white cards
                accentColor: Color(hex: "#D69E2E"), // Warm gold for accents
                gradientStart: Color(hex: "#F7FAFC"), // Light gray-blue gradient start
                gradientEnd: Color(hex: "#E2E8F0"), // Medium gray-blue gradient end
                buttonPrimary: "btn_gold",
                paperSimple: "icon_paper_simple",
                sword: "cursorSword_bronze",
                surfaceColor: Color(hex: "#F7FAFC"), // Light gray-blue for surfaces
                borderColor: Color(hex: "#E2E8F0"), // Medium gray-blue for borders
                shadowColor: Color.black.opacity(0.1), // Subtle shadow
                successColor: Color(hex: "#38A169"), // Green for success
                warningColor: Color(hex: "#D69E2E"), // Gold for warnings
                errorColor: Color(hex: "#E53E3E"), // Red for errors
                infoColor: Color(hex: "#3182CE") // Blue for info
            )
        case .dark:
            return Theme(
                backgroundColor: Color(red: 21 / 255, green: 34 / 255, blue: 49 / 255),
                textColor: Color.white,
                primaryColor: Color(red: 29 / 255, green: 44 / 255, blue: 66 / 255),
                secondaryColor: Color(red: 65 / 255, green: 81 / 255, blue: 107 / 255),
                buttonTextColor: Color.white,
                cardBackgroundColor: Color(red: 40 / 255, green: 55 / 255, blue: 77 / 255),
                accentColor: Color(red: 65 / 255, green: 81 / 255, blue: 107 / 255),
                gradientStart: Color(red: 29 / 255, green: 44 / 255, blue: 66 / 255),
                gradientEnd: Color(red: 65 / 255, green: 81 / 255, blue: 107 / 255),
                buttonPrimary: "btn_blue",
                paperSimple: "icon_paper_simple",
                sword: "cursorSword_gold",
                surfaceColor: Color(red: 29 / 255, green: 44 / 255, blue: 66 / 255),
                borderColor: Color(red: 65 / 255, green: 81 / 255, blue: 107 / 255),
                shadowColor: Color.black.opacity(0.3),
                successColor: Color(hex: "#48BB78"),
                warningColor: Color(hex: "#ED8936"),
                errorColor: Color(hex: "#F56565"),
                infoColor: Color(hex: "#4299E1")
            )
        case .system:
            return Theme.create(for: .light, colorScheme: colorScheme)
        }
    }
}
