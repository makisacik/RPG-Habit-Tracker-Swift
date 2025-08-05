//
//  InventoryDataServiceProtocol.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import Foundation
import CoreData

protocol InventoryDataServiceProtocol {
    func fetchItems() -> [ItemEntity]
    func addItem(name: String, info: String, iconName: String)
    func removeItem(_ item: ItemEntity)
    func clearInventory()
}
