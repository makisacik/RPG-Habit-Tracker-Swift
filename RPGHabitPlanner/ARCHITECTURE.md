# RPG Habit Planner - Architecture Documentation

## Overview
This document describes the restructured architecture of the RPG Habit Planner app, focusing on the onboarding and character customization systems.

## New File Structure

### Onboarding Module
```
Onboarding/
├── OnboardingCoordinator.swift          # Main coordinator for onboarding flow
├── OnboardingFlowView.swift             # Main onboarding view using coordinator
├── OnboardingView.swift                 # Entry point for onboarding
└── Steps/
    ├── WelcomeStepView.swift            # Welcome step
    ├── CharacterCustomizationStepView.swift  # Character customization step
    ├── NicknameStepView.swift           # Nickname selection step
    └── FinalStepView.swift              # Final completion step
```

### Character Customization Module
```
Character Customization/
├── CharacterCustomizationFlow.swift     # Main customization flow coordinator
└── Components/
    ├── CharacterPreviewCard.swift       # Character preview component
    └── CustomizationComponents.swift    # Reusable customization components
```

### Character Creation Module (Renamed)
```
CharacterCreation/
├── CharacterCreationMainView.swift      # Main character creation view
├── CharacterCreationViewModel.swift     # View model for character creation
├── CharacterCustomizationMainView.swift # Main customization view
├── CharacterCustomizationManager.swift  # Customization manager
├── CharacterCustomizationModels.swift   # Customization data models
├── CustomizationStepView.swift          # Individual customization step view
├── NicknamePopupView.swift              # Nickname popup component
└── CloseButtonView.swift                # Reusable close button
```

## Architecture Principles

### 1. Coordinator Pattern
- **OnboardingCoordinator**: Manages the entire onboarding flow
- **CharacterCustomizationFlowCoordinator**: Manages character customization steps
- Clear separation of concerns between flow management and UI

### 2. Component-Based Architecture
- Reusable components in separate files
- Clear interfaces between components
- Easy to test and maintain

### 3. Step-Based Flow
- Each onboarding step is a separate view
- Clear progression through steps
- Easy to add/remove steps

## Key Improvements

### Before (Old Structure)
- ❌ Large monolithic files
- ❌ Mixed concerns in single files
- ❌ Hard to maintain and test
- ❌ Confusing naming conventions

### After (New Structure)
- ✅ Separated concerns with coordinators
- ✅ Component-based architecture
- ✅ Clear file naming and organization
- ✅ Easy to extend and maintain
- ✅ Better testability

## Usage Examples

### Using the New Onboarding Flow
```swift
struct ContentView: View {
    @State private var isOnboardingCompleted = false
    
    var body: some View {
        if isOnboardingCompleted {
            MainAppView()
        } else {
            OnboardingView(isOnboardingCompleted: $isOnboardingCompleted)
                .environmentObject(ThemeManager.shared)
        }
    }
}
```

### Using the Character Customization Flow
```swift
struct CharacterCustomizationStepView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    
    var body: some View {
        CharacterCustomizationFlow { customization in
            coordinator.updateCharacterCustomization(customization)
        }
        .environmentObject(ThemeManager.shared)
    }
}
```

## Migration Notes

### Files Removed
- `OnboardingViewModel.swift` → Replaced by `OnboardingCoordinator.swift`
- `OnboardingStepViews.swift` → Split into individual step files
- `CharacterCustomizationWizardView.swift` → Replaced by `CharacterCustomizationFlow.swift`
- `CustomizedCharacterPreviewCard.swift` → Moved to `CharacterPreviewCard.swift`

### Files Renamed
- `Character Creation/` → `CharacterCreation/`
- `CharacterCreationView.swift` → `CharacterCreationMainView.swift`
- `CharacterCustomizationView.swift` → `CharacterCustomizationMainView.swift`

### New Files Added
- `OnboardingCoordinator.swift`
- `OnboardingFlowView.swift`
- `Steps/` directory with individual step views
- `Character Customization/` directory with flow and components
- `CharacterCustomizationFlow.swift`
- `CustomizationComponents.swift`

## Benefits of New Architecture

1. **Maintainability**: Each component has a single responsibility
2. **Testability**: Easy to test individual components and coordinators
3. **Extensibility**: Easy to add new steps or customization options
4. **Readability**: Clear file names and organization
5. **Reusability**: Components can be reused across different parts of the app
6. **Scalability**: Architecture supports growth and new features

## Future Considerations

1. **State Management**: Consider using a more robust state management solution for larger scale
2. **Dependency Injection**: Consider implementing DI for better testability
3. **Error Handling**: Add comprehensive error handling throughout the flow
4. **Accessibility**: Ensure all components are accessible
5. **Localization**: Support for multiple languages in all components
