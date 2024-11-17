//
//  CharacterClass.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import Foundation

enum CharacterClass: String, CaseIterable, Identifiable {
    case knight = "Knight"
    case assassin = "Assassin"
    case archer = "Archer"
    case wizard = "Wizard"
    
    var id: String { self.rawValue }
    
    var iconName: String {
        switch self {
        case .knight: return "knight"
        case .assassin: return "assassin"
        case .archer: return "archer"
        case .wizard: return "wizard"
        }
    }
    
    var displayName: String {
        switch self {
        case .knight: return "Knight"
        case .archer: return "Archer"
        case .wizard: return "Wizard"
        case .assassin: return "Assassin"
        }
    }
}
