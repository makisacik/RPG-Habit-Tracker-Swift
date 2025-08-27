//
//  FirstTimeQuestService.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import Foundation

final class FirstTimeQuestService {
    static let shared = FirstTimeQuestService()
    
    private let userDefaults = UserDefaults.standard
    private let firstQuestCreatedKey = "firstQuestCreated"
    
    private init() {}
    
    /// Checks if the first quest has already been created
    var hasFirstQuestBeenCreated: Bool {
        return userDefaults.bool(forKey: firstQuestCreatedKey)
    }
    
    /// Creates the first quest for new users
    /// - Parameters:
    ///   - questDataService: The quest data service to save the quest
    ///   - completion: Completion handler with error if any
    func createFirstQuest(
        questDataService: QuestDataServiceProtocol,
        completion: @escaping (Error?) -> Void
    ) {
        // Check if first quest already exists
        if hasFirstQuestBeenCreated {
            completion(nil)
            return
        }
        
        // Check if there are already quests in the system
        questDataService.fetchAllQuests { [weak self] quests, error in
            if let error = error {
                completion(error)
                return
            }
            
            // If there are already quests, don't create the first quest
            if !quests.isEmpty {
                // Mark that the first quest has been created to avoid future attempts
                self?.userDefaults.set(true, forKey: self?.firstQuestCreatedKey ?? "firstQuestCreated")
                completion(nil)
                return
            }
            
            // Create the first quest with explicit date calculation
            let calendar = Calendar.current
            let today = Date()
            
            // Calculate due date as 7 days from today
            let dueDate = calendar.date(byAdding: .day, value: 7, to: today) ?? today
            
            // Format dates for debugging
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .full
            dateFormatter.timeStyle = .full
            
            let shortDateFormatter = DateFormatter()
            shortDateFormatter.dateStyle = .medium
            shortDateFormatter.timeStyle = .none
            
            print("📅 FirstTimeQuestService: Creating first quest")
            print("📅 FirstTimeQuestService: Today: \(shortDateFormatter.string(from: today))")
            print("📅 FirstTimeQuestService: Due date: \(shortDateFormatter.string(from: dueDate))")
            print("📅 FirstTimeQuestService: Calendar: \(calendar.identifier)")
            print("📅 FirstTimeQuestService: Timezone: \(TimeZone.current.identifier)")
            
            // Verify the date difference
            let daysDifference = calendar.dateComponents([.day], from: today, to: dueDate).day ?? 0
            print("📅 FirstTimeQuestService: Days difference: \(daysDifference)")
            
            let firstQuest = Quest(
                title: "first_quest_title".localized,
                isMainQuest: true,
                info: "first_quest_description".localized,
                difficulty: 1,
                creationDate: today,
                dueDate: dueDate,
                isActive: true,
                progress: 0,
                isCompleted: false,
                completionDate: nil,
                repeatType: .oneTime,
                tags: [],
                scheduledDays: []
            )
            
            // Create tasks for the first quest
            let taskTitles = [
                "first_quest_task_1".localized,
                "first_quest_task_2".localized
            ]
            
            // Save the quest
            questDataService.saveQuest(firstQuest, withTasks: taskTitles) { [weak self] error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("❌ FirstTimeQuestService: Error saving quest: \(error)")
                        completion(error)
                    } else {
                        print("✅ FirstTimeQuestService: Quest saved successfully")
                        
                        // Verify the quest was saved correctly by fetching it back
                        questDataService.fetchAllQuests { quests, fetchError in
                            if let fetchError = fetchError {
                                print("❌ FirstTimeQuestService: Error fetching quests after save: \(fetchError)")
                            } else if let savedQuest = quests.first(where: { $0.title == "first_quest_title".localized }) {
                                print("📅 FirstTimeQuestService: Saved quest due date: \(savedQuest.dueDate)")
                                print("📅 FirstTimeQuestService: Saved quest creation date: \(savedQuest.creationDate)")
                            }
                        }
                        
                        // Mark that the first quest has been created
                        self?.userDefaults.set(true, forKey: self?.firstQuestCreatedKey ?? "firstQuestCreated")
                        completion(nil)
                    }
                }
            }
        }
    }
    
    /// Resets the first quest flag (useful for testing)
    func resetFirstQuestFlag() {
        userDefaults.removeObject(forKey: firstQuestCreatedKey)
    }
}
