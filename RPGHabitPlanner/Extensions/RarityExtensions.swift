//
//  RarityExtensions.swift
//  RPGHabitPlanner
//
//  Created by Assistant on 21.08.2025.
//

import Foundation
import SwiftUI

// MARK: - ItemRarity to AssetRarity Conversion

extension ItemRarity {
    var toAssetRarity: AssetRarity {
        switch self {
        case .common: return .common
        case .uncommon: return .uncommon
        case .rare: return .rare
        case .epic: return .epic
        case .legendary: return .legendary
        }
    }
}

extension AssetRarity {
    var toItemRarity: ItemRarity {
        switch self {
        case .common: return .common
        case .uncommon: return .uncommon
        case .rare: return .rare
        case .epic: return .epic
        case .legendary: return .legendary
        }
    }
}
