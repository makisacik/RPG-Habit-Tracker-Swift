//
//  String+Localization.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import Foundation

extension String {
    /// Localizes a string using the current locale from LocalizationManager
    /// - Returns: Localized string or the original key if not found
    var localized: String {
        return LocalizationManager.shared.localizedString(for: self)
    }

    /// Localizes a string with arguments using String format
    /// - Parameter arguments: Arguments to format the string with
    /// - Returns: Localized and formatted string
    func localized(with arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }

    /// Localizes a string with a single argument
    /// - Parameter argument: Single argument to format the string with
    /// - Returns: Localized and formatted string
    func localized(with argument: CVarArg) -> String {
        return String(format: self.localized, argument)
    }

    /// Localizes a string with a dictionary of arguments
    /// - Parameter arguments: Dictionary of key-value pairs for formatting
    /// - Returns: Localized and formatted string
    func localized(with arguments: [String: Any]) -> String {
        var result = self.localized
        for (key, value) in arguments {
            result = result.replacingOccurrences(of: "{\(key)}", with: "\(value)")
        }
        return result
    }

    /// Localizes a string with pluralization support
    /// - Parameter count: The count for pluralization
    /// - Returns: Localized string with proper pluralization
    func localizedPlural(count: Int) -> String {
        let format = NSLocalizedString(self, comment: "")
        return String(format: format, count)
    }

    /// Localizes a string with pluralization and additional arguments
    /// - Parameters:
    ///   - count: The count for pluralization
    ///   - arguments: Additional arguments for formatting
    /// - Returns: Localized string with proper pluralization and formatting
    func localizedPlural(count: Int, with arguments: CVarArg...) -> String {
        let format = NSLocalizedString(self, comment: "")
        let allArguments = [count] + arguments
        return String(format: format, arguments: allArguments)
    }
}
