//
//  ActiveEffectsPersistenceTests.swift
//  RPGHabitPlannerTests
//
//  Created by Mehmet Ali Kısacık on 18.08.2025.
//

import XCTest
import CoreData
@testable import RPGHabitPlanner

final class ActiveEffectsPersistenceTests: XCTestCase {
    var persistenceController: PersistenceController!
    var activeEffectsService: ActiveEffectsCoreDataService!
    var inventoryManager: InventoryManager!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Create in-memory Core Data stack for testing
        persistenceController = PersistenceController(inMemory: true)
        activeEffectsService = ActiveEffectsCoreDataService(container: persistenceController.container)
        
        // Use the shared InventoryManager instance but clear any existing effects
        inventoryManager = InventoryManager.shared
        inventoryManager.clearAllEffects()
    }
    
    override func tearDownWithError() throws {
        // Clean up
        activeEffectsService.clearAllEffects()
        persistenceController = nil
        activeEffectsService = nil
        inventoryManager = nil
        
        try super.tearDownWithError()
    }
    
    func testSaveAndLoadActiveEffect() throws {
        // Create a test XP boost effect
        let effect = ItemEffect(
            type: .xpBoost,
            value: 25,
            duration: 1800, // 30 minutes
            isPercentage: true
        )
        
        let activeEffect = ActiveEffect(
            effect: effect,
            sourceItemId: UUID(),
            duration: 1800
        )
        
        // Save the effect
        activeEffectsService.saveActiveEffect(activeEffect)
        
        // Load effects from persistence
        let loadedEffects = activeEffectsService.fetchActiveEffects()
        
        // Verify the effect was saved and loaded
        XCTAssertEqual(loadedEffects.count, 1, "Should have loaded 1 effect")
        
        let loadedEffect = loadedEffects.first
        XCTAssertNotNil(loadedEffect, "Loaded effect should not be nil")
        XCTAssertEqual(loadedEffect?.effect.type, .xpBoost, "Effect type should match")
        XCTAssertEqual(loadedEffect?.effect.value, 25, "Effect value should match")
        XCTAssertEqual(loadedEffect?.effect.isPercentage, true, "Effect isPercentage should match")
        XCTAssertEqual(loadedEffect?.sourceItemId, activeEffect.sourceItemId, "Source item ID should match")
    }
    
    func testClearExpiredEffects() throws {
        // Create an expired effect (end time in the past)
        let effect = ItemEffect(
            type: .coinBoost,
            value: 50,
            duration: 3600, // 1 hour
            isPercentage: true
        )
        
        let expiredEffect = ActiveEffect(
            id: UUID(),
            effect: effect,
            startTime: Date().addingTimeInterval(-7200), // Started 2 hours ago
            endTime: Date().addingTimeInterval(-3600), // Expired 1 hour ago
            sourceItemId: UUID()
        )
        
        // Save the expired effect
        activeEffectsService.saveActiveEffect(expiredEffect)
        
        // Verify it was saved by checking the raw Core Data count
        let request: NSFetchRequest<ActiveEffectEntity> = ActiveEffectEntity.fetchRequest()
        let rawCount = try persistenceController.container.viewContext.count(for: request)
        XCTAssertEqual(rawCount, 1, "Should have 1 effect in Core Data before cleanup")
        
        // Clear expired effects
        activeEffectsService.clearExpiredEffects()
        
        // Verify expired effect was removed
        let finalCount = try persistenceController.container.viewContext.count(for: request)
        XCTAssertEqual(finalCount, 0, "Should have 0 effects in Core Data after cleanup")
    }
    
    func testRemoveSpecificEffect() throws {
        // Create a test effect
        let effect = ItemEffect(
            type: .xpBoost,
            value: 100,
            duration: 1800,
            isPercentage: true
        )
        
        let activeEffect = ActiveEffect(
            effect: effect,
            sourceItemId: UUID(),
            duration: 1800
        )
        
        // Save the effect
        activeEffectsService.saveActiveEffect(activeEffect)
        
        // Verify it was saved
        var loadedEffects = activeEffectsService.fetchActiveEffects()
        XCTAssertEqual(loadedEffects.count, 1, "Should have 1 effect before removal")
        
        // Remove the specific effect
        activeEffectsService.removeActiveEffect(activeEffect)
        
        // Verify it was removed
        loadedEffects = activeEffectsService.fetchActiveEffects()
        XCTAssertEqual(loadedEffects.count, 0, "Should have 0 effects after removal")
    }
    
    func testInventoryManagerPersistence() throws {
        // Create a test effect
        let effect = ItemEffect(
            type: .coinBoost,
            value: 75,
            duration: 900, // 15 minutes
            isPercentage: true
        )
        
        let activeEffect = ActiveEffect(
            effect: effect,
            sourceItemId: UUID(),
            duration: 900
        )
        
        // Add effect through InventoryManager
        inventoryManager.addActiveEffect(activeEffect)
        
        // Verify effect is in memory
        XCTAssertEqual(inventoryManager.activeEffects.count, 1, "Should have 1 effect in memory")
        
        // Create a new InventoryManager instance to simulate app restart
        let newInventoryManager = InventoryManager.shared
        
        // Load effects from persistence
        newInventoryManager.loadActiveEffectsFromPersistence()
        
        // Verify effect was loaded from persistence
        XCTAssertEqual(newInventoryManager.activeEffects.count, 1, "Should have loaded 1 effect from persistence")
        
        let loadedEffect = newInventoryManager.activeEffects.first
        XCTAssertNotNil(loadedEffect, "Loaded effect should not be nil")
        XCTAssertEqual(loadedEffect?.effect.type, .coinBoost, "Effect type should match")
        XCTAssertEqual(loadedEffect?.effect.value, 75, "Effect value should match")
    }
    
    func testBoosterManagerIntegration() throws {
        // Create a test XP boost effect
        let effect = ItemEffect(
            type: .xpBoost,
            value: 50,
            duration: 1800,
            isPercentage: true
        )
        
        let activeEffect = ActiveEffect(
            effect: effect,
            sourceItemId: UUID(),
            duration: 1800
        )
        
        // Add effect through InventoryManager
        inventoryManager.addActiveEffect(activeEffect)
        
        // Refresh boosters
        BoosterManager.shared.refreshBoostersFromPersistence()
        
        // Verify booster was created
        let activeBoosters = BoosterManager.shared.activeBoosters
        let itemBoosters = activeBoosters.filter { $0.source == .item }
        
        XCTAssertEqual(itemBoosters.count, 1, "Should have 1 item booster")
        
        let booster = itemBoosters.first
        XCTAssertNotNil(booster, "Booster should not be nil")
        XCTAssertEqual(booster?.type, .experience, "Booster type should be experience")
        XCTAssertEqual(booster?.multiplier, 1.5, "Booster multiplier should be 1.5 (1.0 + 0.5)")
    }
}
