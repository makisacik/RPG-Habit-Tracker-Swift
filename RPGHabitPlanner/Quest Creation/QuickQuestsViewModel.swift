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
                }
            }
        }
    }
}

// MARK: - Quick Quest Templates
extension QuickQuestTemplate {
    static let dailyQuests: [QuickQuestTemplate] = [
        QuickQuestTemplate(
            title: "Hydration Hero",
            description: "Drink 8 glasses of water throughout the day",
            category: .health,
            difficulty: 1,
            iconName: "drop.fill",
            tasks: [
                QuestTask(id: UUID(), title: "Drink 2 glasses of water in the morning", isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "Drink 2 glasses of water at lunch", isCompleted: false, order: 2),
                QuestTask(id: UUID(), title: "Drink 2 glasses of water in the afternoon", isCompleted: false, order: 3),
                QuestTask(id: UUID(), title: "Drink 2 glasses of water in the evening", isCompleted: false, order: 4)
            ]
        ),
        QuickQuestTemplate(
            title: "Morning Exercise",
            description: "Complete a 15-minute morning workout routine",
            category: .fitness,
            difficulty: 2,
            iconName: "figure.run",
            tasks: [
                QuestTask(id: UUID(), title: "Do 10 push-ups", isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "Do 20 jumping jacks", isCompleted: false, order: 2),
                QuestTask(id: UUID(), title: "Do 15 squats", isCompleted: false, order: 3),
                QuestTask(id: UUID(), title: "Stretch for 5 minutes", isCompleted: false, order: 4)
            ]
        ),
        QuickQuestTemplate(
            title: "Mindful Reading",
            description: "Read for 20 minutes with full attention",
            category: .learning,
            difficulty: 1,
            iconName: "book.fill",
            tasks: [
                QuestTask(id: UUID(), title: "Find a quiet reading spot", isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "Read for 20 minutes", isCompleted: false, order: 2),
                QuestTask(id: UUID(), title: "Take notes on key points", isCompleted: false, order: 3)
            ]
        ),
        QuickQuestTemplate(
            title: "Gratitude Practice",
            description: "Write down 3 things you're grateful for today",
            category: .mindfulness,
            difficulty: 1,
            iconName: "heart.fill",
            tasks: [
                QuestTask(id: UUID(), title: "Reflect on your day", isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "Write 3 gratitude items", isCompleted: false, order: 2),
                QuestTask(id: UUID(), title: "Feel the positive emotions", isCompleted: false, order: 3)
            ]
        )
    ]
    
    static let weeklyQuests: [QuickQuestTemplate] = [
        QuickQuestTemplate(
            title: "Weekly Planning",
            description: "Plan your week ahead with clear goals and priorities",
            category: .productivity,
            difficulty: 2,
            iconName: "calendar.badge.clock",
            tasks: [
                QuestTask(id: UUID(), title: "Review last week's achievements", isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "Set 3 main goals for the week", isCompleted: false, order: 2),
                QuestTask(id: UUID(), title: "Schedule important tasks", isCompleted: false, order: 3),
                QuestTask(id: UUID(), title: "Plan self-care activities", isCompleted: false, order: 4)
            ]
        ),
        QuickQuestTemplate(
            title: "Skill Development",
            description: "Dedicate time to learning a new skill or improving existing ones",
            category: .learning,
            difficulty: 3,
            iconName: "brain.head.profile",
            tasks: [
                QuestTask(id: UUID(), title: "Choose a skill to focus on", isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "Research learning resources", isCompleted: false, order: 2),
                QuestTask(id: UUID(), title: "Practice for 30 minutes daily", isCompleted: false, order: 3),
                QuestTask(id: UUID(), title: "Track your progress", isCompleted: false, order: 4)
            ]
        ),
        QuickQuestTemplate(
            title: "Social Connection",
            description: "Reach out to friends and family to maintain relationships",
            category: .social,
            difficulty: 2,
            iconName: "person.2.fill",
            tasks: [
                QuestTask(id: UUID(), title: "Call a family member", isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "Message an old friend", isCompleted: false, order: 2),
                QuestTask(id: UUID(), title: "Plan a meetup", isCompleted: false, order: 3),
                QuestTask(id: UUID(), title: "Show appreciation", isCompleted: false, order: 4)
            ]
        ),
        QuickQuestTemplate(
            title: "Home Organization",
            description: "Declutter and organize one area of your home",
            category: .productivity,
            difficulty: 2,
            iconName: "house.fill",
            tasks: [
                QuestTask(id: UUID(), title: "Choose an area to organize", isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "Sort items into keep/donate/trash", isCompleted: false, order: 2),
                QuestTask(id: UUID(), title: "Clean the space thoroughly", isCompleted: false, order: 3),
                QuestTask(id: UUID(), title: "Organize remaining items", isCompleted: false, order: 4)
            ]
        )
    ]
    
    static let oneTimeQuests: [QuickQuestTemplate] = [
        QuickQuestTemplate(
            title: "Bucket List Adventure",
            description: "Complete one item from your bucket list or try something completely new",
            category: .social,
            difficulty: 4,
            iconName: "star.fill",
            tasks: [
                QuestTask(id: UUID(), title: "Identify a bucket list item", isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "Research and plan the adventure", isCompleted: false, order: 2),
                QuestTask(id: UUID(), title: "Make necessary arrangements", isCompleted: false, order: 3),
                QuestTask(id: UUID(), title: "Execute the adventure", isCompleted: false, order: 4),
                QuestTask(id: UUID(), title: "Document the experience", isCompleted: false, order: 5)
            ]
        ),
        QuickQuestTemplate(
            title: "Digital Detox",
            description: "Take a complete break from social media and digital devices for a set period",
            category: .mindfulness,
            difficulty: 3,
            iconName: "iphone.slash",
            tasks: [
                QuestTask(id: UUID(), title: "Set detox duration and rules", isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "Inform friends and family", isCompleted: false, order: 2),
                QuestTask(id: UUID(), title: "Find alternative activities", isCompleted: false, order: 3),
                QuestTask(id: UUID(), title: "Complete the detox period", isCompleted: false, order: 4),
                QuestTask(id: UUID(), title: "Reflect on the experience", isCompleted: false, order: 5)
            ]
        ),
        QuickQuestTemplate(
            title: "Creative Project",
            description: "Start and complete a creative project that you've been wanting to do",
            category: .learning,
            difficulty: 3,
            iconName: "paintbrush.fill",
            tasks: [
                QuestTask(id: UUID(), title: "Choose your creative project", isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "Gather materials and resources", isCompleted: false, order: 2),
                QuestTask(id: UUID(), title: "Set milestones and timeline", isCompleted: false, order: 3),
                QuestTask(id: UUID(), title: "Work on the project regularly", isCompleted: false, order: 4),
                QuestTask(id: UUID(), title: "Complete and showcase the project", isCompleted: false, order: 5)
            ]
        ),
        QuickQuestTemplate(
            title: "Fitness Challenge",
            description: "Complete a 30-day fitness challenge to build healthy habits",
            category: .fitness,
            difficulty: 4,
            iconName: "figure.strengthtraining.traditional",
            tasks: [
                QuestTask(id: UUID(), title: "Choose a fitness challenge", isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "Set up tracking system", isCompleted: false, order: 2),
                QuestTask(id: UUID(), title: "Complete daily workouts", isCompleted: false, order: 3),
                QuestTask(id: UUID(), title: "Track progress and adjust", isCompleted: false, order: 4),
                QuestTask(id: UUID(), title: "Complete the 30-day challenge", isCompleted: false, order: 5)
            ]
        )
    ]
}
