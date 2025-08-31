//
//  RPGHabitPlannerApp.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 26.10.2024.
//

import SwiftUI
import BackgroundTasks
import ActivityKit
import CoreData
import WidgetKit

@main
struct RPGHabitPlannerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var localizationManager = LocalizationManager.shared

    var body: some Scene {
        WindowGroup {
            let questDataService = QuestCoreDataService()
            ContentView(questDataService: questDataService)
                .environmentObject(localizationManager)
                // .environmentObject(ThemeManager())
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                    BackgroundTimerManager.shared.handleAppDidEnterBackground()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    BackgroundTimerManager.shared.handleAppWillEnterForeground()
                }
                .onAppear {
                    // Set up damage tracking integration
                    DamageTrackingIntegration.setupNotificationObservers()
                    
                    // Perform initial damage check on app launch
                    DamageTrackingIntegration.performAppLaunchDamageCheck()
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Setup background timer manager
        BackgroundTimerManager.shared.setupBackgroundTasks()

        // Initialize booster system
        let boosterManager = BoosterManager.shared

        // Prepare haptic feedback generators for immediate use
        HapticFeedbackManager.shared.prepareFeedbackGenerators()

        // Delay booster loading to ensure proper initialization
        DispatchQueue.main.async {
            // Clean up expired effects on app launch
            let activeEffectsService = ActiveEffectsCoreDataService()
            activeEffectsService.clearExpiredEffects()
        }

        return true
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Handle background fetch
        completionHandler(.newData)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Ensure background tasks are properly managed when app enters background
        BackgroundTimerManager.shared.handleAppDidEnterBackground()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Ensure background tasks are properly managed when app enters foreground
        BackgroundTimerManager.shared.handleAppWillEnterForeground()

        // Prepare haptic feedback generators when app becomes active
        HapticFeedbackManager.shared.prepareFeedbackGenerators()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Clean up background tasks when app terminates
        BackgroundTimerManager.shared.stopTimer()
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        handleDeepLink(url: url)
        return true
    }

    private func handleDeepLink(url: URL) {
        guard url.scheme == "rpgquest" else { return }

        print("Received deep link: \(url.absoluteString)")

        let pathComponents = url.pathComponents.filter { $0 != "/" }
        print("Path components: \(pathComponents)")

        if pathComponents.count >= 2 && pathComponents[0] == "toggle-quest" {
            let questIdString = pathComponents[1]
            print("Quest ID string: \(questIdString)")
            if let questId = UUID(uuidString: questIdString) {
                print("Valid quest ID: \(questId)")
                toggleQuestCompletion(questId: questId)
            } else {
                print("Invalid quest ID: \(questIdString)")
            }
        }
    }

    private func toggleQuestCompletion(questId: UUID) {
        print("Toggling quest completion for ID: \(questId)")
        let context = PersistenceController.shared.container.viewContext
        let questRequest: NSFetchRequest<QuestEntity> = QuestEntity.fetchRequest()
        questRequest.predicate = NSPredicate(format: "id == %@", questId as CVarArg)

        do {
            let quests = try context.fetch(questRequest)
            print("Found \(quests.count) quests with ID \(questId)")
            guard let quest = quests.first else {
                print("No quest found with ID \(questId)")
                return
            }

            let today = Calendar.current.startOfDay(for: Date())
            let completionRequest: NSFetchRequest<QuestCompletionEntity> = QuestCompletionEntity.fetchRequest()

            let completionDate: Date
            let repeatType = QuestRepeatType(rawValue: quest.repeatType) ?? .oneTime
            switch repeatType {
            case .daily:
                completionDate = today
            case .weekly:
                completionDate = weekAnchor(for: today)
            case .oneTime:
                completionDate = Calendar.current.startOfDay(for: quest.dueDate ?? today)
            case .scheduled:
                completionDate = today
            }

            completionRequest.predicate = NSPredicate(format: "quest == %@ AND date == %@", quest, completionDate as NSDate)
            let existingCompletions = try context.fetch(completionRequest)

            if !existingCompletions.isEmpty {
                // Remove completion
                print("Removing completion for quest: \(quest.title ?? "Unknown")")
                for completion in existingCompletions {
                    context.delete(completion)
                }
            } else {
                // Add completion
                print("Adding completion for quest: \(quest.title ?? "Unknown")")
                let newCompletion = QuestCompletionEntity(context: context)
                newCompletion.id = UUID()
                newCompletion.date = completionDate
                newCompletion.quest = quest
            }

                          try context.save()

              // Trigger widget refresh
              WidgetCenter.shared.reloadAllTimelines()
        } catch {
            print("Failed to toggle quest completion: \(error)")
        }
    }

    private func weekAnchor(for date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components) ?? date
    }
}
