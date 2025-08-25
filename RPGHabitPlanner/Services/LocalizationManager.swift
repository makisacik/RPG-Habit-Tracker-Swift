//
//  LocalizationManager.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import Foundation
import SwiftUI

extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
}

/// Manages localization settings and language switching
class LocalizationManager: ObservableObject {
    // MARK: - Singleton
    static let shared = LocalizationManager()

    // MARK: - Published Properties
    @Published var currentLanguage: Language {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "selectedLanguage")
            updateLocale()
        }
    }

    @Published var currentLocale: Locale {
        didSet {
            UserDefaults.standard.set(currentLocale.identifier, forKey: "selectedLocale")
        }
    }

    // MARK: - Available Languages
    enum Language: String, CaseIterable, Identifiable {
        case english = "en"
        // case turkish = "tr"  // Temporarily disabled

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .english:
                return String(localized: "language_english")
            // case .turkish:
            //     return String(localized: "language_turkish")
            }
        }

        var flag: String {
            switch self {
            case .english:
                return "🇺🇸"
            // case .turkish:
            //     return "🇹🇷"
            }
        }

        var locale: Locale {
            switch self {
            case .english:
                return Locale(identifier: "en_US")
            // case .turkish:
            //     return Locale(identifier: "tr_TR")
            }
        }
    }

    // MARK: - Initialization
    private init() {
        // Always default to English for now
        let initialLanguage: Language = .english

        // Initialize stored properties
        self.currentLanguage = initialLanguage

        // Determine the initial locale
        let initialLocale: Locale
        if let savedLocaleId = UserDefaults.standard.string(forKey: "selectedLocale") {
            initialLocale = Locale(identifier: savedLocaleId)
        } else {
            initialLocale = initialLanguage.locale
        }

        self.currentLocale = initialLocale
    }

    // MARK: - Public Methods

    /// Changes the current language
    /// - Parameter language: The new language to set
    func changeLanguage(to language: Language) {
        currentLanguage = language
        currentLocale = language.locale

        // Post notification to trigger UI updates
        NotificationCenter.default.post(name: .languageChanged, object: language)

        // Force UI refresh by updating the object
        objectWillChange.send()
    }

    /// Gets the localized string for a key
    /// - Parameter key: The localization key
    /// - Returns: Localized string
    func localizedString(for key: String) -> String {
        let bundle = Bundle.main

        // Try to get the localized string for the specific locale
        if let languagePath = bundle.path(forResource: currentLocale.language.languageCode?.identifier, ofType: "lproj"),
           let languageBundle = Bundle(path: languagePath) {
            return languageBundle.localizedString(forKey: key, value: key, table: nil)
        }

        // Fallback to default NSLocalizedString
        return NSLocalizedString(key, comment: "")
    }

    /// Gets the localized string with arguments
    /// - Parameters:
    ///   - key: The localization key
    ///   - arguments: Arguments to format the string with
    /// - Returns: Localized and formatted string
    func localizedString(for key: String, with arguments: CVarArg...) -> String {
        let format = NSLocalizedString(key, comment: "")
        return String(format: format, arguments: arguments)
    }

    /// Gets the localized string with a single argument
    /// - Parameters:
    ///   - key: The localization key
    ///   - argument: Single argument to format the string with
    /// - Returns: Localized and formatted string
    func localizedString(for key: String, with argument: CVarArg) -> String {
        let format = NSLocalizedString(key, comment: "")
        return String(format: format, argument)
    }

    /// Gets the localized string with pluralization
    /// - Parameters:
    ///   - key: The localization key
    ///   - count: The count for pluralization
    /// - Returns: Localized string with proper pluralization
    func localizedString(for key: String, plural count: Int) -> String {
        let format = NSLocalizedString(key, comment: "")
        return String(format: format, count)
    }

    /// Formats a date according to the current locale
    /// - Parameters:
    ///   - date: The date to format
    ///   - style: The date formatting style
    /// - Returns: Formatted date string
    func formatDate(_ date: Date, style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.locale = currentLocale
        formatter.dateStyle = style
        return formatter.string(from: date)
    }

    /// Formats a date with custom format
    /// - Parameters:
    ///   - date: The date to format
    ///   - format: The custom date format
    /// - Returns: Formatted date string
    func formatDate(_ date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = currentLocale
        formatter.dateFormat = format
        return formatter.string(from: date)
    }

    /// Formats a number according to the current locale
    /// - Parameters:
    ///   - number: The number to format
    ///   - style: The number formatting style
    /// - Returns: Formatted number string
    func formatNumber(_ number: NSNumber, style: NumberFormatter.Style = .decimal) -> String {
        let formatter = NumberFormatter()
        formatter.locale = currentLocale
        formatter.numberStyle = style
        return formatter.string(from: number) ?? "\(number)"
    }

    /// Formats a number with custom format
    /// - Parameters:
    ///   - number: The number to format
    ///   - format: The custom number format
    /// - Returns: Formatted number string
    func formatNumber(_ number: NSNumber, format: String) -> String {
        let formatter = NumberFormatter()
        formatter.locale = currentLocale
        formatter.positiveFormat = format
        return formatter.string(from: number) ?? "\(number)"
    }

    // MARK: - Private Methods

    private func updateLocale() {
        currentLocale = currentLanguage.locale
    }
}

// MARK: - Environment Key
struct LocalizationManagerKey: EnvironmentKey {
    static let defaultValue = LocalizationManager.shared
}

extension EnvironmentValues {
    var localizationManager: LocalizationManager {
        get { self[LocalizationManagerKey.self] }
        set { self[LocalizationManagerKey.self] = newValue }
    }
}

// MARK: - View Extension
extension View {
    /// Adds the localization manager to the environment
    func withLocalization() -> some View {
        self.environmentObject(LocalizationManager.shared)
    }
}
