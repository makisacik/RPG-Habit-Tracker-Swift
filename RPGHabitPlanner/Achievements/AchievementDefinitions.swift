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
            title: String(localized: "achievement_first_steps"),
            description: String(localized: "achievement_first_steps_description"),
            iconName: "flag.fill",
            category: .quests,
            requirement: .questCount(1),
            type: .quest
        ),
        AchievementDefinition(
            id: "quest_master",
            title: String(localized: "achievement_quest_master"),
            description: String(localized: "achievement_quest_master_description"),
            iconName: "crown.fill",
            category: .quests,
            requirement: .questCount(50),
            type: .quest
        ),
        AchievementDefinition(
            id: "speed_runner",
            title: String(localized: "achievement_speed_runner"),
            description: String(localized: "achievement_speed_runner_description"),
            iconName: "bolt.fill",
            category: .quests,
            requirement: .questsInDay(3),
            type: .quest
        ),
        AchievementDefinition(
            id: "consistency",
            title: String(localized: "achievement_consistency"),
            description: String(localized: "achievement_consistency_description"),
            iconName: "calendar.badge.clock",
            category: .quests,
            requirement: .consecutiveDays(7),
            type: .quest
        ),

        // Level Achievements
        AchievementDefinition(
            id: "level_5",
            title: String(localized: "achievement_level_up"),
            description: String(localized: "achievement_level_up_description"),
            iconName: "star.fill",
            category: .leveling,
            requirement: .level(5),
            type: .leveling
        ),
        AchievementDefinition(
            id: "level_20",
            title: String(localized: "achievement_veteran"),
            description: String(localized: "achievement_veteran_description"),
            iconName: "star.circle.fill",
            category: .leveling,
            requirement: .level(20),
            type: .leveling
        ),
        AchievementDefinition(
            id: "level_50",
            title: String(localized: "achievement_legend"),
            description: String(localized: "achievement_legend_description"),
            iconName: "star.square.fill",
            category: .leveling,
            requirement: .level(50),
            type: .leveling
        ),
        AchievementDefinition(
            id: "exp_1000",
            title: String(localized: "achievement_experience_hunter"),
            description: String(localized: "achievement_experience_hunter_description"),
            iconName: "sparkles",
            category: .leveling,
            requirement: .totalExperience(1000),
            type: .leveling
        ),


        // Special Achievements
        AchievementDefinition(
            id: "early_bird",
            title: String(localized: "achievement_early_bird"),
            description: String(localized: "achievement_early_bird_description"),
            iconName: "sunrise.fill",
            category: .special,
            requirement: .questBeforeTime(8),
            type: .special
        ),
        AchievementDefinition(
            id: "night_owl",
            title: String(localized: "achievement_night_owl"),
            description: String(localized: "achievement_night_owl_description"),
            iconName: "moon.fill",
            category: .special,
            requirement: .questAfterTime(22),
            type: .special
        ),
        AchievementDefinition(
            id: "weekend_warrior",
            title: String(localized: "achievement_weekend_warrior"),
            description: String(localized: "achievement_weekend_warrior_description"),
            iconName: "calendar.badge.plus",
            category: .special,
            requirement: .weekendQuests(5),
            type: .special
        ),
        AchievementDefinition(
            id: "perfect_day",
            title: String(localized: "achievement_perfect_day"),
            description: String(localized: "achievement_perfect_day_description"),
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
        case .quest: return String(localized: "achievement_type_quest")
        case .leveling: return String(localized: "achievement_type_leveling")
        case .focus: return String(localized: "achievement_type_focus")
        case .battle: return String(localized: "achievement_type_battle")
        case .special: return String(localized: "achievement_type_special")
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
        case .all: return String(localized: "achievement_category_all")
        case .quests: return String(localized: "achievement_category_quests")
        case .leveling: return String(localized: "achievement_category_leveling")
        case .special: return String(localized: "achievement_category_special")
        }
    }
}
