//
//  QuestsViewModelTests.swift
//  RPGHabitPlannerTests
//
//  Created by Mehmet Ali Kısacık on 16.11.2024.
//

import XCTest
@testable import RPGHabitPlanner

final class QuestsViewModelTests: XCTestCase {
    var viewModel: QuestsViewModel!
    var mockService: MockQuestDataService!

    override func setUp() {
        super.setUp()
        mockService = MockQuestDataService()
        viewModel = QuestsViewModel(questDataService: mockService, userManager: UserManager())
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        super.tearDown()
    }

    func testFetchQuests_Success() {
        let expectation = XCTestExpectation(description: "Quests fetched successfully")
        let quest = Quest(title: "Test Quest", isMainQuest: true, info: "Test Info", difficulty: 1, creationDate: Date(), dueDate: Date().addingTimeInterval(3600), isActive: true, progress: 60, reminderTimes: [], enableReminders: false)
        mockService.mockQuests = [quest]

        viewModel.fetchQuests()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.allQuests.count, 1)
            XCTAssertEqual(self.viewModel.allQuests.first?.title, "Test Quest")
            XCTAssertEqual(self.viewModel.allQuests.first?.progress, 60)
            XCTAssertNil(self.viewModel.alertMessage)
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
            XCTAssertEqual(self.viewModel.alertMessage, "Fetch failed")
            XCTAssertTrue(self.viewModel.allQuests.isEmpty)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    // TODO: These tests need to be updated to match the current QuestsViewModel implementation
    // The current implementation doesn't have selectedStatus, mainQuests, sideQuests, or updateQuestProgress methods
    /*
    func testMainQuestsFilter() {
        let expectation = XCTestExpectation(description: "Main quests filtered successfully")
        let mainQuest = Quest(title: "Main Quest", isMainQuest: true, info: "Info", difficulty: 2, creationDate: Date(), dueDate: Date().addingTimeInterval(3600), isActive: true, progress: 80, reminderTimes: [], enableReminders: false)
        let sideQuest = Quest(title: "Side Quest", isMainQuest: false, info: "Info", difficulty: 1, creationDate: Date(), dueDate: Date().addingTimeInterval(3600), isActive: false, progress: 20, reminderTimes: [], enableReminders: false)
        mockService.mockQuests = [mainQuest, sideQuest]

        viewModel.selectedStatus = .active
        viewModel.fetchQuests()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertEqual(self.viewModel.mainQuests.count, 1)
            XCTAssertEqual(self.viewModel.mainQuests.first?.title, "Main Quest")
            XCTAssertEqual(self.viewModel.mainQuests.first?.progress, 80)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testSideQuestsFilter() {
        let expectation = XCTestExpectation(description: "Side quests filtered successfully")
        let mainQuest = Quest(title: "Main Quest", isMainQuest: true, info: "Info", difficulty: 2, creationDate: Date(), dueDate: Date().addingTimeInterval(3600), isActive: true, progress: 80, reminderTimes: [], enableReminders: false)
        let sideQuest = Quest(title: "Side Quest", isMainQuest: false, info: "Info", difficulty: 1, creationDate: Date(), dueDate: Date().addingTimeInterval(3600), isActive: false, progress: 20, reminderTimes: [], enableReminders: false)
        mockService.mockQuests = [mainQuest, sideQuest]

        viewModel.fetchQuests()
        viewModel.selectedStatus = .inactive

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.sideQuests.count, 1)
            XCTAssertEqual(self.viewModel.sideQuests.first?.title, "Side Quest")
            XCTAssertEqual(self.viewModel.sideQuests.first?.progress, 20)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testUpdateQuestProgress_Increase() {
        let quest = Quest(
            title: "Test Quest",
            isMainQuest: true,
            info: "Test Info",
            difficulty: 1,
            creationDate: Date(),
            dueDate: Date().addingTimeInterval(3600),
            isActive: true,
            progress: 40,
            reminderTimes: [],
            enableReminders: false
        )
        mockService.mockQuests = [quest]
        viewModel.fetchQuests()

        let expectation = XCTestExpectation(description: "Increase quest progress")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.viewModel.updateQuestProgress(id: quest.id, by: 20)

            XCTAssertEqual(self.viewModel.quests.first?.progress, 60, "Quest progress should have increased by 20")
            XCTAssertNil(self.viewModel.errorMessage)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testUpdateQuestProgress_Decrease() {
        let quest = Quest(
            title: "Test Quest",
            isMainQuest: true,
            info: "Test Info",
            difficulty: 1,
            creationDate: Date(),
            dueDate: Date().addingTimeInterval(3600),
            isActive: true,
            progress: 60
        )
        mockService.mockQuests = [quest]
        viewModel.fetchQuests()

        let expectation = XCTestExpectation(description: "Decrease quest progress")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.viewModel.updateQuestProgress(id: quest.id, by: -20)

            XCTAssertEqual(self.viewModel.quests.first?.progress, 60, "Quest progress should have decreased by 20")
            XCTAssertNil(self.viewModel.errorMessage)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testUpdateQuestProgress_NotBelowZero() {
        let quest = Quest(
            title: "Test Quest",
            isMainQuest: true,
            info: "Test Info",
            difficulty: 1,
            creationDate: Date(),
            dueDate: Date().addingTimeInterval(3600),
            isActive: true,
            progress: 10
        )
        mockService.mockQuests = [quest]
        viewModel.fetchQuests()

        let expectation = XCTestExpectation(description: "Progress should not drop below 0")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.viewModel.updateQuestProgress(id: quest.id, by: -20)

            XCTAssertEqual(self.viewModel.quests.first?.progress, 0, "Quest progress should not be less than 0")
            XCTAssertNil(self.viewModel.errorMessage)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testUpdateQuestProgress_NotAbove100() {
        let quest = Quest(
            title: "Test Quest",
            isMainQuest: true,
            info: "Test Info",
            difficulty: 1,
            creationDate: Date(),
            dueDate: Date().addingTimeInterval(3600),
            isActive: true,
            progress: 90
        )
        mockService.mockQuests = [quest]
        viewModel.fetchQuests()

        let expectation = XCTestExpectation(description: "Progress should not exceed 100")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.viewModel.updateQuestProgress(id: quest.id, by: 20)

            XCTAssertEqual(self.viewModel.quests.first?.progress, 100, "Quest progress should not exceed 100")
            XCTAssertNil(self.viewModel.errorMessage)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }
    */
}
