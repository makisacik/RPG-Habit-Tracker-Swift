//
//  AchievementManager.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import Foundation
import Combine

class AchievementManager: ObservableObject {
    static let shared = AchievementManager()

    @Published var unlockedAchievements: Set<String> = []
    @Published var newlyUnlockedAchievements: [AchievementDefinition] = []
    @Published var languageChangeTrigger: String = ""

    private let userDefaults = UserDefaults.standard
    private let unlockedAchievementsKey = "unlockedAchievements"
    private var cancellables = Set<AnyCancellable>()

    private init() {
        loadUnlockedAchievements()
        setupLanguageChangeObserver()
    }
    
    private func setupLanguageChangeObserver() {
        NotificationCenter.default.publisher(for: .languageChanged)
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.languageChangeTrigger = UUID().uuidString
                    self?.objectWillChange.send()
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Achievement Checking

    func checkAchievements(
        questDataService: QuestDataServiceProtocol,
        userManager: UserManager,
        completion: @escaping ([AchievementDefinition]) -> Void
    ) {
        var newlyUnlocked: [AchievementDefinition] = []

        for achievement in AchievementDefinition.getAllAchievements() {
            if !unlockedAchievements.contains(achievement.id) {
                if isAchievementUnlocked(achievement, questDataService: questDataService, userManager: userManager) {
                    newlyUnlocked.append(achievement)
                    unlockAchievement(achievement.id)
                }
            }
        }

        if !newlyUnlocked.isEmpty {
            newlyUnlockedAchievements = newlyUnlocked
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.newlyUnlockedAchievements = []
            }
        }

        #if DEBUG
        // Debug achievement status
        debugAchievementStatus(questDataService: questDataService)
        #endif

        completion(newlyUnlocked)
    }

    private func isAchievementUnlocked(
        _ achievement: AchievementDefinition,
        questDataService: QuestDataServiceProtocol,
        userManager: UserManager
    ) -> Bool {
        switch achievement.requirement {
        case .questCount(let count):
            return getCompletedQuestCount(questDataService) >= count

        case .questsInDay(let count):
            return getQuestsCompletedToday(questDataService) >= count

        case .consecutiveDays(let days):
            return getConsecutiveDaysWithQuests(questDataService) >= days

        case .level(let level):
            var userLevel = 0
            let semaphore = DispatchSemaphore(value: 0)
            userManager.fetchUser { user, _ in
                if let user = user {
                    userLevel = Int(user.level)
                }
                semaphore.signal()
            }
            semaphore.wait()
            return userLevel >= level

        case .totalExperience(let exp):
            return getTotalExperience(userManager) >= exp


        case .questBeforeTime(let hour):
            return hasCompletedQuestBeforeTime(questDataService, hour: hour)

        case .questAfterTime(let hour):
            return hasCompletedQuestAfterTime(questDataService, hour: hour)

        case .questInTimeRange(let startHour, let endHour):
            return hasCompletedQuestInTimeRange(questDataService, startHour: startHour, endHour: endHour)

        case .weekendQuests(let count):
            return getWeekendQuestsCompleted(questDataService) >= count

        case .allDailyQuests:
            return hasCompletedAllDailyQuests(questDataService)
        }
    }

    // MARK: - Achievement Data Helpers

    private func getCompletedQuestCount(_ questDataService: QuestDataServiceProtocol) -> Int {
        var count = 0
        let semaphore = DispatchSemaphore(value: 0)

        questDataService.fetchAllQuests { quests, _ in
                // Count quests that have been finished (permanently completed)
                count = quests.filter { $0.isFinished }.count
            semaphore.signal()
        }

        semaphore.wait()
        return count
    }

    private func getQuestsCompletedToday(_ questDataService: QuestDataServiceProtocol) -> Int {
        var count = 0
        let semaphore = DispatchSemaphore(value: 0)

        questDataService.fetchAllQuests { quests, _ in
                let today = Calendar.current.startOfDay(for: Date())
                count = quests.filter { quest in
                    quest.isCompleted &&
                    quest.completionDate != nil &&
                    Calendar.current.isDate(quest.completionDate!, inSameDayAs: today)
                }.count
            semaphore.signal()
        }

        semaphore.wait()
        return count
    }

    private func getConsecutiveDaysWithQuests(_ questDataService: QuestDataServiceProtocol) -> Int {
        var consecutiveDays = 0
        let semaphore = DispatchSemaphore(value: 0)

        questDataService.fetchAllQuests { quests, _ in
                let completedQuests = quests.filter { $0.isCompleted && $0.completionDate != nil }
                let completionDates = completedQuests.compactMap { $0.completionDate }

                if !completionDates.isEmpty {
                    consecutiveDays = self.calculateConsecutiveDays(from: completionDates)
                }
            semaphore.signal()
        }

        semaphore.wait()
        return consecutiveDays
    }

    private func calculateConsecutiveDays(from dates: [Date]) -> Int {
        let calendar = Calendar.current
        let sortedDates = dates.map { calendar.startOfDay(for: $0) }.sorted()
        let uniqueDates = Array(Set(sortedDates)).sorted()

        var maxConsecutive = 0
        var currentConsecutive = 0

        for i in 0..<uniqueDates.count {
            if i == 0 {
                currentConsecutive = 1
            } else {
                let previousDate = uniqueDates[i - 1]
                let currentDate = uniqueDates[i]

                if calendar.dateInterval(of: .day, for: previousDate)?.end == currentDate {
                    currentConsecutive += 1
                } else {
                    currentConsecutive = 1
                }
            }

            maxConsecutive = max(maxConsecutive, currentConsecutive)
        }

        return maxConsecutive
    }

    private func getTotalExperience(_ userManager: UserManager) -> Int {
        var totalExp = 0
        let semaphore = DispatchSemaphore(value: 0)

        userManager.fetchUser { user, _ in
            if let user = user {
                // Calculate total experience using the new leveling system
                let levelingSystem = LevelingSystem.shared
                totalExp = levelingSystem.calculateTotalExperience(level: Int(user.level), experienceInLevel: Int(user.exp))
            }
            semaphore.signal()
        }

        semaphore.wait()
        return totalExp
    }


    private func hasCompletedQuestBeforeTime(_ questDataService: QuestDataServiceProtocol, hour: Int) -> Bool {
        var hasCompleted = false
        let semaphore = DispatchSemaphore(value: 0)

        questDataService.fetchAllQuests { quests, _ in
                hasCompleted = quests.contains { quest in
                    // Check if quest is finished (permanently completed)
                    if quest.isFinished && quest.isFinishedDate != nil {
                        return Calendar.current.component(.hour, from: quest.isFinishedDate!) < hour
                    }
                    // Check if any completion date is before the specified hour
                    return quest.completions.contains { completionDate in
                        Calendar.current.component(.hour, from: completionDate) < hour
                    }
                }
            semaphore.signal()
        }
        semaphore.wait()
        return hasCompleted
    }

    private func hasCompletedQuestAfterTime(_ questDataService: QuestDataServiceProtocol, hour: Int) -> Bool {
        var hasCompleted = false
        let semaphore = DispatchSemaphore(value: 0)

        questDataService.fetchAllQuests { quests, _ in
                hasCompleted = quests.contains { quest in
                    // Check if quest is finished (permanently completed)
                    if quest.isFinished && quest.isFinishedDate != nil {
                        return Calendar.current.component(.hour, from: quest.isFinishedDate!) >= hour
                    }
                    // Check if any completion date is after the specified hour
                    return quest.completions.contains { completionDate in
                        Calendar.current.component(.hour, from: completionDate) >= hour
                    }
                }
            semaphore.signal()
        }

        semaphore.wait()
        return hasCompleted
    }

    private func hasCompletedQuestInTimeRange(_ questDataService: QuestDataServiceProtocol, startHour: Int, endHour: Int) -> Bool {
        var hasCompleted = false
        let semaphore = DispatchSemaphore(value: 0)

        questDataService.fetchAllQuests { quests, _ in
                hasCompleted = quests.contains { quest in
                    // Check if quest is finished (permanently completed)
                    if quest.isFinished && quest.isFinishedDate != nil {
                        let hour = Calendar.current.component(.hour, from: quest.isFinishedDate!)
                        return hour >= startHour && hour < endHour
                    }
                    // Check if any completion date is within the specified time range
                    return quest.completions.contains { completionDate in
                        let hour = Calendar.current.component(.hour, from: completionDate)
                        return hour >= startHour && hour < endHour
                    }
                }
            semaphore.signal()
        }

        semaphore.wait()
        return hasCompleted
    }

    private func getWeekendQuestsCompleted(_ questDataService: QuestDataServiceProtocol) -> Int {
        var count = 0
        let semaphore = DispatchSemaphore(value: 0)

        questDataService.fetchAllQuests { quests, error in
            guard error == nil else {
                semaphore.signal()
                return
            }
            count = quests.filter { quest in
                quest.isCompleted &&
                quest.completionDate != nil &&
                Calendar.current.isDateInWeekend(quest.completionDate!)
            }.count
            semaphore.signal()
        }

        semaphore.wait()
        return count
    }


    private func hasCompletedAllDailyQuests(_ questDataService: QuestDataServiceProtocol) -> Bool {
        var hasCompletedAll = false
        let semaphore = DispatchSemaphore(value: 0)

        questDataService.fetchAllQuests { quests, _ in
                let today = Calendar.current.startOfDay(for: Date())
                let dailyQuests = quests.filter { quest in
                    quest.repeatType == .daily && quest.isActive
                }

                let completedToday = quests.filter { quest in
                    quest.isCompleted &&
                    quest.completionDate != nil &&
                    Calendar.current.isDate(quest.completionDate!, inSameDayAs: today)
                }

                hasCompletedAll = !dailyQuests.isEmpty && dailyQuests.count == completedToday.count
            semaphore.signal()
        }

        semaphore.wait()
        return hasCompletedAll
    }

    // MARK: - Achievement Management

    func unlockAchievement(_ achievementId: String) {
        unlockedAchievements.insert(achievementId)
        saveUnlockedAchievements()
    }

    func isAchievementUnlocked(_ achievementId: String) -> Bool {
        return unlockedAchievements.contains(achievementId)
    }

    func getUnlockedAchievements() -> [AchievementDefinition] {
        return AchievementDefinition.getAllAchievements().filter { unlockedAchievements.contains($0.id) }
    }

    func getLockedAchievements() -> [AchievementDefinition] {
        return AchievementDefinition.getAllAchievements().filter { !unlockedAchievements.contains($0.id) }
    }

    func getAllAchievements() -> [AchievementDefinition] {
        return AchievementDefinition.getAllAchievements()
    }

    // MARK: - Persistence

    private func saveUnlockedAchievements() {
        let array = Array(unlockedAchievements)
        userDefaults.set(array, forKey: unlockedAchievementsKey)
    }

    private func loadUnlockedAchievements() {
        if let array = userDefaults.array(forKey: unlockedAchievementsKey) as? [String] {
            unlockedAchievements = Set(array)
        }
    }

    func resetAllAchievements() {
        unlockedAchievements.removeAll()
        saveUnlockedAchievements()
    }

    // MARK: - Debug Methods

    #if DEBUG
    func unlockAllAchievements() {
        for achievement in AchievementDefinition.allAchievements {
            unlockedAchievements.insert(achievement.id)
        }
        saveUnlockedAchievements()
    }

    func unlockRandomAchievements() {
        let randomCount = Int.random(in: 1...5)
        let randomAchievements = AchievementDefinition.allAchievements.shuffled().prefix(randomCount)

        for achievement in randomAchievements {
            unlockedAchievements.insert(achievement.id)
        }
        saveUnlockedAchievements()
    }
    
    func debugAchievementStatus(questDataService: QuestDataServiceProtocol) {
        questDataService.fetchAllQuests { quests, _ in
            let finishedQuests = quests.filter { $0.isFinished }
            let completedQuests = quests.filter { $0.isCompleted }
            let questsWithCompletions = quests.filter { !$0.completions.isEmpty }
            
            print("🔍 Achievement Debug Info:")
            print("   Total quests: \(quests.count)")
            print("   Finished quests: \(finishedQuests.count)")
            print("   Completed quests: \(completedQuests.count)")
            print("   Quests with completions: \(questsWithCompletions.count)")
            print("   First Steps achievement unlocked: \(self.isAchievementUnlocked("first_quest"))")
            
            for quest in finishedQuests {
                print("   ✅ Finished quest: '\(quest.title)' (ID: \(quest.id))")
            }
        }
    }
    #endif
}
