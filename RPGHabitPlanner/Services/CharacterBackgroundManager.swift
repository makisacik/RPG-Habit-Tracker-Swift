//
//  CharacterBackgroundManager.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 7.01.2025.
//

import Foundation
import SwiftUI

// MARK: - Character Background Manager

final class CharacterBackgroundManager: ObservableObject {
    static let shared = CharacterBackgroundManager()
    
    @Published var selectedBackground: CharacterBackground = .background1
    
    private let userDefaults = UserDefaults.standard
    private let backgroundKey = "CharacterBackground"
    
    private init() {
        loadBackground()
    }
    
    // MARK: - Background Management
    
    func setBackground(_ background: CharacterBackground) {
        selectedBackground = background
        saveBackground()
    }
    
    func getCurrentBackground() -> CharacterBackground {
        return selectedBackground
    }
    
    func getBackgroundImageName() -> String? {
        return selectedBackground.imageName
    }
    
    // MARK: - Persistence
    
    private func saveBackground() {
        userDefaults.set(selectedBackground.rawValue, forKey: backgroundKey)
    }
    
    private func loadBackground() {
        if let savedBackground = userDefaults.string(forKey: backgroundKey),
           let background = CharacterBackground(rawValue: savedBackground) {
            selectedBackground = background
        } else {
            // Default to background1
            selectedBackground = .background1
            saveBackground()
        }
    }
}

// MARK: - Character Background Enum

enum CharacterBackground: String, CaseIterable, Codable, Identifiable {
    case background1 = "char_background"
    case background2 = "char_background_2"
    case background3 = "char_background_3"
    case background4 = "char_background_4"
    case none = "none"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .none: return String(localized: "no_background")
        case .background1: return String(localized: "background_1")
        case .background2: return String(localized: "background_2")
        case .background3: return String(localized: "background_3")
        case .background4: return String(localized: "background_4")
        }
    }
    
    var imageName: String? {
        switch self {
        case .none: return nil
        case .background1: return "char_background"
        case .background2: return "char_background_2"
        case .background3: return "char_background_3"
        case .background4: return "char_background_4"
        }
    }
    
    var previewImageName: String {
        switch self {
        case .none: return "no_background"
        case .background1: return "char_background"
        case .background2: return "char_background_2"
        case .background3: return "char_background_3"
        case .background4: return "char_background_4"
        }
    }
    
    var isPremium: Bool {
        return false // All backgrounds are free
    }
}
