//
//  LevelingSystemTests.swift
//  RPGHabitPlannerTests
//
//  Created by Mehmet Ali Kısacık on 27.07.2025.
//

import XCTest
@testable import RPGHabitPlanner

final class LevelingSystemTests: XCTestCase {
    var levelingSystem: LevelingSystem!

    override func setUp() {
        super.setUp()
        levelingSystem = LevelingSystem.shared
    }

    override func tearDown() {
        levelingSystem = nil
        super.tearDown()
    }

    // MARK: - Level Requirements Tests

    func testExperienceRequiredForLevel() {
        // Level 1 requires 0 XP (starting level)
        XCTAssertEqual(levelingSystem.experienceRequiredForLevel(1), 0)
        
        // Level 2 requires 50 XP
        XCTAssertEqual(levelingSystem.experienceRequiredForLevel(2), 50)
        
        // Level 3 requires 50 + 60 = 110 XP
        XCTAssertEqual(levelingSystem.experienceRequiredForLevel(3), 110)
        
        // Level 4 requires 50 + 60 + 70 = 180 XP
        XCTAssertEqual(levelingSystem.experienceRequiredForLevel(4), 180)
        
        // Level 5 requires 50 + 60 + 70 + 80 = 260 XP
        XCTAssertEqual(levelingSystem.experienceRequiredForLevel(5), 260)
    }

    func testExperienceRequiredForNextLevel() {
        // From level 1 to 2: 50 XP
        XCTAssertEqual(levelingSystem.experienceRequiredForNextLevel(from: 1), 50)
        
        // From level 2 to 3: 60 XP
        XCTAssertEqual(levelingSystem.experienceRequiredForNextLevel(from: 2), 60)
        
        // From level 3 to 4: 70 XP
        XCTAssertEqual(levelingSystem.experienceRequiredForNextLevel(from: 3), 70)
        
        // From level 4 to 5: 80 XP
        XCTAssertEqual(levelingSystem.experienceRequiredForNextLevel(from: 4), 80)
    }

    // MARK: - Level Calculation Tests

    func testCalculateLevel() {
        // 0 XP = Level 1
        XCTAssertEqual(levelingSystem.calculateLevel(from: 0), 1)
        
        // 25 XP = Level 1 (not enough for level 2)
        XCTAssertEqual(levelingSystem.calculateLevel(from: 25), 1)
        
        // 50 XP = Level 2
        XCTAssertEqual(levelingSystem.calculateLevel(from: 50), 2)
        
        // 100 XP = Level 2 (not enough for level 3)
        XCTAssertEqual(levelingSystem.calculateLevel(from: 100), 2)
        
        // 110 XP = Level 3
        XCTAssertEqual(levelingSystem.calculateLevel(from: 110), 3)
        
        // 180 XP = Level 4
        XCTAssertEqual(levelingSystem.calculateLevel(from: 180), 4)
        
        // 260 XP = Level 5
        XCTAssertEqual(levelingSystem.calculateLevel(from: 260), 5)
    }

    // MARK: - Progress Calculation Tests

    func testCalculateLevelProgress() {
        // Level 1 with 0 XP progress (0/50 = 0.0)
        XCTAssertEqual(levelingSystem.calculateLevelProgress(totalExperience: 0, currentLevel: 1), 0.0)

        // Level 1 with 25 XP progress (25/50 = 0.5)
        XCTAssertEqual(levelingSystem.calculateLevelProgress(totalExperience: 25, currentLevel: 1), 0.5)

        // Level 1 with 50 XP progress (50/50 = 1.0)
        XCTAssertEqual(levelingSystem.calculateLevelProgress(totalExperience: 50, currentLevel: 1), 1.0)

        // Level 2 with 25 XP progress (25/60 = 0.417)
        XCTAssertEqual(levelingSystem.calculateLevelProgress(totalExperience: 75, currentLevel: 2), 25.0 / 60.0)

        // Level 2 with 60 XP progress (60/60 = 1.0)
        XCTAssertEqual(levelingSystem.calculateLevelProgress(totalExperience: 110, currentLevel: 2), 1.0)

        // Level 3 with 30 XP progress (30/70 = 0.429)
        XCTAssertEqual(levelingSystem.calculateLevelProgress(totalExperience: 140, currentLevel: 3), 30.0 / 70.0)
    }

    func testExperienceToNextLevel() {
        // Level 1 with 0 XP: need 50 XP to reach level 2
        XCTAssertEqual(levelingSystem.experienceToNextLevel(totalExperience: 0, currentLevel: 1), 50)
        
        // Level 1 with 25 XP: need 25 XP to reach level 2
        XCTAssertEqual(levelingSystem.experienceToNextLevel(totalExperience: 25, currentLevel: 1), 25)
        
        // Level 2 with 0 XP: need 60 XP to reach level 3
        XCTAssertEqual(levelingSystem.experienceToNextLevel(totalExperience: 50, currentLevel: 2), 60)
        
        // Level 2 with 30 XP: need 30 XP to reach level 3
        XCTAssertEqual(levelingSystem.experienceToNextLevel(totalExperience: 80, currentLevel: 2), 30)
    }

    // MARK: - Total Experience Calculation Tests

    func testCalculateTotalExperience() {
        // Level 1 with 0 XP in level = 0 total
        XCTAssertEqual(levelingSystem.calculateTotalExperience(level: 1, experienceInLevel: 0), 0)
        
        // Level 1 with 25 XP in level = 25 total
        XCTAssertEqual(levelingSystem.calculateTotalExperience(level: 1, experienceInLevel: 25), 25)
        
        // Level 2 with 0 XP in level = 50 total (50 XP required for level 2)
        XCTAssertEqual(levelingSystem.calculateTotalExperience(level: 2, experienceInLevel: 0), 50)
        
        // Level 2 with 30 XP in level = 80 total (50 + 30)
        XCTAssertEqual(levelingSystem.calculateTotalExperience(level: 2, experienceInLevel: 30), 80)
        
        // Level 3 with 0 XP in level = 110 total (50 + 60)
        XCTAssertEqual(levelingSystem.calculateTotalExperience(level: 3, experienceInLevel: 0), 110)
    }

    // MARK: - Level Up Detection Tests

    func testWillLevelUp() {
        // 25 XP added to 0 XP: will level up to level 2
        let result1 = levelingSystem.willLevelUp(currentTotalExperience: 0, additionalExperience: 25)
        XCTAssertFalse(result1.willLevelUp)
        XCTAssertEqual(result1.newLevel, 1)
        XCTAssertEqual(result1.newTotalExperience, 25)
        
        // 50 XP added to 0 XP: will level up to level 2
        let result2 = levelingSystem.willLevelUp(currentTotalExperience: 0, additionalExperience: 50)
        XCTAssertTrue(result2.willLevelUp)
        XCTAssertEqual(result2.newLevel, 2)
        XCTAssertEqual(result2.newTotalExperience, 50)
        
        // 110 XP added to 0 XP: will level up to level 3
        let result3 = levelingSystem.willLevelUp(currentTotalExperience: 0, additionalExperience: 110)
        XCTAssertTrue(result3.willLevelUp)
        XCTAssertEqual(result3.newLevel, 3)
        XCTAssertEqual(result3.newTotalExperience, 110)
    }

    func testLevelsGained() {
        // 25 XP: no levels gained
        XCTAssertEqual(levelingSystem.levelsGained(currentTotalExperience: 0, additionalExperience: 25), 0)
        
        // 50 XP: 1 level gained
        XCTAssertEqual(levelingSystem.levelsGained(currentTotalExperience: 0, additionalExperience: 50), 1)
        
        // 110 XP: 2 levels gained
        XCTAssertEqual(levelingSystem.levelsGained(currentTotalExperience: 0, additionalExperience: 110), 2)
        
        // 180 XP: 3 levels gained
        XCTAssertEqual(levelingSystem.levelsGained(currentTotalExperience: 0, additionalExperience: 180), 3)
    }

    // MARK: - Preview Tests

    func testGetLevelRequirementsPreview() {
        let preview = levelingSystem.getLevelRequirementsPreview()
        
        XCTAssertEqual(preview.count, 10)
        
        // Check first few levels
        XCTAssertEqual(preview[0].level, 1)
        XCTAssertEqual(preview[0].experienceRequired, 0)
        
        XCTAssertEqual(preview[1].level, 2)
        XCTAssertEqual(preview[1].experienceRequired, 50)
        
        XCTAssertEqual(preview[2].level, 3)
        XCTAssertEqual(preview[2].experienceRequired, 110)
        
        XCTAssertEqual(preview[3].level, 4)
        XCTAssertEqual(preview[3].experienceRequired, 180)
    }

    func testGetLevelRequirements() {
        let requirements = levelingSystem.getLevelRequirements(from: 2, to: 5)
        
        XCTAssertEqual(requirements.count, 4)
        
        XCTAssertEqual(requirements[0].level, 2)
        XCTAssertEqual(requirements[0].experienceRequired, 50)
        
        XCTAssertEqual(requirements[1].level, 3)
        XCTAssertEqual(requirements[1].experienceRequired, 110)
        
        XCTAssertEqual(requirements[2].level, 4)
        XCTAssertEqual(requirements[2].experienceRequired, 180)
        
        XCTAssertEqual(requirements[3].level, 5)
        XCTAssertEqual(requirements[3].experienceRequired, 260)
    }
}
