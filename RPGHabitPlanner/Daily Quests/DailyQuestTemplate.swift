//
//  DailyQuestTemplate.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import Foundation
import SwiftUI

enum DailyQuestCategory: String, CaseIterable {
    case health = "health"
    case productivity = "productivity"
    case learning = "learning"
    case mindfulness = "mindfulness"
    case fitness = "fitness"
    case social = "social"
    
    var displayName: String {
        switch self {
        case .health:
            return "Health & Wellness"
        case .productivity:
            return "Productivity"
        case .learning:
            return "Learning & Growth"
        case .mindfulness:
            return "Mindfulness"
        case .fitness:
            return "Fitness"
        case .social:
            return "Social"
        }
    }
    
    var iconName: String {
        switch self {
        case .health:
            return "heart.fill"
        case .productivity:
            return "bolt.fill"
        case .learning:
            return "book.fill"
        case .mindfulness:
            return "brain.head.profile"
        case .fitness:
            return "figure.run"
        case .social:
            return "person.2.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .health:
            return .red
        case .productivity:
            return .blue
        case .learning:
            return .purple
        case .mindfulness:
            return .indigo
        case .fitness:
            return .green
        case .social:
            return .orange
        }
    }
}

struct DailyQuestTemplate: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let category: DailyQuestCategory
    let difficulty: Int
    let iconName: String
    let tasks: [QuestTask]
    
    static var allTemplates: [DailyQuestTemplate] {
        return healthQuests + productivityQuests + learningQuests + mindfulnessQuests + fitnessQuests + socialQuests
    }
    
    // MARK: - Health Quests
    static let healthQuests: [DailyQuestTemplate] = [
        DailyQuestTemplate(
            title: "Hydration Hero",
            description: "Drink 8 glasses of water throughout the day",
            category: .health,
            difficulty: 15,
            iconName: "drop.fill",
            tasks: [
                QuestTask(id: UUID(), title: "Drink 2 glasses of water in the morning", isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "Drink 2 glasses of water at lunch", isCompleted: false, order: 2),
                QuestTask(id: UUID(), title: "Drink 2 glasses of water in the afternoon", isCompleted: false, order: 3),
                QuestTask(id: UUID(), title: "Drink 2 glasses of water in the evening", isCompleted: false, order: 4)
            ]
        ),
        DailyQuestTemplate(
            title: "Sleep Champion",
            description: "Get 7-8 hours of quality sleep",
            category: .health,
            difficulty: 20,
            iconName: "bed.double.fill",
            tasks: [
                QuestTask(id: UUID(), title: "Go to bed by 10 PM", isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "Avoid screens 1 hour before bed", isCompleted: false, order: 2),
                QuestTask(id: UUID(), title: "Sleep for 7-8 hours", isCompleted: false, order: 3)
            ]
        ),
        DailyQuestTemplate(
            title: "Healthy Eater",
            description: "Eat 3 balanced meals with fruits and vegetables",
            category: .health,
            difficulty: 25,
            iconName: "leaf.fill",
            tasks: [
                QuestTask(id: UUID(), title: "Eat a healthy breakfast", isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "Include vegetables in lunch", isCompleted: false, order: 2),
                QuestTask(id: UUID(), title: "Eat a balanced dinner", isCompleted: false, order: 3),
                QuestTask(id: UUID(), title: "Eat 2 servings of fruits", isCompleted: false, order: 4)
            ]
        )
    ]
    
    // MARK: - Productivity Quests
    static let productivityQuests: [DailyQuestTemplate] = [
        DailyQuestTemplate(
            title: "Task Master",
            description: "Complete 5 important tasks from your to-do list",
            category: .productivity,
            difficulty: 30,
            iconName: "checklist",
            tasks: [
                QuestTask(id: UUID(), title: "Complete task 1", isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "Complete task 2", isCompleted: false, order: 2),
                QuestTask(id: UUID(), title: "Complete task 3", isCompleted: false, order: 3),
                QuestTask(id: UUID(), title: "Complete task 4", isCompleted: false, order: 4),
                QuestTask(id: UUID(), title: "Complete task 5", isCompleted: false, order: 5)
            ]
        ),
        DailyQuestTemplate(
            title: "Time Tracker",
            description: "Track your time and stay focused for 6 hours",
            category: .productivity,
            difficulty: 25,
            iconName: "clock.fill",
            tasks: [
                QuestTask(id: UUID(), title: "Work focused for 2 hours in the morning", isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "Work focused for 2 hours in the afternoon", isCompleted: false, order: 2),
                QuestTask(id: UUID(), title: "Work focused for 2 hours in the evening", isCompleted: false, order: 3)
            ]
        ),
        DailyQuestTemplate(
            title: "Declutter Warrior",
            description: "Organize and declutter one area of your space",
            category: .productivity,
            difficulty: 20,
            iconName: "trash.fill",
            tasks: [
                QuestTask(id: UUID(), title: "Choose an area to declutter", isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "Remove unnecessary items", isCompleted: false, order: 2),
                QuestTask(id: UUID(), title: "Organize remaining items", isCompleted: false, order: 3)
            ]
        )
    ]
    
    // MARK: - Learning Quests
    static let learningQuests: [DailyQuestTemplate] = [
        DailyQuestTemplate(
            title: "Knowledge Seeker",
            description: "Learn something new for 30 minutes",
            category: .learning,
            difficulty: 20,
            iconName: "lightbulb.fill",
            tasks: [
                QuestTask(id: UUID(), title: "Read an educational article", isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "Watch an educational video", isCompleted: false, order: 2),
                QuestTask(id: UUID(), title: "Practice a new skill", isCompleted: false, order: 3)
            ]
        ),
        DailyQuestTemplate(
            title: "Language Learner",
            description: "Practice a foreign language for 20 minutes",
            category: .learning,
            difficulty: 25,
            iconName: "text.bubble.fill",
            tasks: [
                QuestTask(id: UUID(), title: "Practice vocabulary for 10 minutes", isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "Listen to language audio for 10 minutes", isCompleted: false, order: 2)
            ]
        ),
        DailyQuestTemplate(
            title: "Book Worm",
            description: "Read for 30 minutes",
            category: .learning,
            difficulty: 15,
            iconName: "book.closed.fill",
            tasks: [
                QuestTask(id: UUID(), title: "Read for 15 minutes in the morning", isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "Read for 15 minutes in the evening", isCompleted: false, order: 2)
            ]
        )
    ]
    
    // MARK: - Mindfulness Quests
    static let mindfulnessQuests: [DailyQuestTemplate] = [
        DailyQuestTemplate(
            title: "Meditation Master",
            description: "Meditate for 10 minutes",
            category: .mindfulness,
            difficulty: 20,
            iconName: "brain.head.profile",
            tasks: [
                QuestTask(id: UUID(), title: "Find a quiet space", isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "Sit comfortably and close your eyes", isCompleted: false, order: 2),
                QuestTask(id: UUID(), title: "Focus on your breath for 10 minutes", isCompleted: false, order: 3)
            ]
        ),
        DailyQuestTemplate(
            title: "Gratitude Journal",
            description: "Write down 3 things you're grateful for",
            category: .mindfulness,
            difficulty: 15,
            iconName: "heart.text.square.fill",
            tasks: [
                QuestTask(id: UUID(), title: "Write down 3 things you're grateful for", isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "Reflect on why you're grateful for each", isCompleted: false, order: 2)
            ]
        ),
        DailyQuestTemplate(
            title: "Mindful Walking",
            description: "Take a 15-minute mindful walk",
            category: .mindfulness,
            difficulty: 15,
            iconName: "figure.walk",
            tasks: [
                QuestTask(id: UUID(), title: "Walk slowly and mindfully", isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "Notice your surroundings", isCompleted: false, order: 2),
                QuestTask(id: UUID(), title: "Focus on your breathing while walking", isCompleted: false, order: 3)
            ]
        )
    ]
    
    // MARK: - Fitness Quests
    static let fitnessQuests: [DailyQuestTemplate] = [
        DailyQuestTemplate(
            title: "Morning Exercise",
            description: "Do 20 minutes of morning exercise",
            category: .fitness,
            difficulty: 25,
            iconName: "figure.run",
            tasks: [
                QuestTask(id: UUID(), title: "Do 10 push-ups", isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "Do 20 jumping jacks", isCompleted: false, order: 2),
                QuestTask(id: UUID(), title: "Do 10 squats", isCompleted: false, order: 3),
                QuestTask(id: UUID(), title: "Stretch for 5 minutes", isCompleted: false, order: 4)
            ]
        ),
        DailyQuestTemplate(
            title: "Step Counter",
            description: "Walk 10,000 steps today",
            category: .fitness,
            difficulty: 30,
            iconName: "figure.walk",
            tasks: [
                QuestTask(id: UUID(), title: "Walk 2,500 steps in the morning", isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "Walk 2,500 steps in the afternoon", isCompleted: false, order: 2),
                QuestTask(id: UUID(), title: "Walk 2,500 steps in the evening", isCompleted: false, order: 3),
                QuestTask(id: UUID(), title: "Walk 2,500 steps throughout the day", isCompleted: false, order: 4)
            ]
        ),
        DailyQuestTemplate(
            title: "Stretch Break",
            description: "Take 3 stretch breaks throughout the day",
            category: .fitness,
            difficulty: 15,
            iconName: "figure.flexibility",
            tasks: [
                QuestTask(id: UUID(), title: "Morning stretch routine", isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "Afternoon stretch break", isCompleted: false, order: 2),
                QuestTask(id: UUID(), title: "Evening stretch routine", isCompleted: false, order: 3)
            ]
        )
    ]
    
    // MARK: - Social Quests
    static let socialQuests: [DailyQuestTemplate] = [
        DailyQuestTemplate(
            title: "Connection Builder",
            description: "Reach out to 2 friends or family members",
            category: .social,
            difficulty: 20,
            iconName: "message.fill",
            tasks: [
                QuestTask(id: UUID(), title: "Send a message to a friend", isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "Call a family member", isCompleted: false, order: 2)
            ]
        ),
        DailyQuestTemplate(
            title: "Kindness Ambassador",
            description: "Perform 3 acts of kindness",
            category: .social,
            difficulty: 25,
            iconName: "heart.fill",
            tasks: [
                QuestTask(id: UUID(), title: "Hold the door for someone", isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "Give a genuine compliment", isCompleted: false, order: 2),
                QuestTask(id: UUID(), title: "Help someone with a task", isCompleted: false, order: 3)
            ]
        ),
        DailyQuestTemplate(
            title: "Social Butterfly",
            description: "Have a meaningful conversation with someone new",
            category: .social,
            difficulty: 30,
            iconName: "person.2.fill",
            tasks: [
                QuestTask(id: UUID(), title: "Start a conversation with someone new", isCompleted: false, order: 1),
                QuestTask(id: UUID(), title: "Ask them about their interests", isCompleted: false, order: 2),
                QuestTask(id: UUID(), title: "Share something about yourself", isCompleted: false, order: 3)
            ]
        )
    ]
}
