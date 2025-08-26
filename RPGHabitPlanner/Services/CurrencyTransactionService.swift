//
//  CurrencyTransactionService.swift
//  RPGHabitPlanner
//
//  Created by Assistant on 27.07.2025.
//

import Foundation
import CoreData

class CurrencyTransactionService: ObservableObject {
    static let shared = CurrencyTransactionService()
    
    private let userDefaults = UserDefaults.standard
    private let coinsEarnedKey = "total_coins_earned"
    private let gemsEarnedKey = "total_gems_earned"
    
    private init() {}
    
    // MARK: - Transaction Recording
    
    func recordEarned(amount: Int, currency: CurrencyType) {
        switch currency {
        case .coins:
            let currentTotal = userDefaults.integer(forKey: coinsEarnedKey)
            userDefaults.set(currentTotal + amount, forKey: coinsEarnedKey)
            print("💰 Recorded \(amount) coins earned. Total: \(currentTotal + amount)")
            
        case .gems:
            let currentTotal = userDefaults.integer(forKey: gemsEarnedKey)
            userDefaults.set(currentTotal + amount, forKey: gemsEarnedKey)
            print("💎 Recorded \(amount) gems earned. Total: \(currentTotal + amount)")
        }
    }
    
    // MARK: - Analytics Calculations
    
    func calculateTotalEarned(currency: CurrencyType) -> Int {
        let total: Int
        switch currency {
        case .coins:
            total = userDefaults.integer(forKey: coinsEarnedKey)
        case .gems:
            total = userDefaults.integer(forKey: gemsEarnedKey)
        }
        print("💰 CurrencyTransactionService: Total earned \(currency.rawValue) from UserDefaults: \(total)")
        return total
    }
    
    
    func calculateAveragePerQuest(currency: CurrencyType) async -> Double {
        let totalEarned = calculateTotalEarned(currency: currency)
        print("💰 CurrencyTransactionService: Total earned for \(currency.rawValue): \(totalEarned)")

        // Get finished quests count directly from quest data service to avoid circular dependency
        let questDataService = QuestCoreDataService()
        let finishedQuestsCount = await withCheckedContinuation { continuation in
            questDataService.fetchAllQuests { quests, error in
                if let error = error {
                    print("❌ CurrencyTransactionService: Error fetching quests: \(error)")
                    continuation.resume(returning: 0)
                } else {
                    let finishedCount = quests.filter { $0.isFinished }.count
                    print("💰 CurrencyTransactionService: Found \(finishedCount) finished quests")
                    continuation.resume(returning: finishedCount)
                }
            }
        }

        // Simple division: total earned / finished quests
        if finishedQuestsCount > 0 {
            let average = Double(totalEarned) / Double(finishedQuestsCount)
            print("💰 CurrencyTransactionService: Calculated average \(currency.rawValue) per quest: \(average)")
            return average
        } else {
            print("💰 CurrencyTransactionService: No finished quests found, using default")
            // If no finished quests, return default
            switch currency {
            case .coins:
                return AnalyticsConfiguration.Currency.defaultAverageCoinsPerQuest
            case .gems:
                return AnalyticsConfiguration.Currency.defaultAverageGemsPerQuest
            }
        }
    }
    
    func calculateEarningRate(currency: CurrencyType, period: TimeInterval = 7 * 24 * 3600) -> Double {
        let totalEarned = calculateTotalEarned(currency: currency)

        // Simple calculation: total earned / weeks since first quest
        // For now, use a reasonable time period (4 weeks) if we don't have specific data
        let weeksInPeriod = period / (7 * 24 * 3600) // Convert to weeks

        if weeksInPeriod > 0 {
            return Double(totalEarned) / weeksInPeriod
        } else {
            return AnalyticsConfiguration.Currency.defaultEarningRate
        }
    }
    
    func fetchAllTransactions() -> [CurrencyTransaction] {
        // For simplicity, return empty array
        // This could be enhanced with detailed transaction history if needed
        return []
    }
    
    // MARK: - Reset Methods (for testing)
    
    func resetAllTracking() {
        userDefaults.removeObject(forKey: coinsEarnedKey)
        userDefaults.removeObject(forKey: gemsEarnedKey)
        print("🔄 Reset all currency tracking")
    }
}

// MARK: - Extensions

extension TransactionType: RawRepresentable {
    typealias RawValue = String
    
    init?(rawValue: String) {
        switch rawValue {
        case "earned": self = .earned
        case "spent": self = .spent
        default: return nil
        }
    }
    
    var rawValue: String {
        switch self {
        case .earned: return "earned"
        case .spent: return "spent"
        }
    }
}

extension CurrencyType: RawRepresentable {
    typealias RawValue = String
    
    init?(rawValue: String) {
        switch rawValue {
        case "coins": self = .coins
        case "gems": self = .gems
        default: return nil
        }
    }
    
    var rawValue: String {
        switch self {
        case .coins: return "coins"
        case .gems: return "gems"
        }
    }
}

extension TransactionSource: RawRepresentable {
    typealias RawValue = String
    
    init?(rawValue: String) {
        switch rawValue {
        case "questCompletion": self = .questCompletion
        case "taskCompletion": self = .taskCompletion
        case "achievement": self = .achievement
        case "shop": self = .shop
        case "booster": self = .booster
        case "dailyReward": self = .dailyReward
        case "levelUp": self = .levelUp
        case "other": self = .other
        default: return nil
        }
    }
    
    var rawValue: String {
        switch self {
        case .questCompletion: return "questCompletion"
        case .taskCompletion: return "taskCompletion"
        case .achievement: return "achievement"
        case .shop: return "shop"
        case .booster: return "booster"
        case .dailyReward: return "dailyReward"
        case .levelUp: return "levelUp"
        case .other: return "other"
        }
    }
}
