//
//  DamageSummaryData.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import Foundation

/// Data model for damage summary information
struct DamageSummaryData {
    let totalDamage: Int
    let damageDate: Date
    let questsAffected: Int
    let message: String
    let detailedDamage: [DetailedDamageItem] // New: Detailed breakdown of damage
}

/// Individual damage item with quest details
struct DetailedDamageItem {
    let questTitle: String
    let damageAmount: Int
    let reason: String
    let questType: String
}
