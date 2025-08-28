//
//  PremiumManagerTests.swift
//  RPGHabitPlannerTests
//
//  Created by Mehmet Ali Kısacık on 28.10.2024.
//

import XCTest
@testable import RPGHabitPlanner

final class PremiumManagerTests: XCTestCase {
    var premiumManager: PremiumManager!

    override func setUp() {
        super.setUp()
        premiumManager = PremiumManager.shared
    }

    override func tearDown() {
        premiumManager = nil
        super.tearDown()
    }

    @MainActor
    func testWeeklyQuestLimit() {
        // Reset weekly count for testing
        UserDefaults.standard.set(0, forKey: "weeklyQuestCount")
        
        // Test that free users can create up to 5 quests per week
        XCTAssertTrue(premiumManager.canCreateQuest())
        premiumManager.incrementWeeklyQuestCount()
        
        XCTAssertTrue(premiumManager.canCreateQuest())
        premiumManager.incrementWeeklyQuestCount()
        
        XCTAssertTrue(premiumManager.canCreateQuest())
        premiumManager.incrementWeeklyQuestCount()
        
        XCTAssertTrue(premiumManager.canCreateQuest())
        premiumManager.incrementWeeklyQuestCount()
        
        XCTAssertTrue(premiumManager.canCreateQuest())
        premiumManager.incrementWeeklyQuestCount()
        
        XCTAssertFalse(premiumManager.canCreateQuest())
    }

    @MainActor
    func testPremiumUserCanCreateUnlimitedQuests() {
        // Simulate premium user
        premiumManager.isPremium = true

        XCTAssertTrue(premiumManager.canCreateQuest())
        XCTAssertTrue(premiumManager.canCreateQuest())
        XCTAssertTrue(premiumManager.canCreateQuest())
        XCTAssertTrue(premiumManager.canCreateQuest())

        // Reset for other tests
        premiumManager.isPremium = false
    }

    @MainActor
    func testRemainingFreeQuests() {
        // Reset weekly count for testing
        UserDefaults.standard.set(0, forKey: "weeklyQuestCount")
        
        XCTAssertEqual(premiumManager.remainingFreeQuests(), 5)
        
        premiumManager.incrementWeeklyQuestCount()
        XCTAssertEqual(premiumManager.remainingFreeQuests(), 4)
        
        premiumManager.incrementWeeklyQuestCount()
        XCTAssertEqual(premiumManager.remainingFreeQuests(), 3)
        
        premiumManager.incrementWeeklyQuestCount()
        XCTAssertEqual(premiumManager.remainingFreeQuests(), 2)
        
        premiumManager.incrementWeeklyQuestCount()
        XCTAssertEqual(premiumManager.remainingFreeQuests(), 1)
        
        premiumManager.incrementWeeklyQuestCount()
        XCTAssertEqual(premiumManager.remainingFreeQuests(), 0)
    }

    @MainActor
    func testShouldShowPaywall() {
        // Reset weekly count for testing
        UserDefaults.standard.set(0, forKey: "weeklyQuestCount")
        
        XCTAssertFalse(premiumManager.shouldShowPaywall())
        
        premiumManager.incrementWeeklyQuestCount()
        XCTAssertFalse(premiumManager.shouldShowPaywall())
        
        premiumManager.incrementWeeklyQuestCount()
        XCTAssertFalse(premiumManager.shouldShowPaywall())
        
        premiumManager.incrementWeeklyQuestCount()
        XCTAssertFalse(premiumManager.shouldShowPaywall())
        
        premiumManager.incrementWeeklyQuestCount()
        XCTAssertFalse(premiumManager.shouldShowPaywall())
        
        premiumManager.incrementWeeklyQuestCount()
        XCTAssertTrue(premiumManager.shouldShowPaywall())
    }

    @MainActor
    func testPremiumUserShouldNotShowPaywall() {
        // Simulate premium user
        premiumManager.isPremium = true

        XCTAssertFalse(premiumManager.shouldShowPaywall())
        XCTAssertFalse(premiumManager.shouldShowPaywall())
        XCTAssertFalse(premiumManager.shouldShowPaywall())

        // Reset for other tests
        premiumManager.isPremium = false
    }
}
