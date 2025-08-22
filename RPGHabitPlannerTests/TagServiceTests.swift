//
//  TagServiceTests.swift
//  RPGHabitPlannerTests
//
//  Created by Mehmet Ali Kısacık on 14.08.2025.
//

import XCTest
import CoreData
@testable import RPGHabitPlanner

final class TagServiceTests: XCTestCase {
    var tagService: TagService!
    var container: NSPersistentContainer!

    override func setUpWithError() throws {
        container = NSPersistentContainer(name: "RPGHabitPlanner")
        container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load test store: \(error)")
            }
        }
        tagService = TagService(container: container)
    }

    override func tearDownWithError() throws {
        tagService = nil
        container = nil
    }

    func testCreateTag() throws {
        let expectation = XCTestExpectation(description: "Create tag")

        tagService.createTag(name: "Test Tag", icon: "star", color: "#FF0000") { tag, error in
            XCTAssertNil(error, "Should not have error")
            XCTAssertNotNil(tag, "Should create tag")
            XCTAssertEqual(tag?.name, "Test Tag")
            XCTAssertEqual(tag?.icon, "star")
            XCTAssertEqual(tag?.color, "#FF0000")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testCreateDuplicateTag() throws {
        let expectation1 = XCTestExpectation(description: "Create first tag")
        let expectation2 = XCTestExpectation(description: "Create duplicate tag")

        // Create first tag
        tagService.createTag(name: "Duplicate Tag", icon: "star", color: "#FF0000") { tag, error in
            XCTAssertNil(error, "Should not have error")
            XCTAssertNotNil(tag, "Should create tag")
            expectation1.fulfill()
        }

        // Try to create duplicate
        tagService.createTag(name: "Duplicate Tag", icon: "heart", color: "#00FF00") { tag, error in
            XCTAssertNotNil(error, "Should have error for duplicate")
            XCTAssertNil(tag, "Should not create duplicate tag")
            expectation2.fulfill()
        }

        wait(for: [expectation1, expectation2], timeout: 2.0)
    }

    func testFetchAllTags() throws {
        let expectation = XCTestExpectation(description: "Fetch all tags")

        // Create a tag first
        tagService.createTag(name: "Test Tag", icon: "star", color: "#FF0000") { _, _ in
            // Then fetch all tags
            self.tagService.fetchAllTags { tags, error in
                XCTAssertNil(error, "Should not have error")
                XCTAssertGreaterThan(tags.count, 0, "Should have at least one tag")
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 2.0)
    }
}
