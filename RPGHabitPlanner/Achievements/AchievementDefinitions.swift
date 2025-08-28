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

    static func getAllAchievements() -> [AchievementDefinition] {
        return [
            // Quest Achievements
            AchievementDefinition(
                id: "first_quest",
                title: "achievement_first_steps".localized,
                description: "achievement_first_steps_description".localized,
                iconName: "flag.fill",
                category: .quests,
                requirement: .questCount(1),
                type: .quest
            ),
            AchievementDefinition(
                id: "quest_master",
                title: "achievement_quest_master".localized,
                description: "achievement_quest_master_description".localized,
                iconName: "crown.fill",
                category: .quests,
                requirement: .questCount(50),
                type: .quest
            ),
            AchievementDefinition(
                id: "speed_runner",
                title: "achievement_speed_runner".localized,
                description: "achievement_speed_runner_description".localized,
                iconName: "bolt.fill",
                category: .quests,
                requirement: .questsInDay(3),
                type: .quest
            ),
            AchievementDefinition(
                id: "consistency",
                title: "achievement_consistency".localized,
                description: "achievement_consistency_description".localized,
                iconName: "calendar.badge.clock",
                category: .quests,
                requirement: .consecutiveDays(7),
                type: .quest
            ),

            // Level Achievements
            AchievementDefinition(
                id: "level_5",
                title: "achievement_level_up".localized,
                description: "achievement_level_up_description".localized,
                iconName: "star.fill",
                category: .leveling,
                requirement: .level(5),
                type: .leveling
            ),
            AchievementDefinition(
                id: "level_20",
                title: "achievement_veteran".localized,
                description: "achievement_veteran_description".localized,
                iconName: "star.circle.fill",
                category: .leveling,
                requirement: .level(20),
                type: .leveling
            ),
            AchievementDefinition(
                id: "level_50",
                title: "achievement_legend".localized,
                description: "achievement_legend_description".localized,
                iconName: "star.square.fill",
                category: .leveling,
                requirement: .level(50),
                type: .leveling
            ),
            AchievementDefinition(
                id: "exp_1000",
                title: "achievement_experience_hunter".localized,
                description: "achievement_experience_hunter_description".localized,
                iconName: "sparkles",
                category: .leveling,
                requirement: .totalExperience(1000),
                type: .leveling
            ),


            // Special Achievements
            AchievementDefinition(
                id: "early_bird",
                title: "achievement_early_bird".localized,
                description: "achievement_early_bird_description".localized,
                iconName: "sunrise.fill",
                category: .special,
                requirement: .questBeforeTime(8),
                type: .special
            ),
            AchievementDefinition(
                id: "night_owl",
                title: "achievement_night_owl".localized,
                description: "achievement_night_owl_description".localized,
                iconName: "moon.fill",
                category: .special,
                requirement: .questAfterTime(22),
                type: .special
            ),
            AchievementDefinition(
                id: "weekend_warrior",
                title: "achievement_weekend_warrior".localized,
                description: "achievement_weekend_warrior_description".localized,
                iconName: "calendar.badge.plus",
                category: .special,
                requirement: .weekendQuests(5),
                type: .special
            ),
            AchievementDefinition(
                id: "perfect_day",
                title: "achievement_perfect_day".localized,
                description: "achievement_perfect_day_description".localized,
                iconName: "checkmark.circle.fill",
                category: .special,
                requirement: .allDailyQuests,
                type: .special
            )
        ]
    }
    
    // Keep the static property for backward compatibility
    static var allAchievements: [AchievementDefinition] {
        return getAllAchievements()
    }
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
        case .quest: return "achievement_type_quest".localized
        case .leveling: return "achievement_type_leveling".localized
        case .focus: return "achievement_type_focus".localized
        case .battle: return "achievement_type_battle".localized
        case .special: return "achievement_type_special".localized
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
        case .all: return "achievement_category_all".localized
        case .quests: return "achievement_category_quests".localized
        case .leveling: return "achievement_category_leveling".localized
        case .special: return "achievement_category_special".localized
        }
    }
}
