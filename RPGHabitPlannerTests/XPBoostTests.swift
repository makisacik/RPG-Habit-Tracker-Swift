//
//  XPBoostTests.swift
//  RPGHabitPlannerTests
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import XCTest
@testable import RPGHabitPlanner

final class XPBoostTests: XCTestCase {
    var inventoryManager: InventoryManager!
    var mockService: MockInventoryService!

    override func setUpWithError() throws {
        super.setUp()
        mockService = MockInventoryService()
        inventoryManager = InventoryManager.shared
        // Inject mock service for testing
        // Note: In a real implementation, you'd want to make the service injectable
    }

    override func tearDownWithError() throws {
        inventoryManager = nil
        mockService = nil
        super.tearDown()
    }

    // MARK: - Item Type Detection Tests

    func testHealthPotionDetection() throws {
        let healthPotion = ItemEntity()
        healthPotion.name = String(localized: "vitality_draught")
        healthPotion.info = "Restores health"
        healthPotion.iconName = "potion_health"

        XCTAssertTrue(inventoryManager.isConsumable(healthPotion))
        XCTAssertFalse(inventoryManager.isBooster(healthPotion))
        XCTAssertFalse(inventoryManager.isCollectible(healthPotion))
    }

    func testXPBoostDetection() throws {
        let xpBoost = ItemEntity()
        xpBoost.name = String(localized: "scholars_insight")
        xpBoost.info = "Increases XP gain"
        xpBoost.iconName = "potion_xp"

        XCTAssertTrue(inventoryManager.isBooster(xpBoost))
        XCTAssertFalse(inventoryManager.isConsumable(xpBoost))
        XCTAssertFalse(inventoryManager.isCollectible(xpBoost))
    }

    func testCollectibleDetection() throws {
        let collectible = ItemEntity()
        collectible.name = "Sword"
        collectible.info = "A sharp sword"
        collectible.iconName = "sword"

        XCTAssertTrue(inventoryManager.isCollectible(collectible))
        XCTAssertFalse(inventoryManager.isConsumable(collectible))
        XCTAssertFalse(inventoryManager.isBooster(collectible))
    }

    func testUnknownItemType() throws {
        let unknownItem = ItemEntity()
        unknownItem.name = "Unknown Item"
        unknownItem.info = "Unknown item"
        unknownItem.iconName = "unknown"

        XCTAssertNil(inventoryManager.getItemType(unknownItem))
    }

    // MARK: - Item Database Tests

    func testItemDatabaseHealthPotions() throws {
        let healthPotions = ItemDatabase.allHealthPotions
        XCTAssertEqual(healthPotions.count, 5)

        let potionNames = healthPotions.map { $0.name }
        XCTAssertTrue(potionNames.contains(String(localized: "lesser_healing_elixir")))
        XCTAssertTrue(potionNames.contains(String(localized: "vitality_draught")))
        XCTAssertTrue(potionNames.contains(String(localized: "greater_restoration_tonic")))
        XCTAssertTrue(potionNames.contains(String(localized: "supreme_life_essence")))
        XCTAssertTrue(potionNames.contains(String(localized: "phoenix_tears")))
    }

    func testItemDatabaseXPBoosts() throws {
        let xpBoosts = ItemDatabase.allXPBoosts
        XCTAssertEqual(xpBoosts.count, 4)

        let boostNames = xpBoosts.map { $0.name }
        XCTAssertTrue(boostNames.contains(String(localized: "wisdoms_breath")))
        XCTAssertTrue(boostNames.contains(String(localized: "scholars_insight")))
        XCTAssertTrue(boostNames.contains(String(localized: "masters_enlightenment")))
        XCTAssertTrue(boostNames.contains(String(localized: "ancient_knowledge_essence")))
    }

    func testItemDatabaseCoinBoosts() throws {
        let coinBoosts = ItemDatabase.allCoinBoosts
        XCTAssertEqual(coinBoosts.count, 4)

        let boostNames = coinBoosts.map { $0.name }
        XCTAssertTrue(boostNames.contains(String(localized: "merchants_blessing")))
        XCTAssertTrue(boostNames.contains(String(localized: "wealth_attractor")))
        XCTAssertTrue(boostNames.contains(String(localized: "golden_fortune")))
        XCTAssertTrue(boostNames.contains(String(localized: "dragons_hoard_essence")))
    }

    func testItemDatabaseCollectibles() throws {
        let collectibles = ItemDatabase.allCollectibles
        XCTAssertGreaterThan(collectibles.count, 0)

        // Check that all collectibles have the correct item type
        for collectible in collectibles {
            XCTAssertEqual(collectible.itemType, .collectible)
        }
    }

    func testItemDatabaseFindItem() throws {
        let itemDatabase = ItemDatabase.shared

        // Test finding existing item
        let foundItem = itemDatabase.findItem(by: String(localized: "vitality_draught"))
        XCTAssertNotNil(foundItem)
        XCTAssertEqual(foundItem?.name, String(localized: "vitality_draught"))

        // Test finding non-existing item
        let notFoundItem = itemDatabase.findItem(by: "Non Existent Item")
        XCTAssertNil(notFoundItem)
    }

    func testItemDatabaseGetItemsByType() throws {
        let itemDatabase = ItemDatabase.shared

        let consumables = itemDatabase.getItems(of: .consumable)
        XCTAssertGreaterThan(consumables.count, 0)
        for item in consumables {
            XCTAssertEqual(item.itemType, .consumable)
        }

        let boosters = itemDatabase.getItems(of: .booster)
        XCTAssertGreaterThan(boosters.count, 0)
        for item in boosters {
            XCTAssertEqual(item.itemType, .booster)
        }

        let collectibles = itemDatabase.getItems(of: .collectible)
        XCTAssertGreaterThan(collectibles.count, 0)
        for item in collectibles {
            XCTAssertEqual(item.itemType, .collectible)
        }
    }

    func testItemDatabaseGetItemsByRarity() throws {
        let itemDatabase = ItemDatabase.shared

        let commonItems = itemDatabase.getItems(of: .common)
        XCTAssertGreaterThan(commonItems.count, 0)
        for item in commonItems {
            XCTAssertEqual(item.rarity, .common)
        }

        let legendaryItems = itemDatabase.getItems(of: .legendary)
        XCTAssertGreaterThan(legendaryItems.count, 0)
        for item in legendaryItems {
            XCTAssertEqual(item.rarity, .legendary)
        }
    }

    // MARK: - Item Creation Tests

    func testHealthPotionCreation() throws {
        let potion = Item.consumable(
            name: "Test Health Potion",
            description: "A test health potion",
            iconName: "icon_flask_red",
            value: 100,
            usageData: .healthPotion(healAmount: 50)
        )

        XCTAssertEqual(potion.name, "Test Health Potion")
        XCTAssertEqual(potion.itemType, .consumable)
        XCTAssertEqual(potion.value, 100)
        XCTAssertEqual(potion.iconName, "icon_flask_red")

        if case .healthPotion(let healAmount) = potion.usageData {
            XCTAssertEqual(healAmount, 50)
        } else {
            XCTFail("Health potion should have healthPotion usage data")
        }
    }

    func testXPBoostCreation() throws {
        let boost = Item.booster(
            name: "Test XP Boost",
            description: "A test XP boost",
            iconName: "icon_flask_blue",
            value: 200,
            usageData: .xpBoost(multiplier: 2.0, duration: 3600)
        )

        XCTAssertEqual(boost.name, "Test XP Boost")
        XCTAssertEqual(boost.itemType, .booster)
        XCTAssertEqual(boost.value, 200)
        XCTAssertEqual(boost.iconName, "icon_flask_blue")

        if case .xpBoost(let multiplier, let duration) = boost.usageData {
            XCTAssertEqual(multiplier, 2.0)
            XCTAssertEqual(duration, 3600)
        } else {
            XCTFail("XP boost should have xpBoost usage data")
        }
    }

    func testCoinBoostCreation() throws {
        let boost = Item.booster(
            name: "Test Coin Boost",
            description: "A test coin boost",
            iconName: "icon_flask_purple",
            value: 150,
            usageData: .coinBoost(multiplier: 1.5, duration: 1800)
        )

        XCTAssertEqual(boost.name, "Test Coin Boost")
        XCTAssertEqual(boost.itemType, .booster)
        XCTAssertEqual(boost.value, 150)
        XCTAssertEqual(boost.iconName, "icon_flask_purple")

        if case .coinBoost(let multiplier, let duration) = boost.usageData {
            XCTAssertEqual(multiplier, 1.5)
            XCTAssertEqual(duration, 1800)
        } else {
            XCTFail("Coin boost should have coinBoost usage data")
        }
    }

    func testCollectibleCreation() throws {
        let collectible = Item.collectible(
            name: "Test Sword",
            description: "A test sword",
            iconName: "test_sword",
            value: 50,
            collectionCategory: "Weapons",
            isRare: true
        )

        XCTAssertEqual(collectible.name, "Test Sword")
        XCTAssertEqual(collectible.itemType, .collectible)
        XCTAssertEqual(collectible.collectionCategory, "Weapons")
        XCTAssertTrue(collectible.isRare)
        XCTAssertNil(collectible.usageData) // Collectibles don't have usage data
    }
}

// MARK: - Mock Inventory Service

class MockInventoryService: InventoryServiceProtocol {
    var items: [ItemEntity] = []

    func fetchInventory() -> [ItemEntity] {
        return items
    }

    func addItem(name: String, info: String, iconName: String, itemType: String?, gearCategory: String?, rarity: String?, value: Int32, collectionCategory: String?, isRare: Bool) {
        let item = ItemEntity()
        item.name = name
        item.info = info
        item.iconName = iconName
        item.itemType = itemType
        item.gearCategory = gearCategory
        item.rarity = rarity
        item.value = value
        item.collectionCategory = collectionCategory
        item.isRare = isRare
        items.append(item)
    }

    func removeItem(_ item: ItemEntity) {
        items.removeAll { $0.name == item.name }
    }

    func clearInventory() {
        items.removeAll()
    }
}
