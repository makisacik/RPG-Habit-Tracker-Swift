//
//  UserManagerTests.swift
//  RPGHabitPlannerTests
//
//  Created by Mehmet Ali Kısacık on 10.11.2024.
//

import XCTest
import CoreData
@testable import RPGHabitPlanner

final class UserManagerTests: XCTestCase {
    var userManager: UserManager!
    var testContainer: NSPersistentContainer!

    override func setUp() {
        super.setUp()

        testContainer = NSPersistentContainer(name: "RPGHabitPlanner")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        testContainer.persistentStoreDescriptions = [description]

        testContainer.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }

        userManager = UserManager(container: testContainer)
    }

    override func tearDown() {
        testContainer = nil
        userManager = nil
        super.tearDown()
    }

    func testSaveUser() {
        let expectation = self.expectation(description: "User saved successfully")

        userManager.saveUser(
            nickname: "TestUser",
            characterClass: "Custom",
            weapon: "char_sword_dagger_wood",
            level: 1,
            exp: 0
        ) { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)

        userManager.fetchUser { user, error in
            XCTAssertNil(error)
            XCTAssertNotNil(user)
            XCTAssertEqual(user?.nickname, "TestUser")
            XCTAssertEqual(user?.characterClass, "Custom")
            XCTAssertEqual(user?.weapon, "char_sword_dagger_wood")
            XCTAssertEqual(user?.level, 1)
            XCTAssertEqual(user?.exp, 0)
        }
    }

    func testFetchUser_WhenUserExists() {
        testSaveUser()

        userManager.fetchUser { user, error in
            XCTAssertNil(error)
            XCTAssertNotNil(user)
            XCTAssertEqual(user?.nickname, "TestUser")
        }
    }

    func testFetchUser_WhenUserDoesNotExist() {
        userManager.fetchUser { user, error in
            XCTAssertNil(error)
            XCTAssertNil(user)
        }
    }

    func testDeleteUser() {
        testSaveUser()

        let deleteExpectation = expectation(description: "User deleted successfully")
        userManager.deleteUser { error in
            XCTAssertNil(error)
            deleteExpectation.fulfill()
        }

        waitForExpectations(timeout: 1)

        // Verify user has been deleted
        userManager.fetchUser { user, error in
            XCTAssertNil(error)
            XCTAssertNil(user)
        }
    }

    func testUpdateUserLevel() {
        testSaveUser()

        let updateExpectation = expectation(description: "User level updated successfully")
        userManager.updateUserLevel(newLevel: 10) { error in
            XCTAssertNil(error)
            updateExpectation.fulfill()
        }

        waitForExpectations(timeout: 1)

        userManager.fetchUser { user, error in
            XCTAssertNil(error)
            XCTAssertEqual(user?.level, 10)
        }
    }

    func testUpdateUserExperience_LevelUp() {
        testSaveUser()

        let updateExpectation = expectation(description: "User experience updated successfully with level up")
        userManager.updateUserExperience(additionalExp: 150) { leveledUp, newLevel, error in
            XCTAssertNil(error)
            XCTAssertTrue(leveledUp)
            XCTAssertEqual(newLevel, 2)
            updateExpectation.fulfill()
        }

        waitForExpectations(timeout: 1)

        userManager.fetchUser { user, error in
            XCTAssertNil(error)
            XCTAssertEqual(user?.exp, 50)
            XCTAssertEqual(user?.level, 2)
        }
    }

    func testUpdateUserExperience_LevelUpMultipleTimes() {
        testSaveUser()

        let updateExpectation = expectation(description: "User experience updated successfully with multiple level ups")
        userManager.updateUserExperience(additionalExp: 250) { leveledUp, newLevel, error in
            XCTAssertNil(error)
            XCTAssertTrue(leveledUp)
            XCTAssertEqual(newLevel, 3)
            updateExpectation.fulfill()
        }

        waitForExpectations(timeout: 1)

        userManager.fetchUser { user, error in
            XCTAssertNil(error)
            XCTAssertEqual(user?.exp, 50)
            XCTAssertEqual(user?.level, 3)
        }
    }

    func testUpdateUserExperience_NoLevelUp() {
        testSaveUser()

        let updateExpectation = expectation(description: "User experience updated successfully without level up")
        userManager.updateUserExperience(additionalExp: 80) { leveledUp, newLevel, error in
            XCTAssertNil(error)
            XCTAssertFalse(leveledUp)
            XCTAssertEqual(newLevel, 1)
            updateExpectation.fulfill()
        }

        waitForExpectations(timeout: 1)

        userManager.fetchUser { user, error in
            XCTAssertNil(error)
            XCTAssertEqual(user?.exp, 80)
            XCTAssertEqual(user?.level, 1)
        }
    }
}
