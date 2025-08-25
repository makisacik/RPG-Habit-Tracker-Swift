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
    static let questType = "quest_type"
    static let quickQuests = "quick_quests"
    static let chooseFromCuratedQuestTemplates = "choose_from_curated_quest_templates"
    static let mainQuest = "main_quest"
    static let sideQuest = "side_quest"
    static let questTitle = "quest_title"
    static let questDescription = "quest_description"
    static let questDifficulty = "quest_difficulty"
    static let questDueDate = "quest_due_date"
    static let basicInformation = "basic_information"
    static let questSettings = "quest_settings"
    static let enterQuestTitle = "enter_quest_title"
    static let enterQuestDescription = "enter_quest_description"
    static let repeatType = "repeat_type"
    static let manageTasks = "manage_tasks"
    static let saveQuest = "save_quest"
    static let editQuest = "edit_quest"
    static let deleteQuest = "delete_quest"
    static let completeQuest = "complete_quest"
    static let questCompleted = "quest_completed"
    static let questFailed = "quest_failed"
    static let questExpired = "quest_expired"
    static let markAsFinished = "mark_as_finished"
    static let finished = "finished"

    // MARK: - Quest Filters
    static let activeToday = "active_today"
    static let inactiveToday = "inactive_today"
    static let allQuests = "all_quests"
    static let today = "today"

    // MARK: - Tasks
    static let task = "task"
    static let tasks = "tasks"
    static let addTask = "add_task"
    static let addNewTask = "add_new_task"
    static let editTasks = "edit_tasks"
    static let enterTaskDescription = "enter_task_description"
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

    static let characterPreview = "character_preview"
    static let customizeCharacter = "customize_character"
    static let hairStyle = "hair_style"
    static let eyeStyle = "eye_style"
    static let outfit = "outfit"
    static let weapon = "weapon"
    static let currentSelection = "current_selection"
    static let style = "style"
    static let level = "level"
    static let experience = "experience"
    static let health = "health"
    static let healthPoints = "health_points"
    static let mana = "mana"
    static let strength = "strength"
    static let intelligence = "intelligence"
    static let agility = "agility"
    static let levelUp = "level_up"
    static let experienceGained = "experience_gained"
    static let newLevelReached = "new_level_reached"

    // MARK: - Streak System
    static let streak = "streak"
    static let currentStreak = "current_streak"
    static let longestStreak = "longest_streak"
    static let streakDays = "streak_days"
    static let streakDay = "streak_day"
    static let bestStreak = "best_streak"
    static let todayStatus = "today_status"
    static let streakCalendar = "streak_calendar"
    static let monthlyActivity = "monthly_activity"
    static let activeDays = "active_days"
    static let activityRate = "activity_rate"

    // MARK: - Rewards & Achievements
    static let reward = "reward"
    static let rewards = "rewards"
    static let achievement = "achievement"
    static let achievementUnlocked = "achievement_unlocked"
    static let unlocked = "unlocked"
    static let locked = "locked"
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
    static let addQuest = "add_quest"
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
    static let chooseYourPreferredLanguage = "choose_your_preferred_language"
    static let languageChangesWillTakeEffectImmediately = "language_changes_will_take_effect_immediately"
    static let someSystemElementsMayRemainInPreviousLanguage = "some_system_elements_may_remain_in_previous_language"
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
    static let startAdventure = "start_adventure"
    static let letsBegin = "lets_begin"
    static let confirmSelection = "confirm_selection"
    static let enterYourNickname = "enter_your_nickname"
    static let nickname = "nickname"
    static let transformHabitsIntoEpicAdventures = "transform_habits_into_epic_adventures"
    static let createEpicQuests = "create_epic_quests"
    static let turnDailyTasksIntoHeroicMissions = "turn_daily_tasks_into_heroic_missions"
    static let earnRewards = "earn_rewards"
    static let levelUpAndUnlockAchievements = "level_up_and_unlock_achievements"
    static let trackProgress = "track_progress"
    static let watchYourCharacterGrowStronger = "watch_your_character_grow_stronger"
    static let readyToBeginAdventure = "ready_to_begin_adventure"
    static let chooseYourHero = "choose_your_hero"

    static let customizeYourHero = "customize_your_hero"
    static let chooseWeaponAndSeeCharacterComeToLife = "choose_weapon_and_see_character_come_to_life"
    static let selectYourWeapon = "select_your_weapon"
    static let nameYourHero = "name_your_hero"
    static let chooseLegendaryNameForCharacter = "choose_legendary_name_for_character"
    static let enterYourHerosName = "enter_your_heros_name"
    static let maximum20Characters = "maximum_20_characters"
    static let readyForAdventure = "ready_for_adventure"
    static let yourHeroIsReadyToBeginJourney = "your_hero_is_ready_to_begin_journey"

    // MARK: - Focus Timer
    static let selectMonster = "select_monster"
    static let noMonsterSelected = "no_monster_selected"
    static let chooseYourEnemy = "choose_your_enemy"
    static let pomodoros = "pomodoros"
    static let monsterDefeated = "monster_defeated"
    static let youHaveSuccessfullyDefeatedMonster = "you_have_successfully_defeated_monster"
    static let continueButton = "continue"

    // MARK: - Character Classes
    static let warrior = "warrior"
    static let mage = "mage"
    static let rogue = "rogue"
    static let paladin = "paladin"
    static let archer = "archer"

    // MARK: - Error Messages
    static let unknown = "unknown"
    static let adventurer = "adventurer"
    static let unknownError = "unknown_error"
    static let headsUp = "heads_up"
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
    static let activeQuest = "active_quest"
    static let noCompletedQuests = "no_completed_quests"
    static let noFinishedQuestsYet = "no_finished_quests_yet"
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

    // MARK: - Tab Navigation
    static let home = "home"
    static let focusTimer = "focus_timer"
    static let questJournal = "quest_journal"

    // MARK: - Home Screen
    static let active = "active"
    static let viewAll = "view_all"
    static let createQuest = "create_quest"
    static let loadingCharacter = "loading_character"
    static let noAchievementsYet = "no_achievements_yet"
    static let completeQuestsToEarnAchievements = "complete_quests_to_earn_achievements"

    // MARK: - Quest Details
    static let questDetails = "quest_details"
    static let close = "close"
    static let deleteQuestConfirmation = "delete_quest_confirmation"
    static let deleteQuestWarning = "delete_quest_warning"
    static let difficulty = "difficulty"
    static let completionHistory = "completion_history"
    static let noCompletionsYet = "no_completions_yet"

    // MARK: - Character Details
    static let exp = "exp"
    static let equippedWeapon = "equipped_weapon"
    static let characterId = "character_id"

    // MARK: - Calendar
    static let questCalendar = "quest_calendar"
    static let setDueDate = "set_due_date"
    static let dueDate = "due_date"
    static let defaultDuration = "default_duration"

    // MARK: - Focus Timer
    static let remaining = "remaining"
    static let complete = "complete"
    static let percentComplete = "percent_complete"

    // MARK: - Widget
    static let allQuestsCompleted = "all_quests_completed"
    static let dueToday = "due_today"
    static let dueTomorrow = "due_tomorrow"
    static let daysLeft = "days_left"
    static let untitledQuest = "untitled_quest"

    // MARK: - Settings
    static let darkMode = "dark_mode"
    static let switchBetweenLightAndDarkThemes = "switch_between_light_and_dark_themes"
    static let notificationsSettings = "notifications_settings"
    static let dataAndStorage = "data_and_storage"
    static let dataAndStorageSettings = "data_and_storage_settings"
    static let versionInfo = "version_info"

    // MARK: - Onboarding
    static let yourAdventureAwaits = "your_adventure_awaits"
    static let classLabel = "class_label"
    static let weaponLabel = "weapon_label"

    // MARK: - Quest Categories
    static let healthAndWellness = "health_and_wellness"
    static let productivity = "productivity"
    static let learningAndGrowth = "learning_and_growth"
    static let mindfulness = "mindfulness"
    static let fitness = "fitness"
    static let social = "social"

    // MARK: - Time Formats
    static let daysFromToday = "days_from_today"
    static let weeksFromToday = "weeks_from_today"
    static let monthsFromToday = "months_from_today"

    // MARK: - Battle/Achievement Items
    static let focusCrystal = "focus_crystal"
    static let focusCrystalDescription = "focus_crystal_description"
    static let focusMaster = "focus_master"
    static let focusMasterDescription = "focus_master_description"
    static let dragonSlayer = "dragon_slayer"
    static let dragonSlayerDescription = "dragon_slayer_description"

    // MARK: - Labels
    static let dueLabel = "due_label"
    static let useSystemAppearance = "use_system_appearance"
    static let repeatLabel = "repeat_label"
    static let markIncomplete = "mark_incomplete"
    static let markComplete = "mark_complete"
    static let yes = "yes"
    static let created = "created"
    static let type = "type"
    static let mainQuestLabel = "main_quest_label"
    static let completedLabel = "completed_label"
    static let onLabel = "on_label"
    static let offLabel = "off_label"
    static let widgetDescription = "widget_description"

    // MARK: - Calendar View
    static let theBrave = "the_brave"

    // MARK: - Shop Categories
    static let weapons = "weapons"
    static let armor = "armor"
    static let wings = "wings"
    static let pets = "pets"
    static let consumables = "consumables"
    static let helmet = "helmet"
    static let shield = "shield"
    static let potions = "potions"
    static let boosts = "boosts"

    // MARK: - Shop Items
    static let shop = "shop"
    static let iconGold = "icon_gold"
    static let iconGem = "icon_gem"
}
