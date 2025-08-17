//
//  BoosterSystemTests.swift
//  RPGHabitPlannerTests
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import XCTest
@testable import RPGHabitPlanner

final class BoosterSystemTests: XCTestCase {
    var boosterManager: BoosterManager!
    
    override func setUp() {
        super.setUp()
        boosterManager = BoosterManager.shared
    }
    
    override func tearDown() {
        boosterManager = nil
        super.tearDown()
    }
    
    func testBoosterEffectCreation() {
        let booster = BoosterEffect(
            type: .experience,
            source: .building,
            multiplier: 1.5,
            flatBonus: 10,
            sourceId: "castle",
            sourceName: "Castle (Lv.3)"
        )
        
        XCTAssertEqual(booster.type, .experience)
        XCTAssertEqual(booster.source, .building)
        XCTAssertEqual(booster.multiplier, 1.5)
        XCTAssertEqual(booster.flatBonus, 10)
        XCTAssertEqual(booster.sourceId, "castle")
        XCTAssertEqual(booster.sourceName, "Castle (Lv.3)")
        XCTAssertTrue(booster.isActive)
        XCTAssertFalse(booster.isExpired)
    }
    
    func testBoosterEffectDescription() {
        let booster = BoosterEffect(
            type: .coins,
            source: .building,
            multiplier: 1.25,
            flatBonus: 5,
            sourceId: "house",
            sourceName: "House (Lv.2)"
        )
        
        let description = booster.description
        XCTAssertTrue(description.contains("House (Lv.2) provides"))
        XCTAssertTrue(description.contains("+25%"))
        XCTAssertTrue(description.contains("+5"))
        XCTAssertTrue(description.contains("coins"))
    }
    
    func testExpiredBooster() {
        let expiredDate = Date().addingTimeInterval(-3600) // 1 hour ago
        let booster = BoosterEffect(
            type: .experience,
            source: .temporary,
            multiplier: 2.0,
            flatBonus: 0,
            sourceId: "temp",
            sourceName: "Temporary Booster",
            expiresAt: expiredDate
        )
        
        XCTAssertTrue(booster.isExpired)
    }
    
    func testActiveBooster() {
        let futureDate = Date().addingTimeInterval(3600) // 1 hour from now
        let booster = BoosterEffect(
            type: .experience,
            source: .temporary,
            multiplier: 2.0,
            flatBonus: 0,
            sourceId: "temp",
            sourceName: "Temporary Booster",
            expiresAt: futureDate
        )
        
        XCTAssertFalse(booster.isExpired)
    }
    
    func testCalculateBoostedRewards() {
        // Test with no boosters
        let (exp, coins) = boosterManager.calculateBoostedRewards(baseExperience: 100, baseCoins: 50)
        XCTAssertEqual(exp, 100)
        XCTAssertEqual(coins, 50)
        
        // Test with experience booster
        let expBooster = BoosterEffect(
            type: .experience,
            source: .building,
            multiplier: 1.5,
            flatBonus: 10,
            sourceId: "house",
            sourceName: "House"
        )
        boosterManager.activeBoosters = [expBooster]
        boosterManager.refreshBoosters()
        
        let (boostedExp, boostedCoins) = boosterManager.calculateBoostedRewards(baseExperience: 100, baseCoins: 50)
        XCTAssertEqual(boostedExp, 160) // (100 * 1.5) + 10
        XCTAssertEqual(boostedCoins, 50) // No coin booster
    }
    
    func testMultipleBoosters() {
        let expBooster = BoosterEffect(
            type: .experience,
            source: .building,
            multiplier: 1.2,
            flatBonus: 5,
            sourceId: "house",
            sourceName: "House"
        )
        
        let coinBooster = BoosterEffect(
            type: .coins,
            source: .building,
            multiplier: 1.3,
            flatBonus: 3,
            sourceId: "castle",
            sourceName: "Castle"
        )
        
        boosterManager.activeBoosters = [expBooster, coinBooster]
        boosterManager.refreshBoosters()
        
        let (boostedExp, boostedCoins) = boosterManager.calculateBoostedRewards(baseExperience: 100, baseCoins: 50)
        XCTAssertEqual(boostedExp, 125) // (100 * 1.2) + 5
        XCTAssertEqual(boostedCoins, 68) // (50 * 1.3) + 3
    }
    
    func testBothTypeBooster() {
        let bothBooster = BoosterEffect(
            type: .both,
            source: .item,
            multiplier: 1.1,
            flatBonus: 2,
            sourceId: "item",
            sourceName: "Magic Item"
        )
        
        boosterManager.activeBoosters = [bothBooster]
        boosterManager.refreshBoosters()
        
        let (boostedExp, boostedCoins) = boosterManager.calculateBoostedRewards(baseExperience: 100, baseCoins: 50)
        XCTAssertEqual(boostedExp, 112) // (100 * 1.1) + 2
        XCTAssertEqual(boostedCoins, 57) // (50 * 1.1) + 2
    }
    
    func testGetActiveBoosters() {
        let activeBooster = BoosterEffect(
            type: .experience,
            source: .building,
            multiplier: 1.2,
            flatBonus: 0,
            sourceId: "house",
            sourceName: "House"
        )
        
        let expiredBooster = BoosterEffect(
            type: .coins,
            source: .temporary,
            multiplier: 1.5,
            flatBonus: 0,
            sourceId: "temp",
            sourceName: "Expired",
            expiresAt: Date().addingTimeInterval(-3600)
        )
        
        boosterManager.activeBoosters = [activeBooster, expiredBooster]
        
        let activeExpBoosters = boosterManager.getActiveBoosters(for: .experience)
        XCTAssertEqual(activeExpBoosters.count, 1)
        XCTAssertEqual(activeExpBoosters.first?.sourceName, "House")
        
        let activeCoinBoosters = boosterManager.getActiveBoosters(for: .coins)
        XCTAssertEqual(activeCoinBoosters.count, 0) // Expired booster should be filtered out
    }
    
    func testAddTemporaryBooster() {
        boosterManager.addTemporaryBooster(
            type: .experience,
            multiplier: 2.0,
            flatBonus: 20,
            duration: 3600, // 1 hour
            sourceName: "Test Booster"
        )
        
        let activeBoosters = boosterManager.getActiveBoosters(for: .experience)
        XCTAssertEqual(activeBoosters.count, 1)
        
        let booster = activeBoosters.first
        XCTAssertEqual(booster?.type, .experience)
        XCTAssertEqual(booster?.source, .temporary)
        XCTAssertEqual(booster?.multiplier, 2.0)
        XCTAssertEqual(booster?.flatBonus, 20)
        XCTAssertEqual(booster?.sourceName, "Test Booster")
        XCTAssertNotNil(booster?.expiresAt)
    }
}
