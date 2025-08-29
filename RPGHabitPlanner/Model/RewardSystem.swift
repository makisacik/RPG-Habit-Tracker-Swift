//
//  RewardSystem.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import Foundation

// MARK: - Reward Types

// RewardType is defined in RewardTypes.swift

// MARK: - Reward Calculation

struct RewardCalculation {
    let baseExperience: Int
    let baseCoins: Int
    let baseGems: Int
    let boostedExperience: Int
    let boostedCoins: Int
    let boostedGems: Int
    let experienceMultiplier: Double
    let coinsMultiplier: Double
    let experienceBonus: Int
    let coinsBonus: Int
    
    var totalExperience: Int {
        return boostedExperience
    }
    
    var totalCoins: Int {
        return boostedCoins
    }

    var totalGems: Int {
        return boostedGems
    }
}

class RewardSystem {
    static let shared = RewardSystem()
    
    private let boosterManager = BoosterManager.shared
    
    private init() {}
    
    // MARK: - Quest Rewards
    
    func calculateQuestReward(quest: Quest) -> RewardCalculation {
        let baseExp = calculateBaseQuestExperience(quest: quest)
        let baseCoins = calculateBaseQuestCoins(quest: quest)
        let baseGems = 5 // Base gems for quest completion

        // Apply premium multiplier (x2 for premium users) to base rewards
        let premiumMultiplier = getPremiumMultiplier()
        let premiumBaseExp = Int(Double(baseExp) * premiumMultiplier)
        let premiumBaseCoins = Int(Double(baseCoins) * premiumMultiplier)
        let premiumBaseGems = Int(Double(baseGems) * premiumMultiplier)

        let boostedRewards = boosterManager.calculateBoostedRewards(
            baseExperience: premiumBaseExp,
            baseCoins: premiumBaseCoins
        )

        return RewardCalculation(
            baseExperience: baseExp,
            baseCoins: baseCoins,
            baseGems: baseGems,
            boostedExperience: boostedRewards.experience,
            boostedCoins: boostedRewards.coins,
            boostedGems: premiumBaseGems,
            experienceMultiplier: boosterManager.totalExperienceMultiplier,
            coinsMultiplier: boosterManager.totalCoinsMultiplier,
            experienceBonus: boosterManager.totalExperienceBonus,
            coinsBonus: boosterManager.totalCoinsBonus
        )
    }
    
    // MARK: - Task Rewards
    
    func calculateTaskReward(task: QuestTask, quest: Quest) -> RewardCalculation {
        let baseExp = calculateBaseTaskExperience(task: task, quest: quest)
        let baseCoins = calculateBaseTaskCoins(task: task, quest: quest)
        let baseGems = 0 // Tasks don't give gems

        // Apply premium multiplier (x2 for premium users) to base rewards
        let premiumMultiplier = getPremiumMultiplier()
        let premiumBaseExp = Int(Double(baseExp) * premiumMultiplier)
        let premiumBaseCoins = Int(Double(baseCoins) * premiumMultiplier)
        let premiumBaseGems = Int(Double(baseGems) * premiumMultiplier)

        let boostedRewards = boosterManager.calculateBoostedRewards(
            baseExperience: premiumBaseExp,
            baseCoins: premiumBaseCoins
        )

        return RewardCalculation(
            baseExperience: baseExp,
            baseCoins: baseCoins,
            baseGems: baseGems,
            boostedExperience: boostedRewards.experience,
            boostedCoins: boostedRewards.coins,
            boostedGems: premiumBaseGems,
            experienceMultiplier: boosterManager.totalExperienceMultiplier,
            coinsMultiplier: boosterManager.totalCoinsMultiplier,
            experienceBonus: boosterManager.totalExperienceBonus,
            coinsBonus: boosterManager.totalCoinsBonus
        )
    }
    
    // MARK: - Base Reward Calculations
    
    private func calculateBaseQuestExperience(quest: Quest) -> Int {
        // Base experience based on difficulty and quest type
        let baseExp: Int
        
        switch quest.difficulty {
        case 1: baseExp = 10
        case 2: baseExp = 20
        case 3: baseExp = 35
        case 4: baseExp = 50
        case 5: baseExp = 75
        default: baseExp = 25
        }
        
        // Bonus for main quests
        let mainQuestBonus = quest.isMainQuest ? 15 : 0
        
        // Bonus for quests with tasks
        let taskBonus = quest.tasks.isEmpty ? 0 : quest.tasks.count * 2
        
        return baseExp + mainQuestBonus + taskBonus
    }
    
    private func calculateBaseQuestCoins(quest: Quest) -> Int {
        // Base coins based on difficulty
        let baseCoins: Int
        
        switch quest.difficulty {
        case 1: baseCoins = 5
        case 2: baseCoins = 10
        case 3: baseCoins = 15
        case 4: baseCoins = 25
        case 5: baseCoins = 40
        default: baseCoins = 15
        }
        
        // Bonus for main quests
        let mainQuestBonus = quest.isMainQuest ? 10 : 0
        
        // Bonus for quests with tasks
        let taskBonus = quest.tasks.isEmpty ? 0 : quest.tasks.count
        
        return baseCoins + mainQuestBonus + taskBonus
    }
    
    private func calculateBaseTaskExperience(task: QuestTask, quest: Quest) -> Int {
        // Base task experience
        let baseExp = 5
        
        // Bonus based on quest difficulty
        let difficultyBonus = quest.difficulty * 2
        
        // Bonus for main quest tasks
        let mainQuestBonus = quest.isMainQuest ? 5 : 0
        
        return baseExp + difficultyBonus + mainQuestBonus
    }
    
    private func calculateBaseTaskCoins(task: QuestTask, quest: Quest) -> Int {
        // Base task coins
        let baseCoins = 2
        
        // Bonus based on quest difficulty
        let difficultyBonus = quest.difficulty
        
        // Bonus for main quest tasks
        let mainQuestBonus = quest.isMainQuest ? 3 : 0
        
        return baseCoins + difficultyBonus + mainQuestBonus
    }
    
    // MARK: - Premium Helper
    
    private func getPremiumMultiplier() -> Double {
        // Access premium status from UserDefaults to avoid main actor issues
        return UserDefaults.standard.bool(forKey: "isPremium") ? 2.0 : 1.0
    }
}
