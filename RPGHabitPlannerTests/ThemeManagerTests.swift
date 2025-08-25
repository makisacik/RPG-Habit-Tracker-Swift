//
//  ThemeManagerTests.swift
//  RPGHabitPlannerTests
//
//  Created by Mehmet Ali Kısacık on 26.08.2025.
//

import XCTest
@testable import RPGHabitPlanner

final class ThemeManagerTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Clear UserDefaults to simulate a fresh app install
        UserDefaults.standard.removeObject(forKey: "selectedTheme")
    }
    
    override func tearDown() {
        // Clean up after tests
        UserDefaults.standard.removeObject(forKey: "selectedTheme")
        super.tearDown()
    }
    
    func testDefaultThemeIsDarkForNewUsers() {
        // Given: A fresh app install (no saved theme preference)
        UserDefaults.standard.removeObject(forKey: "selectedTheme")
        
        // When: Creating a new ThemeManager instance
        let themeManager = ThemeManager.shared
        
        // Then: The default theme should be dark
        XCTAssertEqual(themeManager.currentTheme, .dark)
        XCTAssertEqual(themeManager.forcedColorScheme, .dark)
    }
    
    func testExistingUserPreferencesArePreserved() {
        // Given: An existing user who has set their theme preference
        UserDefaults.standard.set(AppTheme.light.rawValue, forKey: "selectedTheme")
        
        // When: Creating a new ThemeManager instance
        let themeManager = ThemeManager.shared
        
        // Then: The saved preference should be preserved
        XCTAssertEqual(themeManager.currentTheme, .light)
        XCTAssertEqual(themeManager.forcedColorScheme, .light)
    }
    
    func testSystemThemeIsPreserved() {
        // Given: An existing user who has set their theme to system
        UserDefaults.standard.set(AppTheme.system.rawValue, forKey: "selectedTheme")
        
        // When: Creating a new ThemeManager instance
        let themeManager = ThemeManager.shared
        
        // Then: The system preference should be preserved
        XCTAssertEqual(themeManager.currentTheme, .system)
        XCTAssertNil(themeManager.forcedColorScheme)
    }
    
    func testThemeChangeIsSaved() {
        // Given: A fresh ThemeManager
        let themeManager = ThemeManager.shared
        
        // When: Changing the theme to light
        themeManager.setTheme(.light)
        
        // Then: The preference should be saved
        XCTAssertEqual(UserDefaults.standard.string(forKey: "selectedTheme"), AppTheme.light.rawValue)
        XCTAssertEqual(themeManager.currentTheme, .light)
        XCTAssertEqual(themeManager.forcedColorScheme, .light)
    }
}
