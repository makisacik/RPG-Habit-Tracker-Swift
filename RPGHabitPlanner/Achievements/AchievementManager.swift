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
    
    private let userDefaults = UserDefaults.standard
    private let unlockedAchievementsKey = "unlockedAchievements"
    
    private init() {
        loadUnlockedAchievements()
    }
    
    // MARK: - Achievement Checking
    
    func checkAchievements(
        questDataService: QuestDataServiceProtocol,
        userManager: UserManager,
        completion: @escaping ([AchievementDefinition]) -> Void
    ) {
        var newlyUnlocked: [AchievementDefinition] = []
        
        for achievement in AchievementDefinition.allAchievements {
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
                count = quests.filter { $0.isCompleted }.count
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
                // Calculate total experience: current exp + (level - 1) * 100
                totalExp = Int(user.exp) + (Int(user.level) - 1) * 100
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
                    quest.isCompleted &&
                    quest.completionDate != nil &&
                    Calendar.current.component(.hour, from: quest.completionDate!) < hour
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
                    quest.isCompleted &&
                    quest.completionDate != nil &&
                    Calendar.current.component(.hour, from: quest.completionDate!) >= hour
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
        return AchievementDefinition.allAchievements.filter { unlockedAchievements.contains($0.id) }
    }
    
    func getLockedAchievements() -> [AchievementDefinition] {
        return AchievementDefinition.allAchievements.filter { !unlockedAchievements.contains($0.id) }
    }
    
    func getAllAchievements() -> [AchievementDefinition] {
        return AchievementDefinition.allAchievements
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
    #endif
}
