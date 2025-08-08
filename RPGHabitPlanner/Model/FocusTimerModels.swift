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
    case procrastination
    case socialMedia
    case noise
    case fatigue
    case perfectionism
    
    var entity: BattleEntity {
        switch self {
        case .procrastination:
            return BattleEntity(
                name: "Procrastination Demon",
                maxHealth: 100,
                attackPower: 15,
                defense: 8,
                level: 1,
                imageName: "enemy_procrastination"
            )
        case .socialMedia:
            return BattleEntity(
                name: "Social Media Siren",
                maxHealth: 80,
                attackPower: 20,
                defense: 5,
                level: 1,
                imageName: "enemy_social_media"
            )
        case .noise:
            return BattleEntity(
                name: "Noise Gremlin",
                maxHealth: 60,
                attackPower: 12,
                defense: 12,
                level: 1,
                imageName: "enemy_noise"
            )
        case .fatigue:
            return BattleEntity(
                name: "Fatigue Phantom",
                maxHealth: 120,
                attackPower: 18,
                defense: 10,
                level: 2,
                imageName: "enemy_fatigue"
            )
        case .perfectionism:
            return BattleEntity(
                name: "Perfectionism Dragon",
                maxHealth: 150,
                attackPower: 25,
                defense: 15,
                level: 3,
                imageName: "enemy_perfectionism"
            )
        }
    }
    
    var description: String {
        switch self {
        case .procrastination:
            return "A demon that makes you put off important tasks"
        case .socialMedia:
            return "A siren that lures you away with endless scrolling"
        case .noise:
            return "A gremlin that creates distractions in your environment"
        case .fatigue:
            return "A phantom that drains your energy and focus"
        case .perfectionism:
            return "A dragon that paralyzes you with unrealistic standards"
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
