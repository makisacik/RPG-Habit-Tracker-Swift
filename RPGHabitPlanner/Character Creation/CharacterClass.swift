//
//  CharacterClass.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import Foundation

enum CharacterClass: String, CaseIterable, Identifiable {
    case knight = "Knight"
    case archer = "Archer"
    case elephant = "Elephant"
    case ninja = "Ninja"
    case octopus = "Octopus"
    
    var id: String { self.rawValue }
    
    var iconName: String {
        switch self {
        case .knight: return "icon_knight"
        case .archer: return "icon_archer"
        case .elephant: return "icon_elephant"
        case .ninja: return "icon_ninja"
        case .octopus: return "icon_octopus"
        }
    }
    
    var displayName: String {
        switch self {
        case .knight: return "Knight"
        case .archer: return "Archer"
        case .elephant: return "Elephant"
        case .ninja: return "Ninja"
        case .octopus: return "Octopus"
        }
    }
}
