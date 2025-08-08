//
//  RPGHabitPlannerApp.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 26.10.2024.
//

import SwiftUI
import BackgroundTasks
import ActivityKit

@main
struct RPGHabitPlannerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            let questDataService = QuestCoreDataService()
            ContentView(questDataService: questDataService)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                    BackgroundTimerManager.shared.handleAppDidEnterBackground()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    BackgroundTimerManager.shared.handleAppWillEnterForeground()
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Setup background timer manager
        BackgroundTimerManager.shared.setupBackgroundTasks()

        return true
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Handle background fetch
        completionHandler(.newData)
    }
}
