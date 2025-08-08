//
//  BackgroundTimerManager.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import Foundation
import UserNotifications
import BackgroundTasks
import ActivityKit
import UIKit

class BackgroundTimerManager: ObservableObject {
    static let shared = BackgroundTimerManager()
    
    private let backgroundTaskIdentifier = "com.rpghabitplanner.timer"
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private var timer: Timer?
    private var startTime: Date?
    private var totalDuration: TimeInterval = 0
    
    @Published var isTimerRunning = false
    @Published var timeRemaining: TimeInterval = 0
    @Published var currentPhase: String = "Work"
    
    private init() {
        setupNotifications()
    }
    
    // MARK: - Setup
    
    private func setupNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ Notification permission granted")
            } else {
                print("❌ Notification permission denied: \(error?.localizedDescription ?? "")")
            }
        }
    }
    
    func setupBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundTaskIdentifier, using: nil) { task in
            self.handleBackgroundTask(task as! BGAppRefreshTask)
        }
    }
    
    // MARK: - Timer Management
    
    func startTimer(duration: TimeInterval, phase: String) {
        stopTimer()
        
        totalDuration = duration
        timeRemaining = duration
        currentPhase = phase
        startTime = Date()
        isTimerRunning = true
        
        // Start local timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
        
        // Start background task
        startBackgroundTask()
        
        // Start Live Activity
        startLiveActivity()
        
        // Schedule completion notification
        scheduleCompletionNotification()
    }
    
    func pauseTimer() {
        stopTimer()
        isTimerRunning = false
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
        
        // End background task
        endBackgroundTask()
        
        // End Live Activity
        endLiveActivity()
        
        // Cancel pending notifications
        cancelNotifications()
    }
    
    private func updateTimer() {
        guard let startTime = startTime else { return }
        
        let elapsed = Date().timeIntervalSince(startTime)
        timeRemaining = max(0, totalDuration - elapsed)
        
        // Update Live Activity
        updateLiveActivity()
        
        if timeRemaining <= 0 {
            timerCompleted()
        }
    }
    
    private func timerCompleted() {
        stopTimer()
        
        // Send completion notification
        sendCompletionNotification()
        
        // Post notification for app to handle
        NotificationCenter.default.post(name: .timerCompleted, object: nil)
    }
    
    // MARK: - Background Tasks
    
    private func startBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "TimerBackgroundTask") { [weak self] in
            self?.endBackgroundTask()
        }
    }
    
    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
    
    private func handleBackgroundTask(_ task: BGAppRefreshTask) {
        // Schedule next background task
        scheduleBackgroundTask()
        
        // Check if timer is still running
        if isTimerRunning {
            updateTimer()
        }
        
        task.setTaskCompleted(success: true)
    }
    
    private func scheduleBackgroundTask() {
        let request = BGAppRefreshTaskRequest(identifier: backgroundTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 30) // 30 seconds from now
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("❌ Could not schedule background task: \(error)")
        }
    }
    
    // MARK: - Live Activities
    
    private var liveActivity: Activity<FocusTimerAttributes>?
    
    private func startLiveActivity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            return
        }
        
        let attributes = FocusTimerAttributes(
            timerName: currentPhase,
            totalDuration: totalDuration
        )
        
        let contentState = FocusTimerAttributes.ContentState(
            timeRemaining: timeRemaining,
            progress: 1.0 - (timeRemaining / totalDuration)
        )
        
        do {
            liveActivity = try Activity.request(
                attributes: attributes,
                contentState: contentState,
                pushType: nil
            )
        } catch {
            // Live Activity failed to start
        }
    }
    
    private func updateLiveActivity() {
        Task {
            guard let liveActivity = liveActivity else {
                return
            }
            
            let contentState = FocusTimerAttributes.ContentState(
                timeRemaining: timeRemaining,
                progress: 1.0 - (timeRemaining / totalDuration)
            )
            
            await liveActivity.update(using: contentState)
        }
    }
    
    private func endLiveActivity() {
        Task {
            await liveActivity?.end(dismissalPolicy: .immediate)
            liveActivity = nil
        }
    }
    
    // MARK: - Notifications
    
    private func scheduleCompletionNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Focus Timer Complete!"
        content.body = "Your \(currentPhase) session has finished."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeRemaining, repeats: false)
        let request = UNNotificationRequest(identifier: "timer-completion", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule notification: \(error)")
            }
        }
    }
    
    private func sendCompletionNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Focus Timer Complete!"
        content.body = "Your \(currentPhase) session has finished."
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: "timer-completion-now", content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to send notification: \(error)")
            }
        }
    }
    
    private func cancelNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["timer-completion"])
    }
    
    // MARK: - App State Handling
    
    func handleAppDidEnterBackground() {
        if isTimerRunning {
            scheduleBackgroundTask()
        }
    }
    
    func handleAppWillEnterForeground() {
        // Refresh timer state if needed
        if isTimerRunning {
            updateTimer()
        }
    }
    
    // MARK: - Debug Methods
    
    func testLiveActivity() {
        // Live Activities not available on this device
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let timerCompleted = Notification.Name("timerCompleted")
}
