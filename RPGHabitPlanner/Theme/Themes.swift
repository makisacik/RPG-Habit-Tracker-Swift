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
                backgroundColor: Color(hex: "#F8F7FF"), // Very light purple tint
                textColor: Color(hex: "#4B5563"), // Medium gray for text
                primaryColor: Color(hex: "#F8F7FF"), // Very light purple tint
                secondaryColor: Color(hex: "#C4B5FD"), // Very light purple
                buttonTextColor: Color.white,
                cardBackgroundColor: Color.white, // Clean white cards
                accentColor: Color(hex: "#8B5CF6"), // Dark purple for sparkles
                gradientStart: Color(hex: "#C4B5FD"), // Very light purple gradient start
                gradientEnd: Color(hex: "#C4B5FD"), // Very light purple gradient end
                buttonPrimary: "btn_gold",
                paperSimple: "icon_paper_simple",
                sword: "cursorSword_bronze"
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
                sword: "cursorSword_gold"
            )
        case .system:
            return Theme.create(for: .light, colorScheme: colorScheme)
        }
    }
}
