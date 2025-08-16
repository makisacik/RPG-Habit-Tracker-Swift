import Foundation
import CoreData

class StreakManager: ObservableObject {
    static let shared = StreakManager()
    
    private let userManager: UserManager
    private let persistentContainer: NSPersistentContainer
    
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var lastActivityDate: Date?
    
    private init() {
        self.userManager = UserManager()
        self.persistentContainer = PersistenceController.shared.container
        loadStreakData()
    }
    
    // MARK: - Public Methods
    
    /// Records an activity and updates the streak
    func recordActivity() {
        let today = Date().startOfDay
        
        // Check if we already recorded activity today
        if let lastDate = lastActivityDate, Calendar.current.isDate(lastDate, inSameDayAs: today) {
            return // Already recorded today
        }
        
        // Check if this is a consecutive day
        if let lastDate = lastActivityDate {
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today) ?? today
            
            if Calendar.current.isDate(lastDate, inSameDayAs: yesterday) {
                // Consecutive day - increment streak
                currentStreak += 1
            } else if Calendar.current.isDate(lastDate, inSameDayAs: today) {
                // Same day - no change
                return
            } else {
                // Gap in streak - reset to 1
                currentStreak = 1
            }
        } else {
            // First activity ever
            currentStreak = 1
        }
        
        // Update longest streak if current is higher
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
        
        lastActivityDate = today
        
        // Save to Core Data
        saveStreakData()
        
        // Post notification for UI updates
        NotificationCenter.default.post(name: .streakUpdated, object: nil)
    }
    
    /// Gets the current streak count
    func getCurrentStreak() -> Int {
        return currentStreak
    }
    
    /// Gets the longest streak achieved
    func getLongestStreak() -> Int {
        return longestStreak
    }
    
    /// Checks if user was active today
    func wasActiveToday() -> Bool {
        guard let lastDate = lastActivityDate else { return false }
        return Calendar.current.isDateInToday(lastDate)
    }
    
    /// Gets the date of the last activity
    func getLastActivityDate() -> Date? {
        return lastActivityDate
    }
    
    /// Resets the streak (for testing or manual reset)
    func resetStreak() {
        currentStreak = 0
        longestStreak = 0
        lastActivityDate = nil
        saveStreakData()
        NotificationCenter.default.post(name: .streakUpdated, object: nil)
    }
    
    // MARK: - Private Methods
    
    private func loadStreakData() {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<StreakEntity> = StreakEntity.fetchRequest()
        
        do {
            let streaks = try context.fetch(fetchRequest)
            if let streak = streaks.first {
                self.currentStreak = Int(streak.currentStreak)
                self.longestStreak = Int(streak.longestStreak)
                self.lastActivityDate = streak.lastActivityDate
            }
        } catch {
            print("Failed to load streak data: \(error)")
        }
    }
    
    private func saveStreakData() {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<StreakEntity> = StreakEntity.fetchRequest()
        
        do {
            let streaks = try context.fetch(fetchRequest)
            let streak: StreakEntity
            
            if let existingStreak = streaks.first {
                streak = existingStreak
            } else {
                streak = StreakEntity(context: context)
                streak.id = UUID()
            }
            
            streak.currentStreak = Int16(currentStreak)
            streak.longestStreak = Int16(longestStreak)
            streak.lastActivityDate = lastActivityDate
            
            try context.save()
        } catch {
            print("Failed to save streak data: \(error)")
        }
    }
}

// MARK: - Extensions

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
}

extension Notification.Name {
    static let streakUpdated = Notification.Name("streakUpdated")
}
