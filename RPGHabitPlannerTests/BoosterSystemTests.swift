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
            source: .item,
            multiplier: 1.5,
            flatBonus: 10,
            sourceId: "xp_boost_item",
            sourceName: "XP Boost Item"
        )

        XCTAssertEqual(booster.type, .experience)
        XCTAssertEqual(booster.source, .item)
        XCTAssertEqual(booster.multiplier, 1.5)
        XCTAssertEqual(booster.flatBonus, 10)
        XCTAssertEqual(booster.sourceId, "xp_boost_item")
        XCTAssertEqual(booster.sourceName, "XP Boost Item")
        XCTAssertTrue(booster.isActive)
        XCTAssertFalse(booster.isExpired)
    }

    func testBoosterEffectDescription() {
        let booster = BoosterEffect(
            type: .coins,
            source: .item,
            multiplier: 1.25,
            flatBonus: 5,
            sourceId: "coin_boost_item",
            sourceName: "Coin Boost Item"
        )

        let description = booster.description
        XCTAssertTrue(description.contains("Coin Boost Item provides"))
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
            source: .item,
            multiplier: 1.5,
            flatBonus: 10,
            sourceId: "xp_boost_item",
            sourceName: "XP Boost Item"
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
            source: .item,
            multiplier: 1.2,
            flatBonus: 5,
            sourceId: "house",
            sourceName: "House"
        )

        let coinBooster = BoosterEffect(
            type: .coins,
            source: .item,
            multiplier: 1.3,
            flatBonus: 3,
            sourceId: "coin_boost_item",
            sourceName: "Coin Boost Item"
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
            source: .item,
            multiplier: 1.2,
            flatBonus: 0,
            sourceId: "xp_boost_item",
            sourceName: "XP Boost Item"
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
        XCTAssertEqual(activeExpBoosters.first?.sourceName, "XP Boost Item")

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

    func testAdditivePercentageCalculation() {
        // Test that multiple boosters add their percentages together instead of multiplying
        let booster1 = BoosterEffect(
            type: .experience,
            source: .item,
            multiplier: 1.2, // 20% boost
            flatBonus: 0,
            sourceId: "xp_boost_item1",
            sourceName: "XP Boost Item 1"
        )

        let booster2 = BoosterEffect(
            type: .experience,
            source: .item,
            multiplier: 1.2, // 20% boost
            flatBonus: 0,
            sourceId: "xp_boost_item2",
            sourceName: "XP Boost Item 2"
        )

        boosterManager.activeBoosters = [booster1, booster2]
        boosterManager.refreshBoosters()

        // With additive percentages: 20% + 20% = 40% boost = 1.4 multiplier
        let (boostedExp, _) = boosterManager.calculateBoostedRewards(baseExperience: 100, baseCoins: 50)
        XCTAssertEqual(boostedExp, 140) // 100 * 1.4 = 140

        // Test coin boosters as well
        let coinBooster1 = BoosterEffect(
            type: .coins,
            source: .item,
            multiplier: 1.15, // 15% boost
            flatBonus: 0,
            sourceId: "coin_boost_item1",
            sourceName: "Coin Boost Item 1"
        )

        let coinBooster2 = BoosterEffect(
            type: .coins,
            source: .item,
            multiplier: 1.25, // 25% boost
            flatBonus: 0,
            sourceId: "coin_boost_item2",
            sourceName: "Coin Boost Item 2"
        )

        boosterManager.activeBoosters = [booster1, booster2, coinBooster1, coinBooster2]
        boosterManager.refreshBoosters()

        // With additive percentages: 15% + 25% = 40% boost = 1.4 multiplier
        let (_, boostedCoins) = boosterManager.calculateBoostedRewards(baseExperience: 100, baseCoins: 50)
        XCTAssertEqual(boostedCoins, 70) // 50 * 1.4 = 70
    }
}
