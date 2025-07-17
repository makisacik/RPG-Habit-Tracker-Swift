//
//  Font+Extensions.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 17.07.2025.
//
import SwiftUI

enum AppFontWeight {
    case regular, italic, black, blackItalic
}

extension Font {
    static func appFont(size: CGFloat, weight: AppFontWeight = .regular) -> Font {
        switch weight {
        case .regular:
            return Font.custom("HoeflerText-Regular", size: size)
        case .italic:
            return Font.custom("HoeflerText-Italic", size: size)
        case .black:
            return Font.custom("HoeflerText-Black", size: size)
        case .blackItalic:
            return Font.custom("HoeflerText-BlackItalic", size: size)
        }
    }
}
