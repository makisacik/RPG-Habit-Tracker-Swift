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
    private var backgroundTaskTimer: Timer?
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
        do {
            BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundTaskIdentifier, using: nil) { task in
                self.handleBackgroundTask(task as! BGAppRefreshTask)
            }
            print("✅ Background task scheduler configured successfully")
        } catch {
            print("❌ Failed to configure background task scheduler: \(error)")
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

        // Start local timer with high precision
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
        // Ensure timer runs on the main run loop for better accuracy
        RunLoop.main.add(timer!, forMode: .common)

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

        // Ensure background task is ended when paused
        endBackgroundTask()
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false

        // End background task immediately
        endBackgroundTask()

        // End Live Activity
        endLiveActivity()

        // Cancel pending notifications
        cancelNotifications()
    }

    private func updateTimer() {
        guard let startTime = startTime else { return }

        let elapsed = Date().timeIntervalSince(startTime)
        let newTimeRemaining = max(0, totalDuration - elapsed)

        // Always update the time remaining to ensure consistent 1-second decrements
        timeRemaining = newTimeRemaining

        // Update Live Activity
        updateLiveActivity()

        if timeRemaining <= 0 {
            timerCompleted()
        }
    }

    private func timerCompleted() {
        stopTimer()

        // Ensure background task is ended when timer completes
        endBackgroundTask()

        // Send completion notification
        sendCompletionNotification()

        // Post notification for app to handle
        NotificationCenter.default.post(name: .timerCompleted, object: nil)
    }

    // MARK: - Background Tasks

    private func startBackgroundTask() {
        // End any existing background task first
        endBackgroundTask()

        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "TimerBackgroundTask") { [weak self] in
            // This is called when the background task is about to expire
            print("⚠️ Background task expiring, ending task")
            self?.endBackgroundTask()
        }

        // Set a timer to end the background task after 28 seconds to avoid the 30-second warning
        // but give more time for the timer to continue running
        backgroundTaskTimer = Timer.scheduledTimer(withTimeInterval: 28.0, repeats: false) { [weak self] _ in
            print("⏰ Background task timeout reached, ending task")
            self?.endBackgroundTask()
        }

        print("✅ Background task started with ID: \(backgroundTask.rawValue)")
    }

    private func endBackgroundTask() {
        // Invalidate the background task timer
        backgroundTaskTimer?.invalidate()
        backgroundTaskTimer = nil

        if backgroundTask != .invalid {
            print("🛑 Ending background task with ID: \(backgroundTask.rawValue)")
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }

    private func handleBackgroundTask(_ task: BGAppRefreshTask) {
        print("🔄 Background task started")
        // Check if timer is still running
        if isTimerRunning {
            updateTimer()
            print("✅ Background task completed successfully")
        } else {
            print("⚠️ Timer not running, ending background task")
        }

        task.setTaskCompleted(success: true)
    }

    private func scheduleBackgroundTask() {
        // Only schedule if the app is in background and timer is running
        guard UIApplication.shared.applicationState == .background && isTimerRunning else {
            return
        }
        let request = BGAppRefreshTaskRequest(identifier: backgroundTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 30) // 30 seconds from now
        do {
            try BGTaskScheduler.shared.submit(request)
            print("✅ Background task scheduled successfully")
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
        print("📱 App entered background")
        if isTimerRunning {
            // Don't schedule background task immediately - let the system handle it
            print("⏱️ Timer is running, keeping background task active")
        } else {
            // Ensure background task is ended if timer is not running
            endBackgroundTask()
        }
    }

    func handleAppWillEnterForeground() {
        print("📱 App entering foreground")
        // Refresh timer state if needed
        if isTimerRunning {
            updateTimer()
        }

        // End background task when app comes to foreground
        endBackgroundTask()
    }

    // MARK: - Debug Methods

    func testLiveActivity() {
        // Live Activities not available on this device
    }

    // MARK: - Cleanup

    deinit {
        endBackgroundTask()
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let timerCompleted = Notification.Name("timerCompleted")
}
