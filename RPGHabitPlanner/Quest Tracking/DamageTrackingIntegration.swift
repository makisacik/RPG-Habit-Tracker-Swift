//
//  DamageTrackingIntegration.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import SwiftUI

// MARK: - Damage Tracking Integration Examples

/// Example integration of the damage tracking system into the main app
struct DamageTrackingIntegration {
    // MARK: - App Launch Integration
    
    /// Call this when the app launches to check for overdue quests
    static func performAppLaunchDamageCheck() {
        let damageTrackingManager = QuestDamageTrackingManager.shared
        
        // Calculate damage for all active quests
        damageTrackingManager.calculateAndApplyQuestDamage { totalDamage, error in
            if let error = error {
                print("❌ Error calculating quest damage: \(error)")
                return
            }
            
            if totalDamage > 0 {
                print("⚠️ Applied \(totalDamage) damage for missed quests")
                
                // Show notification to user
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: .damageCalculated,
                        object: nil,
                        userInfo: ["damage": totalDamage]
                    )
                }
            } else {
                print("✅ No damage calculated - all quests are up to date")
            }
        }
    }
    
    // MARK: - Quest Completion Integration
    
    /// Call this when a quest is completed
    static func handleQuestCompletion(questId: UUID) {
        let damageTrackingManager = QuestDamageTrackingManager.shared
        
        // Deactivate damage tracking for the completed quest
        damageTrackingManager.deactivateDamageTracking(for: questId) { error in
            if let error = error {
                print("❌ Error deactivating damage tracking: \(error)")
            } else {
                print("✅ Damage tracking deactivated for quest \(questId)")
            }
        }
        
        // Post notification for quest completion
        NotificationCenter.default.post(
            name: .questCompleted,
            object: nil,
            userInfo: ["questId": questId]
        )
    }
    
    // MARK: - Quest Failure Integration
    
    /// Call this when a quest fails
    static func handleQuestFailure(quest: Quest) {
        let damageTrackingManager = QuestDamageTrackingManager.shared
        
        // Calculate and apply damage for the failed quest
        damageTrackingManager.calculateDamageForQuest(quest) { damageAmount, error in
            if let error = error {
                print("❌ Error calculating quest damage: \(error)")
                return
            }
            
            if damageAmount > 0 {
                print("💔 Quest '\(quest.title)' caused \(damageAmount) damage")
                
                // Post notification for quest failure
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: .questFailed,
                        object: nil,
                        userInfo: [
                            "questId": quest.id,
                            "damage": damageAmount,
                            "questTitle": quest.title
                        ]
                    )
                }
            }
        }
    }
    
    // MARK: - Background App Refresh Integration
    
    /// Call this during background app refresh
    static func performBackgroundDamageCheck() {
        let damageTrackingManager = QuestDamageTrackingManager.shared
        
        // Clean up finished quests
        damageTrackingManager.cleanupFinishedQuests { error in
            if let error = error {
                print("❌ Error cleaning up finished quests: \(error)")
            } else {
                print("✅ Finished quests cleanup completed")
            }
        }
        
        // Calculate damage for active quests
        damageTrackingManager.calculateAndApplyQuestDamage { totalDamage, error in
            if let error = error {
                print("❌ Background damage calculation error: \(error)")
                return
            }
            
            if totalDamage > 0 {
                print("⚠️ Background: Applied \(totalDamage) damage")
            }
        }
    }
    
    // MARK: - UI Integration Examples
    
    /// Add damage history button to quest detail view
    static func addDamageHistoryButton(to quest: Quest) -> some View {
        Button(action: {
            // Navigate to damage history view
            // This would be implemented in your navigation system
        }) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                Text("damage_history".localized)
                    .font(.appFont(size: 14, weight: .medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.red.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
    
    /// Add damage calculator button to settings or debug menu
    static func addDamageCalculatorButton() -> some View {
        NavigationLink(destination: DamageCalculationView()) {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.orange)
                Text("damage_calculator".localized)
                    .font(.appFont(size: 16, weight: .medium))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.orange.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Notification Handling
    
    /// Set up notification observers for damage tracking
    static func setupNotificationObservers() {
        // Listen for damage calculation completion
        NotificationCenter.default.addObserver(
            forName: .damageCalculated,
            object: nil,
            queue: .main
        ) { notification in
            if let damage = notification.userInfo?["damage"] as? Int {
                showDamageNotification(damage: damage)
            }
        }
        
        // Listen for quest completion
        NotificationCenter.default.addObserver(
            forName: .questCompleted,
            object: nil,
            queue: .main
        ) { notification in
            if let questId = notification.userInfo?["questId"] as? UUID {
                print("🎉 Quest completed: \(questId)")
            }
        }
        
        // Listen for quest failure
        NotificationCenter.default.addObserver(
            forName: .questFailed,
            object: nil,
            queue: .main
        ) { notification in
            if let questTitle = notification.userInfo?["questTitle"] as? String,
               let damage = notification.userInfo?["damage"] as? Int {
                showQuestFailureNotification(questTitle: questTitle, damage: damage)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private static func showDamageNotification(damage: Int) {
        // Show a notification to the user about damage taken
        // This would be implemented using your notification system
        print("💔 You took \(damage) damage for missed quests")
    }
    
    private static func showQuestFailureNotification(questTitle: String, damage: Int) {
        // Show a notification about quest failure and damage
        print("💔 Quest '\(questTitle)' failed - You took \(damage) damage")
    }
}

// MARK: - Usage Examples

/*
 
 // In your App.swift or main app file:
 
 @main
 struct RPGHabitPlannerApp: App {
     var body: some Scene {
         WindowGroup {
             ContentView()
                 .onAppear {
                     // Set up notification observers
                     DamageTrackingIntegration.setupNotificationObservers()
                     
                     // Perform initial damage check
                     DamageTrackingIntegration.performAppLaunchDamageCheck()
                 }
         }
     }
 }
 
 // In your quest completion handler:
 
 func completeQuest(_ quest: Quest) {
     // Your existing quest completion logic
     
     // Integrate damage tracking
     DamageTrackingIntegration.handleQuestCompletion(questId: quest.id)
 }
 
 // In your quest failure handler:
 
 func failQuest(_ quest: Quest) {
     // Your existing quest failure logic
     
     // Integrate damage tracking
     DamageTrackingIntegration.handleQuestFailure(quest: quest)
 }
 
 // In your background app refresh:
 
 func handleBackgroundAppRefresh() {
     DamageTrackingIntegration.performBackgroundDamageCheck()
 }
 
 // In your quest detail view:
 
 var body: some View {
     VStack {
         // Your existing quest detail content
         
         // Add damage history button
         DamageTrackingIntegration.addDamageHistoryButton(to: quest)
     }
 }
 
 // In your settings view:
 
 var body: some View {
     List {
         // Your existing settings
         
         // Add damage calculator button
         DamageTrackingIntegration.addDamageCalculatorButton()
     }
 }
 
 */
