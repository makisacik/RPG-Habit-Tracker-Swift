import XCTest
@testable import RPGHabitPlanner

final class LevelingSystemComprehensiveTests: XCTestCase {
    var levelingSystem: LevelingSystem!
    
    override func setUpWithError() throws {
        levelingSystem = LevelingSystem.shared
    }
    
    override func tearDownWithError() throws {
        levelingSystem = nil
    }
    
    // MARK: - Experience Required For Level Tests
    
    func testExperienceRequiredForLevel() throws {
        // Test the formula: sum from i=1 to (level-1) of (40 + 10*i)
        
        // Level 1: 0 XP (guard clause)
        XCTAssertEqual(levelingSystem.experienceRequiredForLevel(1), 0)
        
        // Level 2: i=1, so 40 + 10*1 = 50 XP
        XCTAssertEqual(levelingSystem.experienceRequiredForLevel(2), 50)
        
        // Level 3: i=1,2, so (40+10*1) + (40+10*2) = 50 + 60 = 110 XP
        XCTAssertEqual(levelingSystem.experienceRequiredForLevel(3), 110)
        
        // Level 4: i=1,2,3, so (40+10*1) + (40+10*2) + (40+10*3) = 50 + 60 + 70 = 180 XP
        XCTAssertEqual(levelingSystem.experienceRequiredForLevel(4), 180)
        
        // Level 5: i=1,2,3,4, so (40+10*1) + (40+10*2) + (40+10*3) + (40+10*4) = 50 + 60 + 70 + 80 = 260 XP
        XCTAssertEqual(levelingSystem.experienceRequiredForLevel(5), 260)
        
        // Level 6: 50 + 60 + 70 + 80 + 90 = 350 XP
        XCTAssertEqual(levelingSystem.experienceRequiredForLevel(6), 350)
        
        // Level 10: 50 + 60 + 70 + 80 + 90 + 100 + 110 + 120 + 130 = 810 XP
        XCTAssertEqual(levelingSystem.experienceRequiredForLevel(10), 810)
    }
    
    // MARK: - Experience Required For Next Level Tests
    
    func testExperienceRequiredForNextLevel() throws {
        // Formula: 40 + 10 * currentLevel
        
        // From level 1 to 2: 40 + 10*1 = 50 XP
        XCTAssertEqual(levelingSystem.experienceRequiredForNextLevel(from: 1), 50)
        
        // From level 2 to 3: 40 + 10*2 = 60 XP
        XCTAssertEqual(levelingSystem.experienceRequiredForNextLevel(from: 2), 60)
        
        // From level 3 to 4: 40 + 10*3 = 70 XP
        XCTAssertEqual(levelingSystem.experienceRequiredForNextLevel(from: 3), 70)
        
        // From level 5 to 6: 40 + 10*5 = 90 XP
        XCTAssertEqual(levelingSystem.experienceRequiredForNextLevel(from: 5), 90)
        
        // From level 10 to 11: 40 + 10*10 = 140 XP
        XCTAssertEqual(levelingSystem.experienceRequiredForNextLevel(from: 10), 140)
    }
    
    // MARK: - Calculate Level From Total Experience Tests
    
    func testCalculateLevelFromTotalExperience() throws {
        // 0 XP = Level 1
        XCTAssertEqual(levelingSystem.calculateLevel(from: 0), 1)
        
        // 25 XP = Level 1 (not enough for level 2)
        XCTAssertEqual(levelingSystem.calculateLevel(from: 25), 1)
        
        // 50 XP = Level 2 (exactly enough for level 2)
        XCTAssertEqual(levelingSystem.calculateLevel(from: 50), 2)
        
        // 75 XP = Level 2 (more than level 2, but not enough for level 3)
        XCTAssertEqual(levelingSystem.calculateLevel(from: 75), 2)
        
        // 110 XP = Level 3 (exactly enough for level 3)
        XCTAssertEqual(levelingSystem.calculateLevel(from: 110), 3)
        
        // 180 XP = Level 4 (exactly enough for level 4)
        XCTAssertEqual(levelingSystem.calculateLevel(from: 180), 4)
        
        // 260 XP = Level 5 (exactly enough for level 5)
        XCTAssertEqual(levelingSystem.calculateLevel(from: 260), 5)
        
        // 350 XP = Level 6 (exactly enough for level 6)
        XCTAssertEqual(levelingSystem.calculateLevel(from: 350), 6)
    }
    
    // MARK: - Calculate Level Progress Tests
    
    func testCalculateLevelProgress() throws {
        // Level 1 should always return 0.0
        XCTAssertEqual(levelingSystem.calculateLevelProgress(totalExperience: 0, currentLevel: 1), 0.0, accuracy: 0.001)
        XCTAssertEqual(levelingSystem.calculateLevelProgress(totalExperience: 25, currentLevel: 1), 0.0, accuracy: 0.001)
        
        // Level 2 with 25 XP progress (25/60 = 0.4167)
        let level2Progress = levelingSystem.calculateLevelProgress(totalExperience: 75, currentLevel: 2)
        XCTAssertEqual(level2Progress, 25.0 / 60.0, accuracy: 0.001)
        
        // Level 2 with 50 XP progress (50/60 = 0.8333)
        let level2Progress2 = levelingSystem.calculateLevelProgress(totalExperience: 100, currentLevel: 2)
        XCTAssertEqual(level2Progress2, 50.0 / 60.0, accuracy: 0.001)
        
        // Level 3 with 35 XP progress (35/70 = 0.5)
        let level3Progress = levelingSystem.calculateLevelProgress(totalExperience: 145, currentLevel: 3)
        XCTAssertEqual(level3Progress, 35.0 / 70.0, accuracy: 0.001)
        
        // Level 4 with 0 XP progress (just reached level 4)
        XCTAssertEqual(levelingSystem.calculateLevelProgress(totalExperience: 180, currentLevel: 4), 0.0, accuracy: 0.001)
        
        // Level 4 with 40 XP progress (40/80 = 0.5)
        let level4Progress = levelingSystem.calculateLevelProgress(totalExperience: 220, currentLevel: 4)
        XCTAssertEqual(level4Progress, 40.0 / 80.0, accuracy: 0.001)
    }
    
    // MARK: - Experience To Next Level Tests
    
    func testExperienceToNextLevel() throws {
        // Level 1 with 0 XP: need 50 XP for level 2
        XCTAssertEqual(levelingSystem.experienceToNextLevel(totalExperience: 0, currentLevel: 1), 50)
        
        // Level 1 with 25 XP: need 25 more XP for level 2
        XCTAssertEqual(levelingSystem.experienceToNextLevel(totalExperience: 25, currentLevel: 1), 25)
        
        // Level 2 with 50 XP: need 60 XP for level 3
        XCTAssertEqual(levelingSystem.experienceToNextLevel(totalExperience: 50, currentLevel: 2), 60)
        
        // Level 2 with 75 XP: need 35 more XP for level 3
        XCTAssertEqual(levelingSystem.experienceToNextLevel(totalExperience: 75, currentLevel: 2), 35)
        
        // Level 3 with 110 XP: need 70 XP for level 4
        XCTAssertEqual(levelingSystem.experienceToNextLevel(totalExperience: 110, currentLevel: 3), 70)
        
        // Level 4 with 180 XP: need 80 XP for level 5
        XCTAssertEqual(levelingSystem.experienceToNextLevel(totalExperience: 180, currentLevel: 4), 80)
    }
    
    // MARK: - Calculate Total Experience Tests
    
    func testCalculateTotalExperience() throws {
        // Level 1 with 0 XP = 0 total
        XCTAssertEqual(levelingSystem.calculateTotalExperience(level: 1, experienceInLevel: 0), 0)
        
        // Level 1 with 25 XP = 25 total
        XCTAssertEqual(levelingSystem.calculateTotalExperience(level: 1, experienceInLevel: 25), 25)
        
        // Level 2 with 0 XP = 50 total (level 2 requirement)
        XCTAssertEqual(levelingSystem.calculateTotalExperience(level: 2, experienceInLevel: 0), 50)
        
        // Level 2 with 30 XP = 80 total (50 + 30)
        XCTAssertEqual(levelingSystem.calculateTotalExperience(level: 2, experienceInLevel: 30), 80)
        
        // Level 3 with 0 XP = 110 total (level 3 requirement)
        XCTAssertEqual(levelingSystem.calculateTotalExperience(level: 3, experienceInLevel: 0), 110)
        
        // Level 3 with 35 XP = 145 total (110 + 35)
        XCTAssertEqual(levelingSystem.calculateTotalExperience(level: 3, experienceInLevel: 35), 145)
        
        // Level 4 with 0 XP = 180 total (level 4 requirement)
        XCTAssertEqual(levelingSystem.calculateTotalExperience(level: 4, experienceInLevel: 0), 180)
    }
    
    // MARK: - Will Level Up Tests
    
    func testWillLevelUp() throws {
        // Level 1 with 0 XP, adding 25 XP = no level up
        let result1 = levelingSystem.willLevelUp(currentTotalExperience: 0, additionalExperience: 25)
        XCTAssertFalse(result1.willLevelUp)
        XCTAssertEqual(result1.newLevel, 1)
        XCTAssertEqual(result1.newTotalExperience, 25)
        
        // Level 1 with 0 XP, adding 50 XP = level up to 2
        let result2 = levelingSystem.willLevelUp(currentTotalExperience: 0, additionalExperience: 50)
        XCTAssertTrue(result2.willLevelUp)
        XCTAssertEqual(result2.newLevel, 2)
        XCTAssertEqual(result2.newTotalExperience, 50)
        
        // Level 1 with 0 XP, adding 110 XP = level up to 3
        let result3 = levelingSystem.willLevelUp(currentTotalExperience: 0, additionalExperience: 110)
        XCTAssertTrue(result3.willLevelUp)
        XCTAssertEqual(result3.newLevel, 3)
        XCTAssertEqual(result3.newTotalExperience, 110)
        
        // Level 2 with 50 XP, adding 30 XP = no level up
        let result4 = levelingSystem.willLevelUp(currentTotalExperience: 50, additionalExperience: 30)
        XCTAssertFalse(result4.willLevelUp)
        XCTAssertEqual(result4.newLevel, 2)
        XCTAssertEqual(result4.newTotalExperience, 80)
        
        // Level 2 with 50 XP, adding 60 XP = level up to 3
        let result5 = levelingSystem.willLevelUp(currentTotalExperience: 50, additionalExperience: 60)
        XCTAssertTrue(result5.willLevelUp)
        XCTAssertEqual(result5.newLevel, 3)
        XCTAssertEqual(result5.newTotalExperience, 110)
    }
    
    // MARK: - Levels Gained Tests
    
    func testLevelsGained() throws {
        // Level 1 with 0 XP, adding 25 XP = 0 levels gained
        XCTAssertEqual(levelingSystem.levelsGained(currentTotalExperience: 0, additionalExperience: 25), 0)
        
        // Level 1 with 0 XP, adding 50 XP = 1 level gained
        XCTAssertEqual(levelingSystem.levelsGained(currentTotalExperience: 0, additionalExperience: 50), 1)
        
        // Level 1 with 0 XP, adding 110 XP = 2 levels gained
        XCTAssertEqual(levelingSystem.levelsGained(currentTotalExperience: 0, additionalExperience: 110), 2)
        
        // Level 1 with 0 XP, adding 180 XP = 3 levels gained
        XCTAssertEqual(levelingSystem.levelsGained(currentTotalExperience: 0, additionalExperience: 180), 3)
        
        // Level 2 with 50 XP, adding 30 XP = 0 levels gained
        XCTAssertEqual(levelingSystem.levelsGained(currentTotalExperience: 50, additionalExperience: 30), 0)
        
        // Level 2 with 50 XP, adding 60 XP = 1 level gained
        XCTAssertEqual(levelingSystem.levelsGained(currentTotalExperience: 50, additionalExperience: 60), 1)
        
        // Level 2 with 50 XP, adding 130 XP = 2 levels gained (to level 4)
        XCTAssertEqual(levelingSystem.levelsGained(currentTotalExperience: 50, additionalExperience: 130), 2)
    }
    
    // MARK: - Integration Tests
    
    func testLevelingSystemIntegration() throws {
        // Simulate a user starting at level 1 with 0 XP
        var totalExperience = 0
        var currentLevel = 1
        
        // Add 25 XP - should stay at level 1
        totalExperience += 25
        currentLevel = levelingSystem.calculateLevel(from: totalExperience)
        XCTAssertEqual(currentLevel, 1)
        
        // Add 25 more XP (total 50) - should reach level 2
        totalExperience += 25
        currentLevel = levelingSystem.calculateLevel(from: totalExperience)
        XCTAssertEqual(currentLevel, 2)
        
        // Add 30 XP (total 80) - should stay at level 2
        totalExperience += 30
        currentLevel = levelingSystem.calculateLevel(from: totalExperience)
        XCTAssertEqual(currentLevel, 2)
        
        // Add 30 more XP (total 110) - should reach level 3
        totalExperience += 30
        currentLevel = levelingSystem.calculateLevel(from: totalExperience)
        XCTAssertEqual(currentLevel, 3)
        
        // Add 35 XP (total 145) - should stay at level 3
        totalExperience += 35
        currentLevel = levelingSystem.calculateLevel(from: totalExperience)
        XCTAssertEqual(currentLevel, 3)
        
        // Add 35 more XP (total 180) - should reach level 4
        totalExperience += 35
        currentLevel = levelingSystem.calculateLevel(from: totalExperience)
        XCTAssertEqual(currentLevel, 4)
    }
    
    // MARK: - Edge Cases Tests
    
    func testEdgeCases() throws {
        // Negative experience should be handled gracefully
        XCTAssertEqual(levelingSystem.calculateLevel(from: -10), 1)
        XCTAssertEqual(levelingSystem.calculateLevelProgress(totalExperience: -10, currentLevel: 1), 0.0, accuracy: 0.001)
        
        // Zero experience edge cases
        XCTAssertEqual(levelingSystem.experienceRequiredForLevel(0), 0) // Should handle gracefully
        XCTAssertEqual(levelingSystem.experienceRequiredForNextLevel(from: 0), 50) // Should default to 50
        
        // Very high levels (stress test)
        XCTAssertGreaterThan(levelingSystem.experienceRequiredForLevel(100), 0)
        XCTAssertGreaterThan(levelingSystem.experienceRequiredForNextLevel(from: 100), 0)
        
        // Progress should never exceed 1.0
        let highProgress = levelingSystem.calculateLevelProgress(totalExperience: 1000, currentLevel: 2)
        XCTAssertLessThanOrEqual(highProgress, 1.0)
    }
    
    // MARK: - Performance Tests
    
    func testPerformance() throws {
        // Test performance of level calculation for high levels
        measure {
            _ = levelingSystem.calculateLevel(from: 10000)
        }
        
        // Test performance of experience calculation for high levels
        measure {
            _ = levelingSystem.experienceRequiredForLevel(100)
        }
    }
    
    // MARK: - Preview Tests
    
    func testGetLevelRequirementsPreview() throws {
        let preview = levelingSystem.getLevelRequirementsPreview()
        
        // Should return 10 levels
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
        
        XCTAssertEqual(preview[4].level, 5)
        XCTAssertEqual(preview[4].experienceRequired, 260)
    }
    
    func testGetLevelRequirementsRange() throws {
        let requirements = levelingSystem.getLevelRequirements(from: 3, to: 6)
        
        // Should return 4 levels (3, 4, 5, 6)
        XCTAssertEqual(requirements.count, 4)
        
        // Check values
        XCTAssertEqual(requirements[0].level, 3)
        XCTAssertEqual(requirements[0].experienceRequired, 110)
        
        XCTAssertEqual(requirements[1].level, 4)
        XCTAssertEqual(requirements[1].experienceRequired, 180)
        
        XCTAssertEqual(requirements[2].level, 5)
        XCTAssertEqual(requirements[2].experienceRequired, 260)
        
        XCTAssertEqual(requirements[3].level, 6)
        XCTAssertEqual(requirements[3].experienceRequired, 350)
    }
}
