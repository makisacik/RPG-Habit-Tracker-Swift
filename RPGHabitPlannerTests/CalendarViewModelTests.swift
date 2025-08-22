//
//  CalendarViewModelTests.swift
//  RPGHabitPlannerTests
//
//  Created by Assistant on 18.08.2025.
//

import XCTest
@testable import RPGHabitPlanner

final class CalendarViewModelTests: XCTestCase {
    var mockQuestDataService: MockQuestDataService!
    var mockUserManager: UserManager!
    var calendarViewModel: CalendarViewModel!

    override func setUpWithError() throws {
        mockQuestDataService = MockQuestDataService()
        mockUserManager = UserManager()
        calendarViewModel = CalendarViewModel(questDataService: mockQuestDataService, userManager: mockUserManager)
    }

    override func tearDownWithError() throws {
        mockQuestDataService = nil
        mockUserManager = nil
        calendarViewModel = nil
    }

    func testFinishedQuestsAreFilteredOut() throws {
        // Given: A quest that is finished
        let finishedQuest = Quest(
            title: "Finished Quest",
            isMainQuest: false,
            info: "A finished quest",
            difficulty: 1,
            creationDate: Date(),
            dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
            isActive: true,
            progress: 0,
            isFinished: true,
            isFinishedDate: Date(),
            repeatType: .oneTime
        )

        // Given: An active quest that is not finished
        let activeQuest = Quest(
            title: "Active Quest",
            isMainQuest: false,
            info: "An active quest",
            difficulty: 1,
            creationDate: Date(),
            dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
            isActive: true,
            progress: 0,
            isFinished: false,
            repeatType: .oneTime
        )

        // Set up mock data
        mockQuestDataService.mockQuests = [finishedQuest, activeQuest]

        // When: Fetching quests
        calendarViewModel.fetchQuests()

        // Then: Only the active quest should be returned for any date
        let today = Date()
        let items = calendarViewModel.items(for: today)

        // Should only contain the active quest
        XCTAssertEqual(items.count, 1, "Should only show active quests")
        XCTAssertEqual(items.first?.quest.title, "Active Quest", "Should show the active quest")
        XCTAssertFalse(items.first?.quest.isFinished ?? true, "Should not show finished quests")
    }

    func testFinishedQuestsAreNotShownInCalendar() throws {
        // Given: Multiple quests with different states
        let finishedQuest = Quest(
            title: "Finished Quest",
            isMainQuest: false,
            info: "A finished quest",
            difficulty: 1,
            creationDate: Date(),
            dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
            isActive: true,
            progress: 0,
            isFinished: true,
            isFinishedDate: Date(),
            repeatType: .oneTime
        )

        let activeQuest1 = Quest(
            title: "Active Quest 1",
            isMainQuest: false,
            info: "An active quest",
            difficulty: 1,
            creationDate: Date(),
            dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
            isActive: true,
            progress: 0,
            isFinished: false,
            repeatType: .daily
        )

        let activeQuest2 = Quest(
            title: "Active Quest 2",
            isMainQuest: false,
            info: "Another active quest",
            difficulty: 1,
            creationDate: Date(),
            dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
            isActive: true,
            progress: 0,
            isFinished: false,
            repeatType: .weekly
        )

        // Set up mock data
        mockQuestDataService.mockQuests = [finishedQuest, activeQuest1, activeQuest2]

        // When: Fetching quests
        calendarViewModel.fetchQuests()

        // Then: Only active quests should be returned
        let today = Date()
        let items = calendarViewModel.items(for: today)

        // Should only contain active quests
        XCTAssertEqual(items.count, 2, "Should only show active quests")

        let questTitles = items.map { $0.quest.title }.sorted()
        XCTAssertEqual(questTitles, ["Active Quest 1", "Active Quest 2"], "Should show only active quests")

        // Verify no finished quests are included
        for item in items {
            XCTAssertFalse(item.quest.isFinished, "No finished quests should be shown")
        }
    }

    func testDateRangeFilteringStillWorks() throws {
        // Given: An active quest that is outside the current date range
        let pastQuest = Quest(
            title: "Past Quest",
            isMainQuest: false,
            info: "A quest from the past",
            difficulty: 1,
            creationDate: Calendar.current.date(byAdding: .day, value: -10, to: Date())!,
            dueDate: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
            isActive: true,
            progress: 0,
            isFinished: false,
            repeatType: .oneTime
        )

        let futureQuest = Quest(
            title: "Future Quest",
            isMainQuest: false,
            info: "A quest from the future",
            difficulty: 1,
            creationDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())!,
            dueDate: Calendar.current.date(byAdding: .day, value: 10, to: Date())!,
            isActive: true,
            progress: 0,
            isFinished: false,
            repeatType: .oneTime
        )

        let currentQuest = Quest(
            title: "Current Quest",
            isMainQuest: false,
            info: "A current quest",
            difficulty: 1,
            creationDate: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
            dueDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
            isActive: true,
            progress: 0,
            isFinished: false,
            repeatType: .oneTime
        )

        // Set up mock data
        mockQuestDataService.mockQuests = [pastQuest, futureQuest, currentQuest]

        // When: Fetching quests for today
        calendarViewModel.fetchQuests()
        let today = Date()
        let items = calendarViewModel.items(for: today)

        // Then: Only the current quest should be shown (within date range)
        XCTAssertEqual(items.count, 1, "Should only show quests within date range")
        XCTAssertEqual(items.first?.quest.title, "Current Quest", "Should show the current quest")
    }

    func testWeeklyQuestShowsCompletedForEntireWeek() throws {
        // Given: A weekly quest that is completed for the current week
        let calendar = Calendar.current
        let today = Date()
        let weekAnchor = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!

        let weeklyQuest = Quest(
            title: "Weekly Quest",
            isMainQuest: false,
            info: "A weekly quest",
            difficulty: 1,
            creationDate: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
            dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
            isActive: true,
            progress: 0,
            isFinished: false,
            repeatType: .weekly,
            completions: [weekAnchor] // Mark as completed for this week
        )

        // Set up mock data
        mockQuestDataService.mockQuests = [weeklyQuest]

        // When: Fetching quests for different days in the same week
        calendarViewModel.fetchQuests()

        // Check Monday of the current week
        let monday = calendar.date(byAdding: .day, value: -calendar.component(.weekday, from: today) + 2, to: today)!
        let mondayItems = calendarViewModel.items(for: monday)

        // Check Wednesday of the current week
        let wednesday = calendar.date(byAdding: .day, value: -calendar.component(.weekday, from: today) + 4, to: today)!
        let wednesdayItems = calendarViewModel.items(for: wednesday)

        // Check Sunday of the current week
        let sunday = calendar.date(byAdding: .day, value: -calendar.component(.weekday, from: today) + 1, to: today)!
        let sundayItems = calendarViewModel.items(for: sunday)

        // Then: The quest should show as completed for all days in the week
        XCTAssertEqual(mondayItems.count, 1, "Should show quest on Monday")
        XCTAssertEqual(mondayItems.first?.state, .done, "Should show as completed on Monday")

        XCTAssertEqual(wednesdayItems.count, 1, "Should show quest on Wednesday")
        XCTAssertEqual(wednesdayItems.first?.state, .done, "Should show as completed on Wednesday")

        XCTAssertEqual(sundayItems.count, 1, "Should show quest on Sunday")
        XCTAssertEqual(sundayItems.first?.state, .done, "Should show as completed on Sunday")
    }
}
