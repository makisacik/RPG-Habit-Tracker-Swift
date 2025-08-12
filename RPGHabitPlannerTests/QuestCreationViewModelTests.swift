//
//  QuestCreationViewModelTests.swift
//  RPGHabitPlannerTests
//
//  Created by Mehmet Ali Kısacık on 17.11.2024.
//

import XCTest
@testable import RPGHabitPlanner

final class QuestCreationViewModelTests: XCTestCase {
    var mockQuestDataService: MockQuestDataService!
    var viewModel: QuestCreationViewModel!

    override func setUp() {
        super.setUp()
        mockQuestDataService = MockQuestDataService()
        viewModel = QuestCreationViewModel(questDataService: mockQuestDataService)
    }

    override func tearDown() {
        viewModel = nil
        mockQuestDataService = nil
        super.tearDown()
    }

    func testValidateInputs_whenTitleIsEmpty_returnsError() {
        viewModel.questTitle = ""
        viewModel.questDescription = "Description"

        let isValid = viewModel.validateInputs()

        XCTAssertFalse(isValid)
        XCTAssertEqual(viewModel.errorMessage, "Quest title cannot be empty.")
    }

    func testValidateInputs_whenTitleIsValidAndDescriptionIsEmpty_returnsTrue() {
        viewModel.questTitle = "Title"
        viewModel.questDescription = ""

        let isValid = viewModel.validateInputs()

        XCTAssertTrue(isValid)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testValidateInputs_whenTitleAndDescriptionAreValid_returnsTrue() {
        viewModel.questTitle = "Title"
        viewModel.questDescription = "Description"

        let isValid = viewModel.validateInputs()

        XCTAssertTrue(isValid)
        XCTAssertNil(viewModel.errorMessage)
    }

    @MainActor
    func testSaveQuest_whenSaveSucceeds_didSaveQuestIsTrue() {
        mockQuestDataService.mockError = nil

        viewModel.questTitle = "Title"
        viewModel.questDescription = "Description"
        viewModel.questDueDate = Date()
        viewModel.isMainQuest = true
        viewModel.difficulty = 3
        viewModel.isActiveQuest = true

        let expectation = self.expectation(description: "Save quest success")

        viewModel.saveQuest()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.viewModel.didSaveQuest)
            XCTAssertNil(self.viewModel.errorMessage)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    @MainActor
    func testSaveQuest_whenSaveFails_didSaveQuestIsFalse_andErrorMessageIsSet() {
        let error = NSError(domain: "MockQuestDataService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to save quest."])
        mockQuestDataService.mockError = error

        viewModel.questTitle = "Title"
        viewModel.questDescription = "Description"
        viewModel.questDueDate = Date()
        viewModel.isMainQuest = true
        viewModel.difficulty = 3
        viewModel.isActiveQuest = true

        let expectation = self.expectation(description: "Save quest failure")

        viewModel.saveQuest()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(self.viewModel.didSaveQuest)
            XCTAssertEqual(self.viewModel.errorMessage, "Failed to save quest.")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testResetInputs_resetsAllProperties() {
        viewModel.questTitle = "Title"
        viewModel.questDescription = "Description"
        viewModel.questDueDate = Date().addingTimeInterval(3600)
        viewModel.isMainQuest = true
        viewModel.difficulty = 5
        viewModel.isActiveQuest = true

        viewModel.resetInputs()

        XCTAssertEqual(viewModel.questTitle, "")
        XCTAssertEqual(viewModel.questDescription, "")
        XCTAssertTrue(Calendar.current.isDateInToday(viewModel.questDueDate))
        XCTAssertFalse(viewModel.isMainQuest)
        XCTAssertEqual(viewModel.difficulty, 3)
        XCTAssertFalse(viewModel.isActiveQuest)
    }
}
