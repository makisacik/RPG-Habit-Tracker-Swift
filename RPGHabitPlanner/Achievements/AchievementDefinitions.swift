//
//  AchievementDefinitions.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import Foundation

// MARK: - Achievement Definitions

struct AchievementDefinition: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let iconName: String
    let category: AchievementCategory
    let requirement: AchievementRequirement
    let type: AchievementType

    init(id: String, title: String, description: String, iconName: String, category: AchievementCategory, requirement: AchievementRequirement, type: AchievementType = .quest) {
        self.id = id
        self.title = title
        self.description = description
        self.iconName = iconName
        self.category = category
        self.requirement = requirement
        self.type = type
    }
    
    static let allAchievements: [AchievementDefinition] = [
        // Quest Achievements
        AchievementDefinition(
            id: "first_quest",
            title: "First Steps",
            description: "Complete your first quest",
            iconName: "flag.fill",
            category: .quests,
            requirement: .questCount(1),
            type: .quest
        ),
        AchievementDefinition(
            id: "quest_master",
            title: "Quest Master",
            description: "Complete 50 quests",
            iconName: "crown.fill",
            category: .quests,
            requirement: .questCount(50),
            type: .quest
        ),
        AchievementDefinition(
            id: "speed_runner",
            title: "Speed Runner",
            description: "Complete 3 quests in one day",
            iconName: "bolt.fill",
            category: .quests,
            requirement: .questsInDay(3),
            type: .quest
        ),
        AchievementDefinition(
            id: "consistency",
            title: "Consistency",
            description: "Complete quests for 7 days in a row",
            iconName: "calendar.badge.clock",
            category: .quests,
            requirement: .consecutiveDays(7),
            type: .quest
        ),
        
        // Level Achievements
        AchievementDefinition(
            id: "level_5",
            title: "Level Up!",
            description: "Reach level 5",
            iconName: "star.fill",
            category: .leveling,
            requirement: .level(5),
            type: .leveling
        ),
        AchievementDefinition(
            id: "level_20",
            title: "Veteran",
            description: "Reach level 20",
            iconName: "star.circle.fill",
            category: .leveling,
            requirement: .level(20),
            type: .leveling
        ),
        AchievementDefinition(
            id: "level_50",
            title: "Legend",
            description: "Reach level 50",
            iconName: "star.square.fill",
            category: .leveling,
            requirement: .level(50),
            type: .leveling
        ),
        AchievementDefinition(
            id: "exp_1000",
            title: "Experience Hunter",
            description: "Gain 1000 experience points",
            iconName: "sparkles",
            category: .leveling,
            requirement: .totalExperience(1000),
            type: .leveling
        ),
        
        
        // Special Achievements
        AchievementDefinition(
            id: "early_bird",
            title: "Early Bird",
            description: "Complete a quest before 8 AM",
            iconName: "sunrise.fill",
            category: .special,
            requirement: .questBeforeTime(8),
            type: .special
        ),
        AchievementDefinition(
            id: "night_owl",
            title: "Night Owl",
            description: "Complete a quest after 10 PM",
            iconName: "moon.fill",
            category: .special,
            requirement: .questAfterTime(22),
            type: .special
        ),
        AchievementDefinition(
            id: "weekend_warrior",
            title: "Weekend Warrior",
            description: "Complete 5 quests on a weekend",
            iconName: "calendar.badge.plus",
            category: .special,
            requirement: .weekendQuests(5),
            type: .special
        ),
        AchievementDefinition(
            id: "perfect_day",
            title: "Perfect Day",
            description: "Complete all daily quests",
            iconName: "checkmark.circle.fill",
            category: .special,
            requirement: .allDailyQuests,
            type: .special
        )
    ]
}

// MARK: - Achievement Requirements

enum AchievementRequirement: Codable {
    case questCount(Int)
    case questsInDay(Int)
    case consecutiveDays(Int)
    case level(Int)
    case totalExperience(Int)
    case questBeforeTime(Int)
    case questAfterTime(Int)
    case weekendQuests(Int)
    case allDailyQuests
}

// MARK: - Achievement Type

enum AchievementType: String, CaseIterable, Codable {
    case quest
    case leveling
    case focus
    case battle
    case special
    
    var displayName: String {
        switch self {
        case .quest: return "Quest"
        case .leveling: return "Leveling"
        case .focus: return "Focus"
        case .battle: return "Battle"
        case .special: return "Special"
        }
    }
}

// MARK: - Achievement Category

enum AchievementCategory: String, CaseIterable, Codable {
    case all
    case quests
    case leveling
    case special
    
    var displayName: String {
        switch self {
        case .all: return "All"
        case .quests: return "Quests"
        case .leveling: return "Leveling"
        case .special: return "Special"
        }
    }
}
