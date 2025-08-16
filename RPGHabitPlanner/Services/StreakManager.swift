import Foundation
import CoreData

class StreakManager: ObservableObject {
    static let shared = StreakManager()
    
    private let userManager: UserManager
    private let persistentContainer: NSPersistentContainer
    
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var lastActivityDate: Date?
    @Published var activityDates: Set<Date> = []
    
    private init() {
        print("🔥 StreakManager: Initializing StreakManager")
        self.userManager = UserManager()
        self.persistentContainer = PersistenceController.shared.container
        loadStreakData()
        print("🔥 StreakManager: StreakManager initialization complete")
    }
    
    // MARK: - Public Methods
    
        /// Records an activity and updates the streak
    func recordActivity() {
        let today = Date().startOfDay
        print("🔥 StreakManager: recordActivity() called for date: \(today)")

        // Check if we already recorded activity today
        if let lastDate = lastActivityDate, Calendar.current.isDate(lastDate, inSameDayAs: today) {
            print("🔥 StreakManager: Activity already recorded today, skipping")
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

        // Add to activity dates
        activityDates.insert(today)
        print("🔥 StreakManager: Added today to activity dates. Total activity dates: \(activityDates.count)")

        // Save to Core Data
        saveStreakData()
        saveActivityDates()
        
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

    /// Gets all activity dates
    func getActivityDates() -> Set<Date> {
        print("🔥 StreakManager: Returning \(activityDates.count) activity dates")
        print("🔥 StreakManager: Activity dates: \(activityDates)")
        return activityDates
    }
    
    /// Resets the streak (for testing or manual reset)
    func resetStreak() {
        currentStreak = 0
        longestStreak = 0
        lastActivityDate = nil
        activityDates.removeAll()
        saveStreakData()
        saveActivityDates()
        NotificationCenter.default.post(name: .streakUpdated, object: nil)
    }
    
    // MARK: - Private Methods
    
    private func loadStreakData() {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<StreakEntity> = StreakEntity.fetchRequest()
        
        do {
            let streaks = try context.fetch(fetchRequest)
            print("🔥 StreakManager: Found \(streaks.count) StreakEntity objects")
            if let streak = streaks.first {
                self.currentStreak = Int(streak.currentStreak)
                self.longestStreak = Int(streak.longestStreak)
                self.lastActivityDate = streak.lastActivityDate
                print("🔥 StreakManager: Loaded streak data - current: \(self.currentStreak), longest: \(self.longestStreak), lastActivity: \(self.lastActivityDate?.description ?? "nil")")
            } else {
                print("🔥 StreakManager: No StreakEntity found, using default values")
            }
        } catch {
            print("Failed to load streak data: \(error)")
        }

        loadActivityDates()
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

    private func loadActivityDates() {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<ActivityDateEntity> = ActivityDateEntity.fetchRequest()

        do {
            let activityDates = try context.fetch(fetchRequest)
            print("🔥 StreakManager: Loaded \(activityDates.count) ActivityDateEntity objects from Core Data")
            self.activityDates = Set(activityDates.compactMap { $0.date })
            print("🔥 StreakManager: Mapped to \(self.activityDates.count) activity dates")
            print("🔥 StreakManager: Activity dates after loading: \(self.activityDates)")
        } catch {
            print("Failed to load activity dates: \(error)")
        }
    }

    private func saveActivityDates() {
        let context = persistentContainer.viewContext
        print("🔥 StreakManager: Saving \(activityDates.count) activity dates to Core Data")

        // Clear existing activity dates
        let fetchRequest: NSFetchRequest<ActivityDateEntity> = ActivityDateEntity.fetchRequest()
        do {
            let existingDates = try context.fetch(fetchRequest)
            print("🔥 StreakManager: Clearing \(existingDates.count) existing ActivityDateEntity objects")
            for date in existingDates {
                context.delete(date)
            }
        } catch {
            print("Failed to clear existing activity dates: \(error)")
        }

        // Save new activity dates
        for date in activityDates {
            let activityDate = ActivityDateEntity(context: context)
            activityDate.id = UUID()
            activityDate.date = date
            print("🔥 StreakManager: Created ActivityDateEntity for date: \(date)")
        }

        do {
            try context.save()
            print("🔥 StreakManager: Successfully saved activity dates to Core Data")
        } catch {
            print("Failed to save activity dates: \(error)")
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
