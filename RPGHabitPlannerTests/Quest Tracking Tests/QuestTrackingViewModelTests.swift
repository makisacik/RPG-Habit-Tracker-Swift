//
//  QuestTrackingViewModelTests.swift
//  RPGHabitPlannerTests
//
//  Created by Mehmet Ali Kısacık on 16.11.2024.
//

import XCTest
@testable import RPGHabitPlanner

final class QuestTrackingViewModelTests: XCTestCase {
    var viewModel: QuestTrackingViewModel!
    var mockService: MockQuestDataService!
    
    override func setUp() {
        super.setUp()
        mockService = MockQuestDataService()
        viewModel = QuestTrackingViewModel(questDataService: mockService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        super.tearDown()
    }
    
    func testFetchQuests_Success() {
        let expectation = XCTestExpectation(description: "Quests fetched successfully")
        let quest = Quest(title: "Test Quest", isMainQuest: true, info: "Test Info", difficulty: 1, creationDate: Date(), dueDate: Date().addingTimeInterval(3600), isActive: true)
        mockService.mockQuests = [quest]
        
        viewModel.fetchQuests()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.quests.count, 1)
            XCTAssertEqual(self.viewModel.quests.first?.title, "Test Quest")
            XCTAssertNil(self.viewModel.errorMessage)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }

    func testFetchQuests_Failure() {
        let expectation = XCTestExpectation(description: "Quests fetch failed")
        let mockError = NSError(domain: "MockErrorDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "Fetch failed"])
        mockService.mockError = mockError
        
        viewModel.fetchQuests()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.errorMessage, "Fetch failed")
            XCTAssertTrue(self.viewModel.quests.isEmpty)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testMainQuestsFilter() {
        let expectation = XCTestExpectation(description: "Main quests filtered successfully")
        let mainQuest = Quest(title: "Main Quest", isMainQuest: true, info: "Info", difficulty: 2, creationDate: Date(), dueDate: Date().addingTimeInterval(3600), isActive: true)
        let sideQuest = Quest(title: "Side Quest", isMainQuest: false, info: "Info", difficulty: 1, creationDate: Date(), dueDate: Date().addingTimeInterval(3600), isActive: false)
        mockService.mockQuests = [mainQuest, sideQuest]
        
        viewModel.fetchQuests()
        viewModel.selectedStatus = .active

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.mainQuests.count, 1)
            XCTAssertEqual(self.viewModel.mainQuests.first?.title, "Main Quest")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }

    func testSideQuestsFilter() {
        let expectation = XCTestExpectation(description: "Side quests filtered successfully")
        let mainQuest = Quest(title: "Main Quest", isMainQuest: true, info: "Info", difficulty: 2, creationDate: Date(), dueDate: Date().addingTimeInterval(3600), isActive: true)
        let sideQuest = Quest(title: "Side Quest", isMainQuest: false, info: "Info", difficulty: 1, creationDate: Date(), dueDate: Date().addingTimeInterval(3600), isActive: false)
        mockService.mockQuests = [mainQuest, sideQuest]
        
        viewModel.fetchQuests()
        viewModel.selectedStatus = .inactive

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.sideQuests.count, 1)
            XCTAssertEqual(self.viewModel.sideQuests.first?.title, "Side Quest")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
