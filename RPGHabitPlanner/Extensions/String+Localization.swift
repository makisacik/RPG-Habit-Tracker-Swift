//
//  String+Localization.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import Foundation

extension String {
    /// Localizes a string using the current locale
    /// - Returns: Localized string or the original key if not found
    var localized: String {
        // Use the LocalizationManager's current locale
        let locale = LocalizationManager.shared.currentLocale
        let bundle = Bundle.main
        
        // Try to get the localized string for the specific locale
        if let languagePath = bundle.path(forResource: locale.language.languageCode?.identifier, ofType: "lproj"),
           let languageBundle = Bundle(path: languagePath) {
            return languageBundle.localizedString(forKey: self, value: self, table: nil)
        }
        
        // Fallback to default NSLocalizedString
        return NSLocalizedString(self, comment: "")
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

// MARK: - Localization Keys
extension String {
    // MARK: - General
    static let okButton = "ok"
    static let cancelButton = "cancel"
    static let saveButton = "save"
    static let deleteButton = "delete"
    static let editButton = "edit"
    static let closeButton = "close"
    static let backButton = "back"
    static let nextButton = "next"
    static let previousButton = "previous"
    static let doneButton = "done"
    static let errorTitle = "error"
    static let warningTitle = "warning"
    static let successTitle = "success"
    static let loadingText = "loading"
    
    // MARK: - Navigation & Titles
    static let adventureHub = "adventure_hub"
    static let questTracking = "quest_tracking"
    static let questCreation = "quest_creation"
    static let characterDetails = "character_details"
    static let completedQuests = "completed_quests"
    static let settings = "settings"
    static let about = "about"
    static let calendar = "calendar"
    static let inventory = "inventory"
    static let achievements = "achievements"
    
    // MARK: - Quest Related
    static let quest = "quest"
    static let quests = "quests"
    static let mainQuest = "main_quest"
    static let sideQuest = "side_quest"
    static let questTitle = "quest_title"
    static let questDescription = "quest_description"
    static let questDifficulty = "quest_difficulty"
    static let questDueDate = "quest_due_date"
    static let saveQuest = "save_quest"
    static let editQuest = "edit_quest"
    static let deleteQuest = "delete_quest"
    static let completeQuest = "complete_quest"
    static let questCompleted = "quest_completed"
    static let questFailed = "quest_failed"
    static let questExpired = "quest_expired"
    
    // MARK: - Quest Filters
    static let activeToday = "active_today"
    static let inactiveToday = "inactive_today"
    static let allQuests = "all_quests"
    static let today = "today"
    
    // MARK: - Tasks
    static let task = "task"
    static let tasks = "tasks"
    static let addTask = "add_task"
    static let removeTask = "remove_task"
    static let taskCompleted = "task_completed"
    static let taskIncomplete = "task_incomplete"
    
    // MARK: - Quest Repeat Types
    static let oneTime = "one_time"
    static let daily = "daily"
    static let weekly = "weekly"
    static let monthly = "monthly"
    
    // MARK: - Character & Stats
    static let character = "character"
    static let characterClass = "character_class"
    static let level = "level"
    static let experience = "experience"
    static let health = "health"
    static let mana = "mana"
    static let strength = "strength"
    static let intelligence = "intelligence"
    static let agility = "agility"
    static let levelUp = "level_up"
    static let experienceGained = "experience_gained"
    static let newLevelReached = "new_level_reached"
    
    // MARK: - Rewards & Achievements
    static let reward = "reward"
    static let rewards = "rewards"
    static let achievement = "achievement"
    static let achievementUnlocked = "achievement_unlocked"
    static let experiencePoints = "experience_points"
    static let gold = "gold"
    static let items = "items"
    
    // MARK: - Notifications
    static let notifyMe = "notify_me"
    static let notifyMeAboutQuest = "notify_me_about_quest"
    static let notification = "notification"
    static let notifications = "notifications"
    static let reminder = "reminder"
    static let reminders = "reminders"
    
    // MARK: - Home Screen
    static let quickStats = "quick_stats"
    static let activeQuests = "active_quests"
    static let recentAchievements = "recent_achievements"
    static let quickActions = "quick_actions"
    static let createNewQuest = "create_new_quest"
    static let viewCompletedQuests = "view_completed_quests"
    static let viewCharacterDetails = "view_character_details"
    
    // MARK: - Calendar
    static let calendarView = "calendar_view"
    static let thisWeek = "this_week"
    static let thisMonth = "this_month"
    static let noQuestsScheduled = "no_quests_scheduled"
    static let questsScheduled = "quests_scheduled"
    
    // MARK: - Settings
    static let theme = "theme"
    static let language = "language"
    static let soundEffects = "sound_effects"
    static let music = "music"
    static let notificationsEnabled = "notifications_enabled"
    static let dataBackup = "data_backup"
    static let exportData = "export_data"
    static let importData = "import_data"
    static let resetProgress = "reset_progress"
    static let aboutApp = "about_app"
    static let version = "version"
    static let privacyPolicy = "privacy_policy"
    static let termsOfService = "terms_of_service"
    
    // MARK: - Themes
    static let themeClassic = "theme_classic"
    static let themeDark = "theme_dark"
    static let themeLight = "theme_light"
    static let themeAuto = "theme_auto"
    
    // MARK: - Onboarding
    static let welcome = "welcome"
    static let welcomeToRPGHabitPlanner = "welcome_to_rpg_habit_planner"
    static let createYourCharacter = "create_your_character"
    static let chooseYourClass = "choose_your_class"
    static let startYourAdventure = "start_your_adventure"
    static let letsBegin = "lets_begin"
    
    // MARK: - Character Classes
    static let warrior = "warrior"
    static let mage = "mage"
    static let rogue = "rogue"
    static let paladin = "paladin"
    static let archer = "archer"
    
    // MARK: - Error Messages
    static let unknownError = "unknown_error"
    static let networkError = "network_error"
    static let dataError = "data_error"
    static let validationError = "validation_error"
    static let saveError = "save_error"
    static let loadError = "load_error"
    static let deleteError = "delete_error"
    static let invalidInput = "invalid_input"
    
    // MARK: - Success Messages
    static let questSavedSuccessfully = "quest_saved_successfully"
    static let questDeletedSuccessfully = "quest_deleted_successfully"
    static let questCompletedSuccessfully = "quest_completed_successfully"
    static let dataSavedSuccessfully = "data_saved_successfully"
    static let settingsUpdated = "settings_updated"
    
    // MARK: - Validation Messages
    static let titleRequired = "title_required"
    static let descriptionRequired = "description_required"
    static let dueDateRequired = "due_date_required"
    static let invalidDate = "invalid_date"
    static let dateInPast = "date_in_past"
    
    // MARK: - Time & Date
    static let yesterday = "yesterday"
    static let tomorrow = "tomorrow"
    static let nextWeek = "next_week"
    static let nextMonth = "next_month"
    
    // MARK: - Progress
    static let progress = "progress"
    static let completed = "completed"
    static let inProgress = "in_progress"
    static let notStarted = "not_started"
    static let overdue = "overdue"
    
    // MARK: - Difficulty
    static let easy = "easy"
    static let medium = "medium"
    static let hard = "hard"
    static let veryHard = "very_hard"
    static let legendary = "legendary"
    
    // MARK: - Empty States
    static let noQuests = "no_quests"
    static let noActiveQuests = "no_active_quests"
    static let noCompletedQuests = "no_completed_quests"
    static let noAchievements = "no_achievements"
    static let createYourFirstQuest = "create_your_first_quest"
    static let completeQuestsToEarnRewards = "complete_quests_to_earn_rewards"
    
    // MARK: - Tooltips & Help
    static let tapToComplete = "tap_to_complete"
    static let tapToEdit = "tap_to_edit"
    static let swipeToDelete = "swipe_to_delete"
    static let longPressForOptions = "long_press_for_options"
    static let dragToReorder = "drag_to_reorder"
    
    // MARK: - Accessibility
    static let accessibilityQuestCard = "accessibility_quest_card"
    static let accessibilityCompleteButton = "accessibility_complete_button"
    static let accessibilityEditButton = "accessibility_edit_button"
    static let accessibilityDeleteButton = "accessibility_delete_button"
    static let accessibilityProgressBar = "accessibility_progress_bar"
    static let accessibilityStarRating = "accessibility_star_rating"
    static let accessibilityDatePicker = "accessibility_date_picker"
}
