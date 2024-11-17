//
//  QuestCoreDataServiceTests.swift
//  RPGHabitPlannerTests
//
//  Created by Mehmet Ali Kısacık on 2.11.2024.
//

import XCTest
@testable import RPGHabitPlanner

final class QuestCoreDataServiceTests: XCTestCase {
    func testSaveQuest() throws {
        let sut = QuestCoreDataService()
        let quest = Quest(
            title: "exampleTitle",
            isMainQuest: true,
            info: "info",
            difficulty: 3,
            creationDate: Date(),
            dueDate: Date(),
            isActive: true)
        
        sut.saveQuest(quest) { error in
            XCTAssertNil(error, "Error \(String(describing: error?.localizedDescription))")
        }
    }
    
    func testFetchAllQuests() throws {
        let sut = QuestCoreDataService()
        
        sut.fetchAllQuests { _, error in
            XCTAssertNil(error, "Error \(String(describing: error?.localizedDescription))")
        }
    }
    
    func testDeleteQuest() throws {
        let sut = QuestCoreDataService()
        let quest = Quest(
            title: "QuestToDelete",
            isMainQuest: false,
            info: "This quest will be deleted",
            difficulty: 2,
            creationDate: Date(),
            dueDate: Date(),
            isActive: true
        )
        
        sut.saveQuest(quest) { error in
            XCTAssertNil(error, "Error saving quest: \(String(describing: error?.localizedDescription))")
        }
        
        sut.deleteQuest(withId: quest.id) { error in
            XCTAssertNil(error, "Error deleting quest: \(String(describing: error?.localizedDescription))")
        }
        
        sut.fetchAllQuests { quests, error in
            XCTAssertNil(error, "Error fetching quests: \(String(describing: error?.localizedDescription))")
            XCTAssertFalse(quests.contains { $0.id == quest.id }, "Quest was not deleted")
        }
    }
    
    func testUpdateQuestCompletion() throws {
        let sut = QuestCoreDataService()
        let quest = Quest(
            title: "QuestToComplete",
            isMainQuest: false,
            info: "This quest will be marked as completed",
            difficulty: 2,
            creationDate: Date(),
            dueDate: Date(),
            isActive: true
        )
        
        // Save the quest
        sut.saveQuest(quest) { error in
            XCTAssertNil(error, "Error saving quest: \(String(describing: error?.localizedDescription))")
        }
        
        print("Quest ID to update: \(quest.id)")

        // Update the quest completion status
        sut.updateQuestCompletion(forId: quest.id, to: true) { error in
            XCTAssertNil(error, "Error updating quest completion: \(String(describing: error?.localizedDescription))")
        }
        
        // Fetch all quests and verify the update
        sut.fetchAllQuests { quests, error in
            print("Fetched Quests: \(quests.map { $0.id })")

            XCTAssertNil(error, "Error fetching quests: \(String(describing: error?.localizedDescription))")
            
            if let updatedQuest = quests.first(where: { $0.id == quest.id }) {
                XCTAssertTrue(updatedQuest.isCompleted, "Quest completion status was not updated")
            } else {
                XCTFail("Quest not found in fetched results")
            }
        }
    }
}
