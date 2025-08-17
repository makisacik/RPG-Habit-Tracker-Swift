//
//  QuestCoreDataServiceTests.swift
//  RPGHabitPlannerTests
//
//  Created by Mehmet Ali Kısacık on 2.11.2024.
//

import XCTest
@testable import RPGHabitPlanner

final class QuestCoreDataServiceTests: XCTestCase {
    var sut: QuestCoreDataService!
    
    override func setUp() {
        super.setUp()
        sut = QuestCoreDataService()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testSaveQuest() {
        let quest = Quest(
            title: "exampleTitle",
            isMainQuest: true,
            info: "info",
            difficulty: 3,
            creationDate: Date(),
            dueDate: Date(),
            isActive: true,
            progress: 50
        )
        
        let expectation = XCTestExpectation(description: "Save quest")
        sut.saveQuest(quest, withTasks: []) { error in
            XCTAssertNil(error, "Error \(String(describing: error?.localizedDescription))")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testFetchAllQuests() {
        let expectation = XCTestExpectation(description: "Fetch all quests")
        sut.fetchAllQuests { quests, error in
            XCTAssertNil(error, "Error \(String(describing: error?.localizedDescription))")
            XCTAssertNotNil(quests, "Quests should not be nil")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    func testFetchQuestById() {
        let quest = Quest(
            title: "FetchSpecificQuest",
            isMainQuest: false,
            info: "Specific quest for testing fetchQuestById",
            difficulty: 1,
            creationDate: Date(),
            dueDate: Date(),
            isActive: true,
            progress: 70
        )
        
        let saveExpectation = XCTestExpectation(description: "Save quest")
        sut.saveQuest(quest, withTasks: []) { error in
            XCTAssertNil(error, "Error saving quest: \(String(describing: error?.localizedDescription))")
            saveExpectation.fulfill()
        }
        wait(for: [saveExpectation], timeout: 2.0)
        
        let fetchExpectation = XCTestExpectation(description: "Fetch quest by ID")
        sut.fetchQuestById(quest.id) { fetchedQuest, error in
            XCTAssertNil(error, "Error fetching quest by ID: \(String(describing: error?.localizedDescription))")
            XCTAssertNotNil(fetchedQuest, "Fetched quest should not be nil")
            XCTAssertEqual(fetchedQuest?.id, quest.id, "Fetched quest ID should match")
            XCTAssertEqual(fetchedQuest?.progress, 70, "Fetched quest progress should match")
            fetchExpectation.fulfill()
        }
        wait(for: [fetchExpectation], timeout: 2.0)
    }
    
    func testDeleteQuest() {
        let quest = Quest(
            title: "QuestToDelete",
            isMainQuest: false,
            info: "This quest will be deleted",
            difficulty: 2,
            creationDate: Date(),
            dueDate: Date(),
            isActive: true,
            progress: 30
        )
        
        let saveExpectation = XCTestExpectation(description: "Save quest to delete")
        sut.saveQuest(quest, withTasks: []) { error in
            XCTAssertNil(error, "Error saving quest: \(String(describing: error?.localizedDescription))")
            saveExpectation.fulfill()
        }
        wait(for: [saveExpectation], timeout: 2.0)
        
        let deleteExpectation = XCTestExpectation(description: "Delete quest")
        sut.deleteQuest(withId: quest.id) { error in
            XCTAssertNil(error, "Error deleting quest: \(String(describing: error?.localizedDescription))")
            deleteExpectation.fulfill()
        }
        wait(for: [deleteExpectation], timeout: 2.0)
        
        let fetchExpectation = XCTestExpectation(description: "Fetch all quests after deletion")
        sut.fetchAllQuests { quests, error in
            XCTAssertNil(error, "Error fetching quests: \(String(describing: error?.localizedDescription))")
            XCTAssertFalse(quests.contains { $0.id == quest.id }, "Quest was not deleted")
            fetchExpectation.fulfill()
        }
        wait(for: [fetchExpectation], timeout: 2.0)
    }
    
    func testUpdateQuest() {
        let quest = Quest(
            title: "QuestToUpdate",
            isMainQuest: false,
            info: "This quest will be updated",
            difficulty: 2,
            creationDate: Date(),
            dueDate: Date(),
            isActive: true,
            progress: 20
        )
        
        let saveExpectation = XCTestExpectation(description: "Save quest to update")
        sut.saveQuest(quest, withTasks: []) { error in
            XCTAssertNil(error, "Error saving quest: \(String(describing: error?.localizedDescription))")
            saveExpectation.fulfill()
        }
        wait(for: [saveExpectation], timeout: 2.0)
        
        let updatedTitle = "UpdatedTitle"
        let updatedIsMainQuest = true
        let updatedDifficulty = 5
        let updatedDueDate = Calendar.current.date(byAdding: .day, value: 7, to: quest.dueDate)!
        let updatedIsActive = false
        let updatedProgress = 90
        
        let updateExpectation = XCTestExpectation(description: "Update quest fields")
        sut.updateQuest(
            withId: quest.id,
            title: updatedTitle,
            isMainQuest: updatedIsMainQuest,
            info: "",
            difficulty: updatedDifficulty,
            dueDate: updatedDueDate,
            isActive: updatedIsActive,
            progress: updatedProgress,
            repeatType: nil,
            tasks: nil,
            tags: nil,
            showProgress: nil
        ) { error in
            XCTAssertNil(error, "Error updating quest: \(String(describing: error?.localizedDescription))")
            updateExpectation.fulfill()
        }
        wait(for: [updateExpectation], timeout: 2.0)
        
        let fetchExpectation = XCTestExpectation(description: "Fetch quest to verify updates")
        sut.fetchQuestById(quest.id) { updatedQuest, error in
            XCTAssertNil(error, "Error fetching updated quest: \(String(describing: error?.localizedDescription))")
            XCTAssertNotNil(updatedQuest, "Updated quest should not be nil")
            XCTAssertEqual(updatedQuest?.title, updatedTitle, "Quest title was not updated correctly")
            XCTAssertEqual(updatedQuest?.isMainQuest, updatedIsMainQuest, "Quest isMainQuest flag was not updated correctly")
            XCTAssertEqual(updatedQuest?.difficulty, updatedDifficulty, "Quest difficulty was not updated correctly")
            XCTAssertEqual(updatedQuest?.dueDate, updatedDueDate, "Quest due date was not updated correctly")
            XCTAssertEqual(updatedQuest?.isActive, updatedIsActive, "Quest isActive flag was not updated correctly")
            XCTAssertEqual(updatedQuest?.progress, updatedProgress, "Quest progress was not updated correctly")
            fetchExpectation.fulfill()
        }
        wait(for: [fetchExpectation], timeout: 2.0)
    }
}
