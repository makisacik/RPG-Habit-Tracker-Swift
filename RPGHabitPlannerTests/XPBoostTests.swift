//
//  XPBoostTests.swift
//  RPGHabitPlannerTests
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import XCTest
@testable import RPGHabitPlanner

final class XPBoostTests: XCTestCase {
    var inventoryManager: InventoryManager!
    
    override func setUpWithError() throws {
        super.setUp()
        inventoryManager = InventoryManager.shared
        // Clear any existing effects
        inventoryManager.activeEffects.removeAll()
    }
    
    override func tearDownWithError() throws {
        inventoryManager.activeEffects.removeAll()
        super.tearDown()
    }
    
    func testXPBoostCreation() throws {
        // Test XP boost creation
        let minorBoost = XPBoostItem.minorXPBoost
        XCTAssertEqual(minorBoost.name, "Minor XP Boost")
        XCTAssertEqual(minorBoost.boostMultiplier, 1.25)
        XCTAssertEqual(minorBoost.boostDuration, 30 * 60) // 30 minutes
        
        let legendaryBoost = XPBoostItem.legendaryXPBoost
        XCTAssertEqual(legendaryBoost.name, "Legendary XP Boost")
        XCTAssertEqual(legendaryBoost.boostMultiplier, 3.0)
        XCTAssertEqual(legendaryBoost.boostDuration, 4 * 60 * 60) // 4 hours
    }
    
    func testXPBoostApplication() throws {
        // Test applying XP boost
        let xpBoost = XPBoostItem.xpBoost
        inventoryManager.applyXPBoost(xpBoost)
        
        // Check that effect was added
        XCTAssertEqual(inventoryManager.activeEffects.count, 1)
        
        let activeEffect = inventoryManager.activeEffects.first
        XCTAssertNotNil(activeEffect)
        XCTAssertEqual(activeEffect?.effect.type, .xpBoost)
        XCTAssertEqual(activeEffect?.effect.value, 150) // 1.5 * 100
    }
    
    func testXPBoostMultiplier() throws {
        // Test XP boost multiplier calculation
        XCTAssertEqual(inventoryManager.getXPBoostMultiplier(), 1.0) // No boost initially
        
        let xpBoost = XPBoostItem.greaterXPBoost
        inventoryManager.applyXPBoost(xpBoost)
        
        XCTAssertEqual(inventoryManager.getXPBoostMultiplier(), 2.0) // 100% boost
    }
    
    func testXPBoostReplacement() throws {
        // Test that new XP boost replaces old one
        let minorBoost = XPBoostItem.minorXPBoost
        inventoryManager.applyXPBoost(minorBoost)
        
        XCTAssertEqual(inventoryManager.activeEffects.count, 1)
        XCTAssertEqual(inventoryManager.getXPBoostMultiplier(), 1.25)
        
        let legendaryBoost = XPBoostItem.legendaryXPBoost
        inventoryManager.applyXPBoost(legendaryBoost)
        
        XCTAssertEqual(inventoryManager.activeEffects.count, 1) // Should still be 1
        XCTAssertEqual(inventoryManager.getXPBoostMultiplier(), 3.0) // Should be legendary boost
    }
    
    func testActiveEffectExpiration() throws {
        // Test that effects expire correctly
        let shortBoost = XPBoostItem(
            name: "Test Boost",
            description: "Test",
            iconName: "test",
            boostMultiplier: 1.5,
            boostDuration: 1 // 1 second
        )
        
        inventoryManager.applyXPBoost(shortBoost)
        XCTAssertEqual(inventoryManager.activeEffects.count, 1)
        
        // Wait for effect to expire
        let expectation = XCTestExpectation(description: "Effect expires")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // Effect should be expired by now
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        
        // Check that expired effects are removed
        inventoryManager.updateActiveEffects()
        XCTAssertEqual(inventoryManager.activeEffects.count, 0)
    }
    
    func testItemTypeDetection() throws {
        // Test item type detection
        let healthPotion = ItemEntity()
        healthPotion.name = "Health Potion"
        healthPotion.info = "Restores health"
        healthPotion.iconName = "potion_health"
        
        XCTAssertTrue(inventoryManager.isHealthPotion(healthPotion))
        XCTAssertTrue(inventoryManager.isFunctionalItem(healthPotion))
        XCTAssertFalse(inventoryManager.isCollectibleItem(healthPotion))
        
        let xpBoost = ItemEntity()
        xpBoost.name = "XP Boost"
        xpBoost.info = "Increases XP gain"
        xpBoost.iconName = "icon_xp_boost"
        
        XCTAssertTrue(inventoryManager.isXPBoost(xpBoost))
        XCTAssertTrue(inventoryManager.isFunctionalItem(xpBoost))
        XCTAssertFalse(inventoryManager.isCollectibleItem(xpBoost))
        
        let collectible = ItemEntity()
        collectible.name = "Sword"
        collectible.info = "A weapon"
        collectible.iconName = "icon_sword"
        
        XCTAssertFalse(inventoryManager.isHealthPotion(collectible))
        XCTAssertFalse(inventoryManager.isXPBoost(collectible))
        XCTAssertTrue(inventoryManager.isCollectibleItem(collectible))
        XCTAssertFalse(inventoryManager.isFunctionalItem(collectible))
    }
}
