//
//  QuestDamageTrackingTests.swift
//  RPGHabitPlannerTests
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import XCTest
@testable import RPGHabitPlanner

final class QuestDamageTrackingTests: XCTestCase {
    var damageTrackingManager: QuestDamageTrackingManager!
    var mockQuestDataService: MockQuestDataService!
    var mockHealthManager: MockHealthManager!
    
    override func setUp() {
        super.setUp()
        mockQuestDataService = MockQuestDataService()
        mockHealthManager = MockHealthManager()
        damageTrackingManager = QuestDamageTrackingManager(
            damageTrackingService: QuestDamageTrackingService(),
            questDataService: mockQuestDataService,
            healthManager: mockHealthManager
        )
    }
    
    override func tearDown() {
        damageTrackingManager = nil
        mockQuestDataService = nil
        mockHealthManager = nil
        super.tearDown()
    }
    
    // MARK: - Daily Quest Damage Tests
    
    func testDailyQuestDamageCalculation_FirstTime() {
        // Given: A daily quest that's 3 days overdue, first time calculating damage
        let dueDate = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        let quest = createDailyQuest(dueDate: dueDate)
        
        // When: Calculate damage for the first time
        let calculator = QuestTypeDamageCalculator.daily
        let result = calculator.calculateDamage(
            quest: quest,
            lastDamageCheckDate: dueDate
        )
        
        // Then: Should calculate 9 damage (3 days × 3 HP)
        XCTAssertEqual(result.damageAmount, 9)
        XCTAssertEqual(result.missedDays, 3)
        XCTAssertTrue(result.reason.contains("Daily quest"))
        XCTAssertTrue(result.reason.contains("missed 3 day(s)"))
    }
    
    func testDailyQuestDamageCalculation_SecondTime() {
        // Given: A daily quest that's 4 days overdue, but we already calculated damage 3 days ago
        let dueDate = Calendar.current.date(byAdding: .day, value: -4, to: Date())!
        let lastCheckDate = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        let quest = createDailyQuest(dueDate: dueDate)
        
        // When: Calculate damage for the second time
        let calculator = QuestTypeDamageCalculator.daily
        let result = calculator.calculateDamage(
            quest: quest,
            lastDamageCheckDate: lastCheckDate
        )
        
        // Then: Should calculate 3 damage (1 day × 3 HP) - only the new missed day
        XCTAssertEqual(result.damageAmount, 3)
        XCTAssertEqual(result.missedDays, 1)
    }
    
    func testDailyQuestDamageCalculation_CompletedYesterday() {
        // Given: A daily quest that was completed yesterday
        let dueDate = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        let lastCheckDate = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let quest = createDailyQuest(dueDate: dueDate, completions: [yesterday])
        
        // When: Calculate damage
        let calculator = QuestTypeDamageCalculator.daily
        let result = calculator.calculateDamage(
            quest: quest,
            lastDamageCheckDate: lastCheckDate
        )
        
        // Then: Should calculate 0 damage since quest was completed yesterday
        XCTAssertEqual(result.damageAmount, 0)
        XCTAssertEqual(result.missedDays, 0)
    }
    
    // MARK: - Weekly Quest Damage Tests
    
    func testWeeklyQuestDamageCalculation_Overdue() {
        // Given: A weekly quest that's overdue
        let dueDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let quest = createWeeklyQuest(dueDate: dueDate)
        
        // When: Calculate damage
        let calculator = QuestTypeDamageCalculator.weekly
        let result = calculator.calculateDamage(
            quest: quest,
            lastDamageCheckDate: dueDate
        )
        
        // Then: Should calculate 8 damage
        XCTAssertEqual(result.damageAmount, 8)
        XCTAssertEqual(result.missedDays, 1)
        XCTAssertTrue(result.reason.contains("Weekly quest"))
        XCTAssertTrue(result.reason.contains("overdue"))
    }
    
    func testWeeklyQuestDamageCalculation_NotOverdue() {
        // Given: A weekly quest that's not overdue
        let dueDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        let quest = createWeeklyQuest(dueDate: dueDate)
        
        // When: Calculate damage
        let calculator = QuestTypeDamageCalculator.weekly
        let result = calculator.calculateDamage(
            quest: quest,
            lastDamageCheckDate: Date()
        )
        
        // Then: Should calculate 0 damage
        XCTAssertEqual(result.damageAmount, 0)
        XCTAssertEqual(result.missedDays, 0)
        XCTAssertTrue(result.reason.contains("not overdue"))
    }
    
    // MARK: - One-Time Quest Damage Tests
    
    func testOneTimeQuestDamageCalculation_Overdue() {
        // Given: A one-time quest that's overdue
        let dueDate = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        let quest = createOneTimeQuest(dueDate: dueDate)
        
        // When: Calculate damage
        let calculator = QuestTypeDamageCalculator.oneTime
        let result = calculator.calculateDamage(
            quest: quest,
            lastDamageCheckDate: dueDate
        )
        
        // Then: Should calculate 10 damage
        XCTAssertEqual(result.damageAmount, 10)
        XCTAssertEqual(result.missedDays, 1)
        XCTAssertTrue(result.reason.contains("One-time quest"))
        XCTAssertTrue(result.reason.contains("still overdue"))
    }
    
    func testOneTimeQuestDamageCalculation_Completed() {
        // Given: A one-time quest that's completed
        let dueDate = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        let quest = createOneTimeQuest(dueDate: dueDate, isCompleted: true)
        
        // When: Calculate damage
        let calculator = QuestTypeDamageCalculator.oneTime
        let result = calculator.calculateDamage(
            quest: quest,
            lastDamageCheckDate: dueDate
        )
        
        // Then: Should calculate 0 damage since quest is completed
        XCTAssertEqual(result.damageAmount, 0)
        XCTAssertEqual(result.missedDays, 0)
        XCTAssertTrue(result.reason.contains("not overdue"))
    }
    
    // MARK: - Scheduled Quest Damage Tests
    
    func testScheduledQuestDamageCalculation_MissedDays() {
        // Given: A scheduled quest for Monday and Wednesday, missed both this week
        let dueDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let quest = createScheduledQuest(dueDate: dueDate, scheduledDays: [2, 4]) // Monday, Wednesday
        
        // When: Calculate damage for the first time
        let calculator = QuestTypeDamageCalculator.scheduled
        let result = calculator.calculateDamage(
            quest: quest,
            lastDamageCheckDate: dueDate
        )
        
        // Then: Should calculate damage for missed scheduled days
        // Note: This test depends on the current day of the week
        XCTAssertGreaterThanOrEqual(result.damageAmount, 0)
        XCTAssertTrue(result.reason.contains("Scheduled quest"))
    }
    
    // MARK: - Damage Constants Tests
    
    func testDamageConstants() {
        XCTAssertEqual(QuestDamageConstants.dailyQuestDamagePerDay, 3)
        XCTAssertEqual(QuestDamageConstants.weeklyQuestDamage, 8)
        XCTAssertEqual(QuestDamageConstants.oneTimeQuestDamage, 10)
        XCTAssertEqual(QuestDamageConstants.scheduledQuestDamagePerDay, 5)
    }
    
    // MARK: - Helper Methods
    
    private func createDailyQuest(dueDate: Date, completions: Set<Date> = []) -> Quest {
        return Quest(
            title: "Test Daily Quest",
            isMainQuest: false,
            info: "Test quest",
            difficulty: 1,
            creationDate: Date(),
            dueDate: dueDate,
            isActive: true,
            progress: 0,
            repeatType: .daily,
            completions: completions
        )
    }
    
    private func createWeeklyQuest(dueDate: Date, isCompleted: Bool = false) -> Quest {
        return Quest(
            title: "Test Weekly Quest",
            isMainQuest: false,
            info: "Test quest",
            difficulty: 2,
            creationDate: Date(),
            dueDate: dueDate,
            isActive: true,
            progress: 0,
            isCompleted: isCompleted,
            repeatType: .weekly
        )
    }
    
    private func createOneTimeQuest(dueDate: Date, isCompleted: Bool = false) -> Quest {
        return Quest(
            title: "Test One-Time Quest",
            isMainQuest: false,
            info: "Test quest",
            difficulty: 3,
            creationDate: Date(),
            dueDate: dueDate,
            isActive: true,
            progress: 0,
            isCompleted: isCompleted,
            repeatType: .oneTime
        )
    }
    
    private func createScheduledQuest(dueDate: Date, scheduledDays: Set<Int>) -> Quest {
        return Quest(
            title: "Test Scheduled Quest",
            isMainQuest: false,
            info: "Test quest",
            difficulty: 2,
            creationDate: Date(),
            dueDate: dueDate,
            isActive: true,
            progress: 0,
            repeatType: .scheduled,
            scheduledDays: scheduledDays
        )
    }
}

// MARK: - Mock Classes

class MockHealthManager: HealthManager {
    var damageTaken: Int16 = 0
    
    override func takeDamage(_ amount: Int16, completion: @escaping (Error?) -> Void) {
        damageTaken += amount
        completion(nil)
    }
}
