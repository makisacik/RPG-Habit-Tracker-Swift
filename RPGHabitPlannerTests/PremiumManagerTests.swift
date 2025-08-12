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
    func testFreeQuestLimit() {
        // Test that free users can create up to 10 quests
        XCTAssertTrue(premiumManager.canCreateQuest(currentQuestCount: 0))
        XCTAssertTrue(premiumManager.canCreateQuest(currentQuestCount: 5))
        XCTAssertTrue(premiumManager.canCreateQuest(currentQuestCount: 9))
        XCTAssertFalse(premiumManager.canCreateQuest(currentQuestCount: 10))
        XCTAssertFalse(premiumManager.canCreateQuest(currentQuestCount: 15))
    }
    
    @MainActor
    func testPremiumUserCanCreateUnlimitedQuests() {
        // Simulate premium user
        premiumManager.isPremium = true
        
        XCTAssertTrue(premiumManager.canCreateQuest(currentQuestCount: 0))
        XCTAssertTrue(premiumManager.canCreateQuest(currentQuestCount: 10))
        XCTAssertTrue(premiumManager.canCreateQuest(currentQuestCount: 100))
        XCTAssertTrue(premiumManager.canCreateQuest(currentQuestCount: 1000))
        
        // Reset for other tests
        premiumManager.isPremium = false
    }
    
    @MainActor
    func testRemainingFreeQuests() {
        XCTAssertEqual(premiumManager.remainingFreeQuests(currentQuestCount: 0), 10)
        XCTAssertEqual(premiumManager.remainingFreeQuests(currentQuestCount: 5), 5)
        XCTAssertEqual(premiumManager.remainingFreeQuests(currentQuestCount: 10), 0)
        XCTAssertEqual(premiumManager.remainingFreeQuests(currentQuestCount: 15), 0)
    }
    
    @MainActor
    func testShouldShowPaywall() {
        XCTAssertFalse(premiumManager.shouldShowPaywall(currentQuestCount: 0))
        XCTAssertFalse(premiumManager.shouldShowPaywall(currentQuestCount: 5))
        XCTAssertFalse(premiumManager.shouldShowPaywall(currentQuestCount: 9))
        XCTAssertTrue(premiumManager.shouldShowPaywall(currentQuestCount: 10))
        XCTAssertTrue(premiumManager.shouldShowPaywall(currentQuestCount: 15))
    }
    
    @MainActor
    func testPremiumUserShouldNotShowPaywall() {
        // Simulate premium user
        premiumManager.isPremium = true
        
        XCTAssertFalse(premiumManager.shouldShowPaywall(currentQuestCount: 0))
        XCTAssertFalse(premiumManager.shouldShowPaywall(currentQuestCount: 10))
        XCTAssertFalse(premiumManager.shouldShowPaywall(currentQuestCount: 100))
        
        // Reset for other tests
        premiumManager.isPremium = false
    }
}
