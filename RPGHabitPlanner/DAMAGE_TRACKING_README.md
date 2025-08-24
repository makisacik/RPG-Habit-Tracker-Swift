# Quest Damage Tracking System

## Overview

The Quest Damage Tracking System is a comprehensive solution that prevents double-charging damage for missed quests while providing transparency and fairness to users. It tracks when damage was last calculated for each quest and only applies damage for new missed periods.

## Core Features

### 1. Damage Prevention
- **No Double-Charging**: Each missed day is only charged once
- **Accurate Tracking**: Only new missed days are charged
- **Fair System**: Damage matches actual missed time

### 2. Quest Type Support
- **Daily Quests**: 3 HP per missed day
- **Weekly Quests**: 8 HP if overdue
- **One-Time Quests**: 10 HP if still overdue
- **Scheduled Quests**: 5 HP per missed scheduled day

### 3. User Transparency
- **Damage History**: Complete record of all damage events
- **Clear Feedback**: Detailed reasons for damage taken
- **Progress Tracking**: See damage reduction over time

## Architecture

### Core Components

#### 1. Models (`QuestDamageTrackingModels.swift`)
```swift
struct QuestDamageTracker {
    let id: UUID
    let questId: UUID
    var lastDamageCheckDate: Date
    var totalDamageTaken: Int
    var damageHistory: [DamageEvent]
    var isActive: Bool
}

struct DamageEvent {
    let id: UUID
    let date: Date
    let damageAmount: Int
    let reason: String
}
```

#### 2. Damage Calculation (`QuestTypeDamageCalculator`)
- **Daily**: Counts missed days from last check to today
- **Weekly**: Checks if quest is overdue since last check
- **One-Time**: Checks if quest is still overdue
- **Scheduled**: Counts missed scheduled days

#### 3. Core Data Entities
- `QuestDamageTrackerEntity`: Stores damage tracking data
- `DamageEventEntity`: Stores individual damage events

#### 4. Services
- `QuestDamageTrackingService`: Core Data persistence
- `QuestDamageTrackingManager`: Main orchestration logic

## Usage Examples

### Example 1: Daily Quest - First Time
```swift
// Quest: "Exercise daily"
// Due Date: 3 days ago
// Last Damage Check: Never (first time)
// Result: 9 HP damage (3 days × 3 HP)
```

### Example 2: Daily Quest - Second Time
```swift
// Quest: "Exercise daily"
// Due Date: 4 days ago
// Last Damage Check: Yesterday
// Result: 3 HP damage (1 day × 3 HP)
```

### Example 3: Daily Quest - Completed Yesterday
```swift
// Quest: "Exercise daily"
// Due Date: 3 days ago
// Last Damage Check: 2 days ago
// Status: Completed yesterday
// Result: 0 HP damage
```

## Implementation Details

### Damage Calculation Process

1. **Check Last Damage Date**
   - For each quest: Check when we last calculated damage
   - If never calculated: Start from quest's due date
   - If previously calculated: Start from the day after last damage check

2. **Calculate New Damage**
   - Only count days: From last damage check date until today
   - Avoid double-counting: Don't charge for days already processed

3. **Update Last Damage Date**
   - After calculation: Set last damage date to today
   - Prevent future double-charging: Next check starts from tomorrow

### Integration Points

#### 1. Quest Completion
```swift
// Automatically deactivate damage tracking when quest is completed
NotificationCenter.default.post(
    name: .questCompleted,
    object: nil,
    userInfo: ["questId": questId]
)
```

#### 2. Quest Failure
```swift
// Apply damage when quest fails
damageTrackingManager.calculateDamageForQuest(quest) { damageAmount, error in
    // Handle damage application
}
```

#### 3. Manual Calculation
```swift
// Calculate damage for all active quests
damageTrackingManager.calculateAndApplyQuestDamage { totalDamage, error in
    // Handle total damage
}
```

## UI Components

### 1. Damage History View
- Shows complete damage history for a quest
- Displays damage amount, reason, and date
- Provides transparency to users

### 2. Damage Calculator View
- Manual damage calculation for testing
- Shows active quests and their status
- Displays today's total damage taken

## Testing

### Unit Tests
- Damage calculation logic for each quest type
- Edge cases and boundary conditions
- Integration with health system

### Test Scenarios
1. **First-time damage calculation**
2. **Subsequent damage calculations**
3. **Quest completion scenarios**
4. **Different quest types**
5. **Date boundary conditions**

## Benefits

### 1. Prevents Double-Charging
- No duplicate damage for same missed day
- Accurate tracking of missed periods
- Fair damage application

### 2. User Transparency
- Complete damage history
- Clear reasons for damage taken
- Progress tracking over time

### 3. Fair System
- Proportional damage to missed time
- No punishment for app usage
- Immediate feedback on quest completion

### 4. Recovery Tracking
- Immediate damage reduction on completion
- Progress visualization
- Motivation for quest completion

## Configuration

### Damage Constants
```swift
enum QuestDamageConstants {
    static let dailyQuestDamagePerDay = 3
    static let weeklyQuestDamage = 8
    static let oneTimeQuestDamage = 10
    static let scheduledQuestDamagePerDay = 5
}
```

### Customization
- Damage amounts can be adjusted per quest type
- Calculation logic can be modified for different requirements
- UI components can be customized for different themes

## Future Enhancements

### 1. Advanced Features
- Damage reduction based on quest difficulty
- Streak-based damage mitigation
- Recovery items and healing mechanics

### 2. Analytics
- Damage patterns analysis
- Quest completion correlation
- User behavior insights

### 3. Gamification
- Damage-based achievements
- Recovery challenges
- Damage prevention rewards

## Troubleshooting

### Common Issues

1. **No damage calculated**
   - Check if quest is active and not completed
   - Verify last damage check date
   - Ensure quest due date is in the past

2. **Incorrect damage amount**
   - Verify quest type and damage constants
   - Check completion dates for daily quests
   - Review scheduled days for scheduled quests

3. **Missing damage history**
   - Check Core Data persistence
   - Verify damage event creation
   - Review tracker activation status

### Debug Tools
- Damage calculation view for manual testing
- Damage history view for verification
- Unit tests for logic validation
