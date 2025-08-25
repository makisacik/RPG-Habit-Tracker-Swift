//
//  HapticFeedbackManagerTests.swift
//  RPGHabitPlannerTests
//
//  Created by AI Assistant on 2025-01-07.
//

import XCTest
@testable import RPGHabitPlanner

final class HapticFeedbackManagerTests: XCTestCase {
    var hapticManager: HapticFeedbackManager!
    
    override func setUpWithError() throws {
        hapticManager = HapticFeedbackManager.shared
    }
    
    override func tearDownWithError() throws {
        hapticManager = nil
    }
    
    func testHapticFeedbackManagerSingleton() throws {
        // Test that we get the same instance
        let instance1 = HapticFeedbackManager.shared
        let instance2 = HapticFeedbackManager.shared
        XCTAssertEqual(ObjectIdentifier(instance1), ObjectIdentifier(instance2))
    }
    
    func testQuestFeedbackMethods() throws {
        // Test that all quest feedback methods can be called without crashing
        XCTAssertNoThrow(hapticManager.questCompleted())
        XCTAssertNoThrow(hapticManager.questUncompleted())
        XCTAssertNoThrow(hapticManager.questFinished())
    }
    
    func testTaskFeedbackMethods() throws {
        // Test that all task feedback methods can be called without crashing
        XCTAssertNoThrow(hapticManager.taskCompleted())
        XCTAssertNoThrow(hapticManager.taskUncompleted())
    }
    
    func testErrorFeedbackMethod() throws {
        // Test that error feedback method can be called without crashing
        XCTAssertNoThrow(hapticManager.errorOccurred())
    }
    
    func testPrepareFeedbackGenerators() throws {
        // Test that prepare method can be called without crashing
        XCTAssertNoThrow(hapticManager.prepareFeedbackGenerators())
    }
}
