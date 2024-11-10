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
            dueDate: Date())
        
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
            dueDate: Date())
        
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
}
