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
        
        // Create an in-memory NSPersistentContainer for testing
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
            characterClass: .knight,
            weapon: .swordBroad,
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
            XCTAssertEqual(user?.characterClass, CharacterClass.knight.rawValue)
            XCTAssertEqual(user?.weapon, Weapon.swordBroad.rawValue)
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
        
        // Fetch and verify the level was updated
        userManager.fetchUser { user, error in
            XCTAssertNil(error)
            XCTAssertEqual(user?.level, 10)
        }
    }
    
    func testUpdateUserExperience() {
        testSaveUser()
        
        let updateExpectation = expectation(description: "User experience updated successfully")
        userManager.updateUserExperience(additionalExp: 100) { error in
            XCTAssertNil(error)
            updateExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
        
        // Fetch and verify the experience was updated
        userManager.fetchUser { user, error in
            XCTAssertNil(error)
            XCTAssertEqual(user?.exp, 100)
        }
    }
    
    func testUpdateUserExperience_AddMultiple() {
        testSaveUser()
        
        let updateExpectation = expectation(description: "User experience updated twice")

        userManager.updateUserExperience(additionalExp: 50) { error in
            XCTAssertNil(error)
            
            self.userManager.updateUserExperience(additionalExp: 75) { error in
                XCTAssertNil(error)
                
                self.userManager.fetchUser { user, error in
                    XCTAssertNil(error)
                    XCTAssertEqual(user?.exp, 125)
                    updateExpectation.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 2)
    }
}
