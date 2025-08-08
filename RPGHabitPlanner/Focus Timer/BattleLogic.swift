//
//  BattleLogic.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import Foundation

class BattleLogic {
    // MARK: - Damage Calculation
    
    static func calculateDamage(attacker: BattleEntity, target: BattleEntity, actionType: BattleAction.ActionType) -> Int {
        let baseDamage: Int
        
        switch actionType {
        case .attack:
            baseDamage = attacker.attackPower
        case .distraction:
            baseDamage = Int(Double(attacker.attackPower) * 0.7) // Distractions are less effective
        case .focus:
            baseDamage = Int(Double(attacker.attackPower) * 1.3) // Focus attacks are more effective
        case .special:
            baseDamage = Int(Double(attacker.attackPower) * 1.5) // Special attacks are very effective
        }
        
        // Apply defense reduction
        let damageAfterDefense = max(1, baseDamage - target.defense)
        
        // Add some randomness (±20%)
        let randomFactor = Double.random(in: 0.8...1.2)
        let finalDamage = Int(Double(damageAfterDefense) * randomFactor)
        
        return max(1, finalDamage) // Minimum 1 damage
    }
    
    // MARK: - Battle Actions
    
    static func performAttack(attacker: BattleEntity, target: inout BattleEntity, actionType: BattleAction.ActionType) -> BattleAction {
        let damage = calculateDamage(attacker: attacker, target: target, actionType: actionType)
        
        // Apply damage
        target.currentHealth = max(0, target.currentHealth - damage)
        
        // Create battle action
        let action = BattleAction(
            attacker: attacker,
            target: target,
            damage: damage,
            actionType: actionType,
            timestamp: Date()
        )
        
        return action
    }
    
    // MARK: - Enemy AI
    
    static func generateEnemyAction(enemy: BattleEntity, player: BattleEntity) -> BattleAction.ActionType {
        // Simple AI: randomly choose between attack and distraction
        let random = Double.random(in: 0...1)
        
        if random < 0.7 {
            return .attack
        } else {
            return .distraction
        }
    }
    
    // MARK: - Battle Session Management
    
    static func startBattle(player: BattleEntity, enemyType: EnemyType, targetPomodoros: Int = 4) -> BattleSession {
        return BattleSession(player: player, enemyType: enemyType, targetPomodoros: targetPomodoros)
    }
    
    static func processPomodoroCompletion(session: inout BattleSession) -> [BattleAction] {
        session.completedPomodoros += 1
        
        var actions: [BattleAction] = []
        
        // Player gets a focus attack for completing a pomodoro
        let focusAction = performAttack(
            attacker: session.player,
            target: &session.enemy,
            actionType: .focus
        )
        actions.append(focusAction)
        
        // Enemy gets a counter-attack
        let enemyActionType = generateEnemyAction(enemy: session.enemy, player: session.player)
        let enemyAction = performAttack(
            attacker: session.enemy,
            target: &session.player,
            actionType: enemyActionType
        )
        actions.append(enemyAction)
        
        // Add actions to session
        session.actions.append(contentsOf: actions)
        
        // Check if battle is complete
        if session.isVictory || session.isDefeat {
            session.isCompleted = true
        }
        
        return actions
    }
    
    static func processDistraction(session: inout BattleSession) -> BattleAction {
        // Distraction gives enemy a free attack
        let enemyActionType = generateEnemyAction(enemy: session.enemy, player: session.player)
        let enemyAction = performAttack(
            attacker: session.enemy,
            target: &session.player,
            actionType: enemyActionType
        )
        
        session.actions.append(enemyAction)
        
        // Check if battle is complete
        if session.isDefeat {
            session.isCompleted = true
        }
        
        return enemyAction
    }
    
    // MARK: - Battle Rewards
    
    static func calculateRewards(session: BattleSession) -> BattleReward {
        guard session.isVictory else {
            return BattleReward(experience: 0, gold: 0, items: [], achievement: nil)
        }
        
        let baseExp = 50
        let expPerPomodoro = 25
        let totalExp = baseExp + (session.completedPomodoros * expPerPomodoro)
        
        let baseGold = 10
        let goldPerPomodoro = 5
        let totalGold = baseGold + (session.completedPomodoros * goldPerPomodoro)
        
        // Generate random items based on enemy type and completion
        let items = generateBattleItems(enemyType: session.enemyType, pomodorosCompleted: session.completedPomodoros)
        
        // Check for achievements
        let achievement = checkForAchievements(session: session)
        
        return BattleReward(
            experience: totalExp,
            gold: totalGold,
            items: items,
            achievement: achievement
        )
    }
    
    // MARK: - Helper Methods
    
    private static func generateBattleItems(enemyType: EnemyType, pomodorosCompleted: Int) -> [BattleItem] {
        var items: [BattleItem] = []
        
        // Base chance for items
        let baseChance = 0.3
        let chancePerPomodoro = 0.1
        let totalChance = baseChance + (Double(pomodorosCompleted) * chancePerPomodoro)
        
        if Double.random(in: 0...1) < totalChance {
            // Generate a random item based on enemy type
            let item = generateItemForEnemy(enemyType: enemyType)
            items.append(item)
        }
        
        return items
    }
    
    private static func generateItemForEnemy(enemyType: EnemyType) -> BattleItem {
        // This would integrate with your existing Item system
        // For now, returning a placeholder
        return BattleItem(
            id: UUID(),
            name: "Focus Crystal",
            description: "A crystal that enhances your focus abilities",
            iconName: "focus_crystal",
            rarity: .common
        )
    }
    
    private static func checkForAchievements(session: BattleSession) -> AchievementDefinition? {
        // Check for various achievements
        if session.completedPomodoros >= 8 {
            return AchievementDefinition(
                id: "focus_master",
                title: "Focus Master",
                description: "Complete 8 pomodoros in a single battle",
                iconName: "trophy.fill",
                category: .special,
                requirement: .questCount(8),
                type: .focus
            )
        }
        
        if session.enemyType == .perfectionism && session.isVictory {
            return AchievementDefinition(
                id: "dragon_slayer",
                title: "Dragon Slayer",
                description: "Defeat the Perfectionism Dragon",
                iconName: "flame.fill",
                category: .special,
                requirement: .questCount(1),
                type: .battle
            )
        }
        
        return nil
    }
}

// MARK: - Battle Statistics

struct BattleStatistics {
    let totalBattles: Int
    let victories: Int
    let totalPomodorosCompleted: Int
    let totalExperienceEarned: Int
    let totalGoldEarned: Int
    let favoriteEnemyType: EnemyType?
    let averagePomodorosPerBattle: Double
    
    var winRate: Double {
        guard totalBattles > 0 else { return 0 }
        return Double(victories) / Double(totalBattles)
    }
}
