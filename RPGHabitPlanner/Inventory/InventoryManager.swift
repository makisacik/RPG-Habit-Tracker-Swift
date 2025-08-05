//
//  InventoryManager.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import Foundation

struct Item: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let info: String
    let iconName: String

    init(name: String, info: String, iconName: String) {
        self.id = UUID()
        self.name = name
        self.info = info
        self.iconName = iconName
    }
}

final class InventoryManager {
    static let shared = InventoryManager()
    private let service: InventoryServiceProtocol

    private init(service: InventoryServiceProtocol = InventoryService()) {
        self.service = service
    }

    private let allItems: [Item] = [
        Item(name: "Armor", info: "Protective armor to increase defense", iconName: "icon_armor"),
        Item(name: "Arrows", info: "A bundle of arrows for ranged attacks", iconName: "icon_arrows"),
        Item(name: "Axe Spear", info: "Dual weapon for melee combat", iconName: "icon_axe_spear"),
        Item(name: "Axe", info: "Heavy axe for chopping or battle", iconName: "icon_axe"),
        Item(name: "Bag", info: "Extra storage for items", iconName: "icon_bag"),
        Item(name: "Bell", info: "Ringing bell, maybe magical", iconName: "icon_bell"),
        Item(name: "Bow", info: "Ranged weapon for precision attacks", iconName: "icon_bow"),
        Item(name: "Crown", info: "Symbol of royalty", iconName: "icon_crown"),
        Item(name: "Egg", info: "Mysterious egg, what’s inside?", iconName: "icon_egg"),
        Item(name: "Feather", info: "Light and delicate", iconName: "icon_feather"),
        Item(name: "Flask Blue", info: "Magical blue potion", iconName: "icon_flask_blue"),
        Item(name: "Flask Purple", info: "Magical purple potion", iconName: "icon_flask_purple"),
        Item(name: "Flash Green", info: "Instant energy boost", iconName: "icon_flash_green"),
        Item(name: "Flash Red", info: "Health regeneration potion", iconName: "icon_flash_red"),
        Item(name: "Gear", info: "Mechanical part for crafting", iconName: "icon_gear"),
        Item(name: "Gold", info: "Precious gold coin", iconName: "icon_gold"),
        Item(name: "Hammer", info: "Tool or weapon for strong strikes", iconName: "icon_hammer"),
        Item(name: "Helmet", info: "Protective headgear", iconName: "icon_helmet"),
        Item(name: "Helmet Witch", info: "Magical witch’s hat", iconName: "icon_helmet_witch"),
        Item(name: "Key Gold", info: "Opens golden locks", iconName: "icon_key_gold"),
        Item(name: "Key Silver", info: "Opens silver locks", iconName: "icon_key_silver"),
        Item(name: "Meat", info: "Cooked meat to restore health", iconName: "icon_meat"),
        Item(name: "Medal", info: "Award for great achievements", iconName: "icon_medal"),
        Item(name: "Pouch", info: "Small pouch for coins or trinkets", iconName: "icon_pouch"),
        Item(name: "Pumpkin", info: "Festive pumpkin", iconName: "icon_pumpkin")
    ]

    func getRandomReward() -> Item {
        return allItems.randomElement()!
    }

    func addToInventory(_ item: Item) {
        service.addItem(name: item.name, info: item.info, iconName: item.iconName)
    }

    func fetchInventory() -> [ItemEntity] {
        return service.fetchInventory()
    }

    func removeFromInventory(_ item: ItemEntity) {
        service.removeItem(item)
    }

    func clearInventory() {
        service.clearInventory()
    }
}
