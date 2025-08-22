//
//  FocusTimerAttributes.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import ActivityKit
import Foundation

public struct FocusTimerAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var timeRemaining: TimeInterval
        public var progress: Double

        public init(timeRemaining: TimeInterval, progress: Double) {
            self.timeRemaining = timeRemaining
            self.progress = progress
        }
    }

    public var timerName: String
    public var totalDuration: TimeInterval

    public init(timerName: String, totalDuration: TimeInterval) {
        self.timerName = timerName
        self.totalDuration = totalDuration
    }
}
