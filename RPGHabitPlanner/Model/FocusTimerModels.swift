//
//  FocusTimerModels.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import Foundation
import SwiftUI

// MARK: - Timer Models

enum TimerState {
    case idle
    case working
    case shortBreak
    case longBreak
    case battle
    case victory
    case defeat
}

struct TimerSettings {
    let workDuration: TimeInterval = 25 * 60 // 25 minutes
    let shortBreakDuration: TimeInterval = 5 * 60 // 5 minutes
    let longBreakDuration: TimeInterval = 15 * 60 // 15 minutes
    let pomodorosUntilLongBreak: Int = 4
}

// MARK: - Battle Models

struct BattleEntity {
    let id: UUID
    var name: String
    var maxHealth: Int
    var currentHealth: Int
    var attackPower: Int
    var defense: Int
    var level: Int
    var imageName: String
    var isPlayer: Bool
    
    init(id: UUID = UUID(), name: String, maxHealth: Int, currentHealth: Int? = nil, attackPower: Int, defense: Int, level: Int, imageName: String, isPlayer: Bool = false) {
        self.id = id
        self.name = name
        self.maxHealth = maxHealth
        self.currentHealth = currentHealth ?? maxHealth
        self.attackPower = attackPower
        self.defense = defense
        self.level = level
        self.imageName = imageName
        self.isPlayer = isPlayer
    }
    
    var healthPercentage: Double {
        return Double(currentHealth) / Double(maxHealth)
    }
    
    var isAlive: Bool {
        return currentHealth > 0
    }
}

struct BattleAction {
    let attacker: BattleEntity
    let target: BattleEntity
    let damage: Int
    let actionType: ActionType
    let timestamp: Date
    
    enum ActionType {
        case attack
        case distraction
        case focus
        case special
    }
}

struct BattleReward {
    let experience: Int
    let gold: Int
    let items: [BattleItem]
    let achievement: AchievementDefinition?
}

// MARK: - Enemy Types

enum EnemyType: CaseIterable {
    case sleepyCat
    case funnyZombie
    case funkyMonster
    case booMonster
    case flyingDragon
    
    var entity: BattleEntity {
        switch self {
        case .sleepyCat:
            return BattleEntity(
                name: "Sleepy Cat",
                maxHealth: 80,
                attackPower: 12,
                defense: 8,
                level: 1,
                imageName: "sleepy-cat"
            )
        case .funnyZombie:
            return BattleEntity(
                name: "Funny Zombie",
                maxHealth: 100,
                attackPower: 15,
                defense: 10,
                level: 2,
                imageName: "funny-zombie"
            )
        case .funkyMonster:
            return BattleEntity(
                name: "Funky Monster",
                maxHealth: 120,
                attackPower: 18,
                defense: 12,
                level: 2,
                imageName: "funky-monster"
            )
        case .booMonster:
            return BattleEntity(
                name: "Boo Monster",
                maxHealth: 90,
                attackPower: 14,
                defense: 9,
                level: 1,
                imageName: "boo-monster"
            )
        case .flyingDragon:
            return BattleEntity(
                name: "Flying Dragon",
                maxHealth: 150,
                attackPower: 25,
                defense: 15,
                level: 3,
                imageName: "flying-dragon"
            )
        }
    }
    
    var description: String {
        switch self {
        case .sleepyCat:
            return "A sleepy cat that makes you want to nap instead of work"
        case .funnyZombie:
            return "A funny zombie that distracts you with humor"
        case .funkyMonster:
            return "A funky monster that gets you grooving instead of focusing"
        case .booMonster:
            return "A spooky boo monster that scares away your concentration"
        case .flyingDragon:
            return "A majestic flying dragon that's hard to defeat"
        }
    }
    
    var animationName: String {
        switch self {
        case .sleepyCat:
            return "sleepy-cat"
        case .funnyZombie:
            return "funny-zombie"
        case .funkyMonster:
            return "funky-monster"
        case .booMonster:
            return "boo-monster"
        case .flyingDragon:
            return "flying-dragon"
        }
    }
}

// MARK: - Battle Session

struct BattleSession {
    let id: UUID
    let startTime: Date
    let enemyType: EnemyType
    var player: BattleEntity
    var enemy: BattleEntity
    var actions: [BattleAction]
    var completedPomodoros: Int
    let targetPomodoros: Int
    var isCompleted: Bool
    
    init(player: BattleEntity, enemyType: EnemyType, targetPomodoros: Int = 4) {
        self.id = UUID()
        self.startTime = Date()
        self.player = player
        self.enemyType = enemyType
        self.enemy = enemyType.entity
        self.actions = []
        self.completedPomodoros = 0
        self.targetPomodoros = targetPomodoros
        self.isCompleted = false
    }
    
    var isVictory: Bool {
        return !enemy.isAlive && completedPomodoros >= targetPomodoros
    }
    
    var isDefeat: Bool {
        return !player.isAlive || (enemy.isAlive && completedPomodoros >= targetPomodoros)
    }
    
    var progress: Double {
        return Double(completedPomodoros) / Double(targetPomodoros)
    }
}

// MARK: - Focus Timer Session

struct FocusTimerSession {
    let id: UUID
    let startTime: Date
    var currentState: TimerState
    var timeRemaining: TimeInterval
    var completedPomodoros: Int
    var totalWorkTime: TimeInterval
    var battleSession: BattleSession?
    let settings: TimerSettings
    
    init(settings: TimerSettings = TimerSettings()) {
        self.id = UUID()
        self.startTime = Date()
        self.currentState = .idle
        self.timeRemaining = settings.workDuration
        self.completedPomodoros = 0
        self.totalWorkTime = 0
        self.battleSession = nil
        self.settings = settings
    }
    
    var isInBattle: Bool {
        return battleSession != nil
    }
    
    var shouldStartLongBreak: Bool {
        return completedPomodoros > 0 && completedPomodoros % settings.pomodorosUntilLongBreak == 0
    }
}
