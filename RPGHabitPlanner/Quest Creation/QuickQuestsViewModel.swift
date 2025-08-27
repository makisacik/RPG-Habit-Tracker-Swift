import Foundation
import SwiftUI
import Combine
import CoreData

final class QuickQuestsViewModel: ObservableObject {
    private let questDataService: QuestDataServiceProtocol

    @Published var selectedQuestType: QuestType = .daily
    @Published var selectedTemplate: QuickQuestTemplate?
    @Published var showDueDatePicker = false

    private var cancellables = Set<AnyCancellable>()

    init(questDataService: QuestDataServiceProtocol) {
        self.questDataService = questDataService
    }

    var questsForSelectedType: [QuickQuestTemplate] {
        switch selectedQuestType {
        case .daily:
            return QuickQuestTemplate.dailyQuests
        case .weekly:
            return QuickQuestTemplate.weeklyQuests
        case .oneTime:
            return QuickQuestTemplate.oneTimeQuests
        }
    }

    func addQuickQuest(template: QuickQuestTemplate, dueDate: Date) {
        let repeatType: QuestRepeatType
        switch selectedQuestType {
        case .daily:
            repeatType = .daily
        case .weekly:
            repeatType = .weekly
        case .oneTime:
            repeatType = .oneTime
        }

        let newQuest = Quest(
            title: template.title,
            isMainQuest: false,
            info: template.description,
            difficulty: template.difficulty,
            creationDate: Date(),
            dueDate: dueDate,
            isActive: true,
            progress: 0,
            isCompleted: false,
            completionDate: nil,
            tasks: template.tasks,
            repeatType: repeatType
        )

        questDataService.saveQuest(newQuest, withTasks: template.tasks.map { $0.title }) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Failed to save quick quest: \(error)")
                } else {
                    print("Quick quest saved successfully: \(template.title)")
                    // Send notification to update other views
                    NotificationCenter.default.post(name: .questCreated, object: newQuest)
                }
            }
        }
    }
}

// MARK: - Quick Quest Templates
extension QuickQuestTemplate {
    static let dailyQuests: [QuickQuestTemplate] = [
        QuickQuestTemplate(
            title: "quick_quest_hydration_hero".localized,
            description: "quick_quest_hydration_hero_description".localized,
            category: .health,
            difficulty: 1,
            iconName: "drop.fill",
            tasks: [
                QuestTask(id: UUID(), title: "quick_quest_hydration_hero_task_1".localized, isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "quick_quest_hydration_hero_task_2".localized, isCompleted: false, order: 2),
                QuestTask(id: UUID(), title: "quick_quest_hydration_hero_task_3".localized, isCompleted: false, order: 3),
                QuestTask(id: UUID(), title: "quick_quest_hydration_hero_task_4".localized, isCompleted: false, order: 4)
            ]
        ),
        QuickQuestTemplate(
            title: "quick_quest_morning_exercise".localized,
            description: "quick_quest_morning_exercise_description".localized,
            category: .fitness,
            difficulty: 2,
            iconName: "figure.run",
            tasks: [
                QuestTask(id: UUID(), title: "quick_quest_morning_exercise_task_1".localized, isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "quick_quest_morning_exercise_task_2".localized, isCompleted: false, order: 2),
                QuestTask(id: UUID(), title: "quick_quest_morning_exercise_task_3".localized, isCompleted: false, order: 3),
                QuestTask(id: UUID(), title: "quick_quest_morning_exercise_task_4".localized, isCompleted: false, order: 4)
            ]
        ),
        QuickQuestTemplate(
            title: "quick_quest_mindful_reading".localized,
            description: "quick_quest_mindful_reading_description".localized,
            category: .learning,
            difficulty: 1,
            iconName: "book.fill",
            tasks: [
                QuestTask(id: UUID(), title: "quick_quest_mindful_reading_task_1".localized, isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "quick_quest_mindful_reading_task_2".localized, isCompleted: false, order: 2),
                QuestTask(id: UUID(), title: "quick_quest_mindful_reading_task_3".localized, isCompleted: false, order: 3)
            ]
        ),
        QuickQuestTemplate(
            title: "quick_quest_gratitude_practice".localized,
            description: "quick_quest_gratitude_practice_description".localized,
            category: .mindfulness,
            difficulty: 1,
            iconName: "heart.fill",
            tasks: [
                QuestTask(id: UUID(), title: "quick_quest_gratitude_practice_task_1".localized, isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "quick_quest_gratitude_practice_task_2".localized, isCompleted: false, order: 2),
                QuestTask(id: UUID(), title: "quick_quest_gratitude_practice_task_3".localized, isCompleted: false, order: 3)
            ]
        )
    ]

    static let weeklyQuests: [QuickQuestTemplate] = [
        QuickQuestTemplate(
            title: "quick_quest_weekly_planning".localized,
            description: "quick_quest_weekly_planning_description".localized,
            category: .productivity,
            difficulty: 2,
            iconName: "calendar.badge.clock",
            tasks: [
                QuestTask(id: UUID(), title: "quick_quest_weekly_planning_task_1".localized, isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "quick_quest_weekly_planning_task_2".localized, isCompleted: false, order: 2),
                QuestTask(id: UUID(), title: "quick_quest_weekly_planning_task_3".localized, isCompleted: false, order: 3),
                QuestTask(id: UUID(), title: "quick_quest_weekly_planning_task_4".localized, isCompleted: false, order: 4)
            ]
        ),
        QuickQuestTemplate(
            title: "quick_quest_skill_development".localized,
            description: "quick_quest_skill_development_description".localized,
            category: .learning,
            difficulty: 3,
            iconName: "brain.head.profile",
            tasks: [
                QuestTask(id: UUID(), title: "quick_quest_skill_development_task_1".localized, isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "quick_quest_skill_development_task_2".localized, isCompleted: false, order: 2),
                QuestTask(id: UUID(), title: "quick_quest_skill_development_task_3".localized, isCompleted: false, order: 3),
                QuestTask(id: UUID(), title: "quick_quest_skill_development_task_4".localized, isCompleted: false, order: 4)
            ]
        ),
        QuickQuestTemplate(
            title: "quick_quest_social_connection".localized,
            description: "quick_quest_social_connection_description".localized,
            category: .social,
            difficulty: 2,
            iconName: "person.2.fill",
            tasks: [
                QuestTask(id: UUID(), title: "quick_quest_social_connection_task_1".localized, isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "quick_quest_social_connection_task_2".localized, isCompleted: false, order: 2),
                QuestTask(id: UUID(), title: "quick_quest_social_connection_task_3".localized, isCompleted: false, order: 3),
                QuestTask(id: UUID(), title: "quick_quest_social_connection_task_4".localized, isCompleted: false, order: 4)
            ]
        ),
        QuickQuestTemplate(
            title: "quick_quest_home_organization".localized,
            description: "quick_quest_home_organization_description".localized,
            category: .productivity,
            difficulty: 2,
            iconName: "house.fill",
            tasks: [
                QuestTask(id: UUID(), title: "quick_quest_home_organization_task_1".localized, isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "quick_quest_home_organization_task_2".localized, isCompleted: false, order: 2),
                QuestTask(id: UUID(), title: "quick_quest_home_organization_task_3".localized, isCompleted: false, order: 3),
                QuestTask(id: UUID(), title: "quick_quest_home_organization_task_4".localized, isCompleted: false, order: 4)
            ]
        )
    ]

    static let oneTimeQuests: [QuickQuestTemplate] = [
        QuickQuestTemplate(
            title: "quick_quest_bucket_list_adventure".localized,
            description: "quick_quest_bucket_list_adventure_description".localized,
            category: .social,
            difficulty: 4,
            iconName: "star.fill",
            tasks: [
                QuestTask(id: UUID(), title: "quick_quest_bucket_list_adventure_task_1".localized, isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "quick_quest_bucket_list_adventure_task_2".localized, isCompleted: false, order: 2),
                QuestTask(id: UUID(), title: "quick_quest_bucket_list_adventure_task_3".localized, isCompleted: false, order: 3),
                QuestTask(id: UUID(), title: "quick_quest_bucket_list_adventure_task_4".localized, isCompleted: false, order: 4),
                QuestTask(id: UUID(), title: "quick_quest_bucket_list_adventure_task_5".localized, isCompleted: false, order: 5)
            ]
        ),
        QuickQuestTemplate(
            title: "quick_quest_digital_detox".localized,
            description: "quick_quest_digital_detox_description".localized,
            category: .mindfulness,
            difficulty: 3,
            iconName: "iphone.slash",
            tasks: [
                QuestTask(id: UUID(), title: "quick_quest_digital_detox_task_1".localized, isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "quick_quest_digital_detox_task_2".localized, isCompleted: false, order: 2),
                QuestTask(id: UUID(), title: "quick_quest_digital_detox_task_3".localized, isCompleted: false, order: 3),
                QuestTask(id: UUID(), title: "quick_quest_digital_detox_task_4".localized, isCompleted: false, order: 4),
                QuestTask(id: UUID(), title: "quick_quest_digital_detox_task_5".localized, isCompleted: false, order: 5)
            ]
        ),
        QuickQuestTemplate(
            title: "quick_quest_creative_project".localized,
            description: "quick_quest_creative_project_description".localized,
            category: .learning,
            difficulty: 3,
            iconName: "paintbrush.fill",
            tasks: [
                QuestTask(id: UUID(), title: "quick_quest_creative_project_task_1".localized, isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "quick_quest_creative_project_task_2".localized, isCompleted: false, order: 2),
                QuestTask(id: UUID(), title: "quick_quest_creative_project_task_3".localized, isCompleted: false, order: 3),
                QuestTask(id: UUID(), title: "quick_quest_creative_project_task_4".localized, isCompleted: false, order: 4),
                QuestTask(id: UUID(), title: "quick_quest_creative_project_task_5".localized, isCompleted: false, order: 5)
            ]
        ),
        QuickQuestTemplate(
            title: "quick_quest_fitness_challenge".localized,
            description: "quick_quest_fitness_challenge_description".localized,
            category: .fitness,
            difficulty: 4,
            iconName: "figure.strengthtraining.traditional",
            tasks: [
                QuestTask(id: UUID(), title: "quick_quest_fitness_challenge_task_1".localized, isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "quick_quest_fitness_challenge_task_2".localized, isCompleted: false, order: 2),
                QuestTask(id: UUID(), title: "quick_quest_fitness_challenge_task_3".localized, isCompleted: false, order: 3),
                QuestTask(id: UUID(), title: "quick_quest_fitness_challenge_task_4".localized, isCompleted: false, order: 4),
                QuestTask(id: UUID(), title: "quick_quest_fitness_challenge_task_5".localized, isCompleted: false, order: 5)
            ]
        )
    ]
}
