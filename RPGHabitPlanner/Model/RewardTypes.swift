//
//  RewardTypes.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI

// MARK: - Reward Types

enum RewardType {
    case quest
    case task
    
    var icon: String {
        switch self {
        case .quest: return "flag.fill"
        case .task: return "checkmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .quest: return .blue
        case .task: return .green
        }
    }
}
