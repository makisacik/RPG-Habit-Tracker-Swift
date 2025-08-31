//
//  LocalizationManagerTests.swift
//  RPGHabitPlannerTests
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import XCTest
@testable import RPGHabitPlanner

final class LocalizationManagerTests: XCTestCase {
    var localizationManager: LocalizationManager!
    
    override func setUpWithError() throws {
        // Clear any saved language preferences before each test
        UserDefaults.standard.removeObject(forKey: "selectedLanguage")
        UserDefaults.standard.removeObject(forKey: "selectedLocale")
        
        // Create a fresh instance for each test
        localizationManager = LocalizationManager.shared
    }
    
    override func tearDownWithError() throws {
        // Clean up after each test
        UserDefaults.standard.removeObject(forKey: "selectedLanguage")
        UserDefaults.standard.removeObject(forKey: "selectedLocale")
    }
    
    func testLanguageDetectionForTurkishDevice() throws {
        // Simulate Turkish device language
        let originalLanguages = Locale.preferredLanguages
        defer {
            // Restore original languages after test
            UserDefaults.standard.set(originalLanguages, forKey: "AppleLanguages")
        }
        
        // Set Turkish as preferred language
        UserDefaults.standard.set(["tr-TR"], forKey: "AppleLanguages")
        
        // Create a new instance to trigger language detection
        let turkishManager = LocalizationManager.shared
        
        // Verify that Turkish is detected and set
        XCTAssertEqual(turkishManager.currentLanguage, .turkish)
        XCTAssertEqual(turkishManager.currentLocale.identifier, "tr_TR")
    }
    
    func testLanguageDetectionForEnglishDevice() throws {
        // Simulate English device language
        let originalLanguages = Locale.preferredLanguages
        defer {
            // Restore original languages after test
            UserDefaults.standard.set(originalLanguages, forKey: "AppleLanguages")
        }
        
        // Set English as preferred language
        UserDefaults.standard.set(["en-US"], forKey: "AppleLanguages")
        
        // Create a new instance to trigger language detection
        let englishManager = LocalizationManager.shared
        
        // Verify that English is detected and set
        XCTAssertEqual(englishManager.currentLanguage, .english)
        XCTAssertEqual(englishManager.currentLocale.identifier, "en_US")
    }
    
    func testLanguageDetectionForOtherLanguages() throws {
        // Test with various other languages to ensure they default to English
        let testLanguages = ["es-ES", "fr-FR", "de-DE", "ja-JP", "zh-CN"]
        
        for language in testLanguages {
            // Simulate different device language
            let originalLanguages = Locale.preferredLanguages
            defer {
                // Restore original languages after test
                UserDefaults.standard.set(originalLanguages, forKey: "AppleLanguages")
            }
            
            // Set test language as preferred
            UserDefaults.standard.set([language], forKey: "AppleLanguages")
            
            // Create a new instance to trigger language detection
            let testManager = LocalizationManager.shared
            
            // Verify that non-Turkish languages default to English
            XCTAssertEqual(testManager.currentLanguage, .english, "Language \(language) should default to English")
            XCTAssertEqual(testManager.currentLocale.identifier, "en_US", "Language \(language) should use English locale")
        }
    }
    
    func testSavedLanguagePreferenceTakesPriority() throws {
        // First, set a saved language preference
        UserDefaults.standard.set("tr", forKey: "selectedLanguage")
        
        // Then simulate English device language
        let originalLanguages = Locale.preferredLanguages
        defer {
            // Restore original languages after test
            UserDefaults.standard.set(originalLanguages, forKey: "AppleLanguages")
        }
        UserDefaults.standard.set(["en-US"], forKey: "AppleLanguages")
        
        // Create a new instance
        let manager = LocalizationManager.shared
        
        // Verify that saved preference takes priority over device language
        XCTAssertEqual(manager.currentLanguage, .turkish)
        XCTAssertEqual(manager.currentLocale.identifier, "tr_TR")
    }
    
    func testLanguageChangeNotification() throws {
        let expectation = XCTestExpectation(description: "Language change notification")
        
        // Observe language change notifications
        NotificationCenter.default.addObserver(
            forName: .languageChanged,
            object: nil,
            queue: .main
        ) { notification in
            if let newLanguage = notification.object as? LocalizationManager.Language {
                XCTAssertEqual(newLanguage, .turkish)
                expectation.fulfill()
            }
        }
        
        // Change language
        localizationManager.changeLanguage(to: .turkish)
        
        // Wait for notification
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLocalizedStringRetrieval() throws {
        // Test that localized strings are retrieved correctly
        let englishText = localizationManager.localizedString(for: "language_english")
        let turkishText = localizationManager.localizedString(for: "language_turkish")
        
        // Verify that we get actual localized text (not just the key)
        XCTAssertNotEqual(englishText, "language_english")
        XCTAssertNotEqual(turkishText, "language_turkish")
        
        // Verify that we get different text for different languages
        XCTAssertNotEqual(englishText, turkishText)
    }
}
