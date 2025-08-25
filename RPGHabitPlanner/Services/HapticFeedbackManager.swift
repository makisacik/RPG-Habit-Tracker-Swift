//
//  HapticFeedbackManager.swift
//  RPGHabitPlanner
//
//  Created by AI Assistant on 2025-01-07.
//

import UIKit

/// A utility class that provides haptic feedback for quest and task interactions
/// in the RPG habit planner app.
class HapticFeedbackManager {
    // MARK: - Singleton
    static let shared = HapticFeedbackManager()
    
    // MARK: - Private Properties
    private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let lightImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    private let softImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .soft)
    private let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
    
    // MARK: - Initialization
    private init() {
        // Prepare the feedback generators for immediate use
        impactFeedbackGenerator.prepare()
        lightImpactFeedbackGenerator.prepare()
        softImpactFeedbackGenerator.prepare()
        notificationFeedbackGenerator.prepare()
    }
    
    // MARK: - Quest Feedback Methods
    
    /// Provides medium impact feedback when a quest is completed
    func questCompleted() {
        impactFeedbackGenerator.impactOccurred()
    }
    
    /// Provides light impact feedback when a quest is uncompleted/toggled off
    func questUncompleted() {
        lightImpactFeedbackGenerator.impactOccurred()
    }
    
    /// Provides success notification feedback when a quest is marked as permanently finished
    func questFinished() {
        notificationFeedbackGenerator.notificationOccurred(.success)
    }
    
    // MARK: - Task Feedback Methods
    
    /// Provides light impact feedback when a task is completed
    func taskCompleted() {
        lightImpactFeedbackGenerator.impactOccurred()
    }
    
    /// Provides soft impact feedback when a task is uncompleted/toggled off
    func taskUncompleted() {
        softImpactFeedbackGenerator.impactOccurred()
    }
    
    // MARK: - Error Feedback Method
    
    /// Provides error notification feedback for failures
    func errorOccurred() {
        notificationFeedbackGenerator.notificationOccurred(.error)
    }
    
    // MARK: - Utility Methods
    
    /// Prepares all feedback generators for immediate use
    /// Call this method when the app becomes active to ensure responsive haptic feedback
    func prepareFeedbackGenerators() {
        impactFeedbackGenerator.prepare()
        lightImpactFeedbackGenerator.prepare()
        softImpactFeedbackGenerator.prepare()
        notificationFeedbackGenerator.prepare()
    }
}
