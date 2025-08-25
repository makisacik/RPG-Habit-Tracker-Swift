//
//  Font+Extensions.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 17.07.2025.
//
import SwiftUI

enum AppFontWeight {
    case regular, medium, italic, black, bold, blackItalic, semibold
}

extension Font {
    static func appFont(size: CGFloat, weight: AppFontWeight = .regular) -> Font {
        switch weight {
        case .regular:
            return Font.custom("Quicksand-Regular", size: size)
        case .medium:
            return Font.custom("Quicksand-Medium", size: size)
        case .italic:
            return Font.custom("Quicksand-Regular", size: size).italic()
        case .black:
            return Font.custom("Quicksand-Bold", size: size)
        case .bold:
            return Font.custom("Quicksand-Bold", size: size)
        case .blackItalic:
            return Font.custom("Quicksand-Bold", size: size).italic()
        case .semibold:
            return Font.custom("Quicksand-Medium", size: size)
        }
    }
}
