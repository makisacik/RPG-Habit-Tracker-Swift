import XCTest
@testable import RPGHabitPlanner

final class StreakManagerTests: XCTestCase {
    var streakManager: StreakManager!

    override func setUp() {
        super.setUp()
        streakManager = StreakManager.shared
        // Reset streak for testing
        streakManager.resetStreak()
    }

    override func tearDown() {
        streakManager.resetStreak()
        super.tearDown()
    }

    func testInitialStreakState() {
        XCTAssertEqual(streakManager.getCurrentStreak(), 0)
        XCTAssertEqual(streakManager.getLongestStreak(), 0)
        XCTAssertNil(streakManager.getLastActivityDate())
        XCTAssertFalse(streakManager.wasActiveToday())
    }

    func testFirstActivity() {
        streakManager.recordActivity()

        XCTAssertEqual(streakManager.getCurrentStreak(), 1)
        XCTAssertEqual(streakManager.getLongestStreak(), 1)
        XCTAssertNotNil(streakManager.getLastActivityDate())
        XCTAssertTrue(streakManager.wasActiveToday())
    }

    func testConsecutiveDays() {
        // Record activity today
        streakManager.recordActivity()
        XCTAssertEqual(streakManager.getCurrentStreak(), 1)

        // Simulate next day activity
        let today = Date().startOfDay
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!

        // Manually set last activity to yesterday
        streakManager.lastActivityDate = yesterday

        // Record activity again (should increment streak)
        streakManager.recordActivity()

        XCTAssertEqual(streakManager.getCurrentStreak(), 2)
        XCTAssertEqual(streakManager.getLongestStreak(), 2)
    }

    func testStreakBreak() {
        // Record activity today
        streakManager.recordActivity()
        XCTAssertEqual(streakManager.getCurrentStreak(), 1)

        // Simulate activity 2 days ago (missing yesterday)
        let today = Date().startOfDay
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: today)!

        // Manually set last activity to 2 days ago
        streakManager.lastActivityDate = twoDaysAgo

        // Record activity again (should reset streak to 1)
        streakManager.recordActivity()

        XCTAssertEqual(streakManager.getCurrentStreak(), 1)
        XCTAssertEqual(streakManager.getLongestStreak(), 1) // Longest streak should remain 1
    }

    func testLongestStreakTracking() {
        // Simulate a 5-day streak
        for i in 0..<5 {
            let daysAgo = Calendar.current.date(byAdding: .day, value: -i, to: Date().startOfDay)!
            streakManager.lastActivityDate = daysAgo
            streakManager.currentStreak = 5 - i
            streakManager.longestStreak = 5
        }

        // Break streak and start new one
        let sixDaysAgo = Calendar.current.date(byAdding: .day, value: -6, to: Date().startOfDay)!
        streakManager.lastActivityDate = sixDaysAgo

        streakManager.recordActivity()

        XCTAssertEqual(streakManager.getCurrentStreak(), 1)
        XCTAssertEqual(streakManager.getLongestStreak(), 5) // Should preserve longest streak
    }

    func testSameDayActivity() {
        // Record activity
        streakManager.recordActivity()
        let initialStreak = streakManager.getCurrentStreak()

        // Record activity again on same day
        streakManager.recordActivity()

        // Streak should not change
        XCTAssertEqual(streakManager.getCurrentStreak(), initialStreak)
    }
}

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
}
