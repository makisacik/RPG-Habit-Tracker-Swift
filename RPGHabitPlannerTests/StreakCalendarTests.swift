import XCTest
@testable import RPGHabitPlanner

final class StreakCalendarTests: XCTestCase {
    var streakManager: StreakManager!
    
    override func setUp() {
        super.setUp()
        streakManager = StreakManager.shared
        streakManager.resetStreak()
    }
    
    override func tearDown() {
        streakManager.resetStreak()
        super.tearDown()
    }
    
    func testActivityDatesTracking() {
        // Record activity on different days
        streakManager.recordActivity()
        
        // Simulate activity on a different day
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        streakManager.lastActivityDate = yesterday
        streakManager.recordActivity()
        
        let activityDates = streakManager.getActivityDates()
        XCTAssertEqual(activityDates.count, 2)
        
        // Verify today and yesterday are in the activity dates
        let today = Calendar.current.startOfDay(for: Date())
        let yesterdayStart = Calendar.current.startOfDay(for: yesterday)
        
        XCTAssertTrue(activityDates.contains(today))
        XCTAssertTrue(activityDates.contains(yesterdayStart))
    }
    
    func testActivityDatesPersistence() {
        // Record some activity
        streakManager.recordActivity()
        
        let initialDates = streakManager.getActivityDates()
        XCTAssertEqual(initialDates.count, 1)
        
        // Create a new instance to test persistence
        let newStreakManager = StreakManager.shared
        let loadedDates = newStreakManager.getActivityDates()
        
        // Should have the same activity dates
        XCTAssertEqual(loadedDates.count, initialDates.count)
    }
    
    func testMonthlyStatsCalculation() {
        // Record activity on several days
        for i in 0..<5 {
            let daysAgo = Calendar.current.date(byAdding: .day, value: -i, to: Date()) ?? Date()
            streakManager.lastActivityDate = daysAgo
            streakManager.recordActivity()
        }
        
        let activityDates = streakManager.getActivityDates()
        XCTAssertEqual(activityDates.count, 5)
        
        // Test that we can calculate monthly stats
        let currentMonth = Calendar.current.dateInterval(of: .month, for: Date()) ?? DateInterval()
        let monthlyDates = activityDates.filter { date in
            currentMonth.contains(date)
        }
        
        XCTAssertEqual(monthlyDates.count, 5)
    }
}
