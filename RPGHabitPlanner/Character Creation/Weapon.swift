//
//  Weapon.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import Foundation

enum Weapon: String, CaseIterable {
    case swordBroad = "Broad Sword"
    case swordLong = "Long Sword"
    case swordDouble = "Double Sword"
    case daggerGolden = "Golden Dagger"
    case daggerLong = "Long Dagger"
    case daggerDouble = "Double Dagger"
    case bow = "Bow"
    case crossbow = "Crossbow"
    case staff = "Staff"
    case spellbook = "Spellbook"
    
    var iconName: String {
        switch self {
        case .swordBroad: return "sword-broad"
        case .swordLong: return "sword-long"
        case .swordDouble: return "sword-double"
        case .daggerGolden: return "dagger-golden"
        case .daggerLong: return "dagger-long"
        case .daggerDouble: return "dagger-double"
        case .bow: return "bow"
        case .crossbow: return "crossbow"
        case .staff: return "staff"
        case .spellbook: return "spellbook"
        }
    }
}
