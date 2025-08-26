//
//  CurrencyTransactionService.swift
//  RPGHabitPlanner
//
//  Created by Assistant on 27.07.2025.
//

import Foundation

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
        switch currency {
        case .coins:
            return userDefaults.integer(forKey: coinsEarnedKey)
        case .gems:
            return userDefaults.integer(forKey: gemsEarnedKey)
        }
    }
    
    
    func calculateAveragePerQuest(currency: CurrencyType) -> Double {
        // For simplicity, return a default value
        // This could be enhanced with more detailed tracking if needed
        return AnalyticsConfiguration.Currency.defaultAverageCoinsPerQuest
    }
    
    func calculateEarningRate(currency: CurrencyType, period: TimeInterval = 7 * 24 * 3600) -> Double {
        // For simplicity, return a default value
        // This could be enhanced with time-based tracking if needed
        return AnalyticsConfiguration.Currency.defaultEarningRate
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
