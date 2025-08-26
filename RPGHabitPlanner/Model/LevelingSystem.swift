//
//  LevelingSystem.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 27.07.2025.
//

import Foundation

/// Manages the leveling system with progressive experience requirements
/// Level 2 requires 50 XP, Level 3 requires 60 XP, Level 4 requires 70 XP, etc.
final class LevelingSystem {
    static let shared = LevelingSystem()
    
    private init() {}
    
    // MARK: - Level Requirements
    
    /// Calculates the experience required to reach a specific level
    /// - Parameter level: The target level
    /// - Returns: Total experience required to reach that level
    func experienceRequiredForLevel(_ level: Int) -> Int {
        guard level > 1 else { return 0 }
        
        // Level 2 requires 50 XP, each subsequent level adds 10 more XP
        // Level 2: 50 XP
        // Level 3: 50 + 60 = 110 XP
        // Level 4: 50 + 60 + 70 = 180 XP
        // Level 5: 50 + 60 + 70 + 80 = 260 XP
        // Formula: sum from i=1 to (level-1) of (40 + 10*i)
        
        let levelDifference = level - 1
        return levelDifference * (50 + 5 * (levelDifference - 1))
    }
    
    /// Calculates the experience required for the next level from current level
    /// - Parameter currentLevel: The current level
    /// - Returns: Experience required to reach the next level
    func experienceRequiredForNextLevel(from currentLevel: Int) -> Int {
        guard currentLevel >= 1 else { return 50 }
        
        // For level 1 to 2: 50 XP
        // For level 2 to 3: 60 XP
        // For level 3 to 4: 70 XP
        // Formula: 40 + 10 * currentLevel
        return 40 + 10 * currentLevel
    }
    
    /// Calculates the current level based on total experience
    /// - Parameter totalExperience: Total experience earned
    /// - Returns: Current level
    func calculateLevel(from totalExperience: Int) -> Int {
        guard totalExperience > 0 else { return 1 }
        
        var level = 1
        var requiredExp = 0
        
        while requiredExp <= totalExperience {
            level += 1
            requiredExp = experienceRequiredForLevel(level)
        }
        
        return level - 1
    }
    
    /// Calculates experience progress within current level
    /// - Parameters:
    ///   - totalExperience: Total experience earned
    ///   - currentLevel: Current level
    /// - Returns: Progress as a value between 0.0 and 1.0
    func calculateLevelProgress(totalExperience: Int, currentLevel: Int) -> Double {
        guard currentLevel > 1 else { return 0.0 }
        
        let experienceForCurrentLevel = experienceRequiredForLevel(currentLevel)
        let experienceForNextLevel = experienceRequiredForLevel(currentLevel + 1)
        let experienceInCurrentLevel = totalExperience - experienceForCurrentLevel
        let experienceNeededForNextLevel = experienceForNextLevel - experienceForCurrentLevel
        
        return Double(experienceInCurrentLevel) / Double(experienceNeededForNextLevel)
    }
    
    /// Calculates experience remaining to next level
    /// - Parameters:
    ///   - totalExperience: Total experience earned
    ///   - currentLevel: Current level
    /// - Returns: Experience needed to reach next level
    func experienceToNextLevel(totalExperience: Int, currentLevel: Int) -> Int {
        let experienceForNextLevel = experienceRequiredForLevel(currentLevel + 1)
        return max(0, experienceForNextLevel - totalExperience)
    }
    
    /// Calculates total experience from current level and experience within level
    /// - Parameters:
    ///   - level: Current level
    ///   - experienceInLevel: Experience earned within current level
    /// - Returns: Total experience
    func calculateTotalExperience(level: Int, experienceInLevel: Int) -> Int {
        let experienceForLevel = experienceRequiredForLevel(level)
        return experienceForLevel + experienceInLevel
    }
    
    // MARK: - Level Up Detection
    
    /// Checks if adding experience would result in a level up
    /// - Parameters:
    ///   - currentTotalExperience: Current total experience
    ///   - additionalExperience: Experience to add
    /// - Returns: Tuple with (willLevelUp, newLevel, newTotalExperience)
    func willLevelUp(currentTotalExperience: Int, additionalExperience: Int) -> (willLevelUp: Bool, newLevel: Int, newTotalExperience: Int) {
        let currentLevel = calculateLevel(from: currentTotalExperience)
        let newTotalExperience = currentTotalExperience + additionalExperience
        let newLevel = calculateLevel(from: newTotalExperience)
        
        let willLevelUp = newLevel > currentLevel
        return (willLevelUp, newLevel, newTotalExperience)
    }
    
    /// Calculates how many levels would be gained from adding experience
    /// - Parameters:
    ///   - currentTotalExperience: Current total experience
    ///   - additionalExperience: Experience to add
    /// - Returns: Number of levels gained
    func levelsGained(currentTotalExperience: Int, additionalExperience: Int) -> Int {
        let currentLevel = calculateLevel(from: currentTotalExperience)
        let newTotalExperience = currentTotalExperience + additionalExperience
        let newLevel = calculateLevel(from: newTotalExperience)
        
        return newLevel - currentLevel
    }
}

// MARK: - Leveling System Extensions

extension LevelingSystem {
    /// Gets a preview of level requirements for the first 10 levels
    func getLevelRequirementsPreview() -> [(level: Int, experienceRequired: Int)] {
        return (1...10).map { level in
            (level: level, experienceRequired: experienceRequiredForLevel(level))
        }
    }
    
    /// Gets experience requirements for a range of levels
    /// - Parameters:
    ///   - fromLevel: Starting level
    ///   - toLevel: Ending level
    /// - Returns: Array of level requirements
    func getLevelRequirements(from fromLevel: Int, to toLevel: Int) -> [(level: Int, experienceRequired: Int)] {
        return (fromLevel...toLevel).map { level in
            (level: level, experienceRequired: experienceRequiredForLevel(level))
        }
    }
}
