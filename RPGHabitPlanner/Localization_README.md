# Localization Guide for RPG Habit Planner

This document explains how to use the localization system implemented in the RPG Habit Planner app.

## Overview

The app supports multiple languages through a comprehensive localization system built with iOS best practices. Currently supported languages:
- English (en)
- Turkish (tr)

## File Structure

```
RPGHabitPlanner/
├── en.lproj/
│   └── Localizable.strings          # English translations
├── tr.lproj/
│   └── Localizable.strings          # Turkish translations
├── Extensions/
│   └── String+Localization.swift    # Localization extensions
└── Services/
    └── LocalizationManager.swift    # Localization management
```

## How to Use Localization

### 1. Basic String Localization

Use the `.localized` property on any string key:

```swift
Text("adventure_hub".localized)
// or
Text(String.adventureHub.localized)
```

### 2. String with Arguments

For strings that need formatting with values:

```swift
// In Localizable.strings
"quest_progress" = "Quest Progress: %d/%d";

// In Swift code
Text("quest_progress".localized(with: completedTasks, totalTasks))
// or
Text(String.localizedString(for: "quest_progress", with: completedTasks, totalTasks))
```

### 3. Pluralization

For strings that change based on count:

```swift
// In Localizable.strings
"quest_count" = "%d quest";
"quest_count_plural" = "%d quests";

// In Swift code
Text("quest_count".localizedPlural(count: questCount))
```

### 4. Date and Number Formatting

Use the LocalizationManager for locale-aware formatting:

```swift
@EnvironmentObject var localizationManager: LocalizationManager

// Date formatting
Text(localizationManager.formatDate(Date(), style: .medium))

// Number formatting
Text(localizationManager.formatNumber(NSNumber(value: 1234.56)))
```

## Adding New Languages

### Step 1: Create Language Directory

Create a new `.lproj` directory for your language:
```
RPGHabitPlanner/
└── [language_code].lproj/
    └── Localizable.strings
```

### Step 2: Add Language to LocalizationManager

Update `LocalizationManager.swift`:

```swift
enum Language: String, CaseIterable, Identifiable {
    case english = "en"
    case turkish = "tr"
    case spanish = "es"  // New language
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .turkish: return "Türkçe"
        case .spanish: return "Español"  // New language
        }
    }
    
    var flag: String {
        switch self {
        case .english: return "🇺🇸"
        case .turkish: return "🇹🇷"
        case .spanish: return "🇪🇸"  // New language
        }
    }
    
    var locale: Locale {
        switch self {
        case .english: return Locale(identifier: "en_US")
        case .turkish: return Locale(identifier: "tr_TR")
        case .spanish: return Locale(identifier: "es_ES")  // New language
        }
    }
}
```

### Step 3: Translate Strings

Copy the English `Localizable.strings` file to your new language directory and translate all the values.

## Best Practices

### 1. Use String Constants

Instead of hardcoding strings, use the predefined constants:

```swift
// Good
Text(String.adventureHub.localized)

// Avoid
Text("adventure_hub".localized)
```

### 2. Group Related Strings

Organize your `Localizable.strings` file with clear sections:

```strings
// MARK: - Navigation & Titles
"adventure_hub" = "Adventure Hub";
"quest_tracking" = "Quest Tracking";

// MARK: - Quest Related
"quest" = "Quest";
"quests" = "Quests";
```

### 3. Use Descriptive Keys

Make your localization keys descriptive and consistent:

```swift
// Good
"quest_title" = "Title";
"quest_description" = "Description";

// Avoid
"title" = "Title";
"desc" = "Description";
```

### 4. Handle Missing Translations

The system automatically falls back to the key name if a translation is missing. Always test with different languages to ensure all strings are translated.

### 5. Consider Text Length

Different languages have different text lengths. Design your UI to accommodate longer text:

```swift
// Use flexible layouts
HStack {
    Text(String.questTitle.localized)
        .lineLimit(nil)  // Allow multiple lines
    Spacer()
}
```

## Testing Localization

### 1. Simulator Testing

1. Open your app in the simulator
2. Go to Settings > General > Language & Region
3. Change the language
4. Restart your app

### 2. Xcode Testing

1. Edit your scheme in Xcode
2. Go to Run > Options
3. Set "Application Language" to your target language
4. Run the app

### 3. Runtime Language Switching

The app supports runtime language switching through the `LanguageSettingsView`. Users can change languages without restarting the app.

## Common Patterns

### 1. Alert Messages

```swift
.alert(isPresented: $showAlert) {
    Alert(
        title: Text(String.errorTitle.localized),
        message: Text(String.unknownError.localized),
        dismissButton: .default(Text(String.okButton.localized))
    )
}
```

### 2. Navigation Titles

```swift
.navigationTitle(String.adventureHub.localized)
```

### 3. Button Labels

```swift
Button(String.saveQuest.localized) {
    // Action
}
```

### 4. Form Labels

```swift
TextField(String.questTitle.localized, text: $title)
```

## Troubleshooting

### 1. Strings Not Localizing

- Check that the key exists in all language files
- Verify the key spelling matches exactly
- Ensure the `.lproj` directory is included in your target

### 2. Format Strings Not Working

- Make sure format specifiers match the number of arguments
- Use the correct format specifiers for your data type (`%d`, `%@`, etc.)

### 3. Date/Number Formatting Issues

- Verify the locale is set correctly
- Check that the date/number formatter is using the current locale

## Future Enhancements

Consider these improvements for future versions:

1. **RTL Support**: Add support for right-to-left languages like Arabic
2. **Dynamic Type**: Ensure text scales properly with accessibility settings
3. **VoiceOver**: Add proper accessibility labels for screen readers
4. **Contextual Translations**: Support different translations based on context
5. **Remote Localization**: Download translations from a server

## Resources

- [Apple Localization Guide](https://developer.apple.com/documentation/xcode/localization)
- [NSLocalizedString Documentation](https://developer.apple.com/documentation/foundation/nslocalizedstring)
- [Locale Documentation](https://developer.apple.com/documentation/foundation/locale)
