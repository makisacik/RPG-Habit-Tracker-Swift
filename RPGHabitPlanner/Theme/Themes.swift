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
                backgroundColor: Color(red: 241 / 255, green: 246 / 255, blue: 253 / 255),
                textColor: Color.black,
                primaryColor: Color(red: 225 / 255, green: 235 / 255, blue: 247 / 255),
                secondaryColor: Color(red: 208 / 255, green: 222 / 255, blue: 240 / 255),
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
                buttonPrimary: "btn_blue",
                paperSimple: "icon_paper_simple",
                sword: "cursorSword_gold"
            )
        case .system:
            return Theme.create(for: .light, colorScheme: colorScheme)
        }
    }
}
