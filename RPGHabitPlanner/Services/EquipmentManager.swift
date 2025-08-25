//
//  EquipmentManager.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 7.01.2025.
//

import Foundation
import CoreData
import Combine

// MARK: - Equipment Slot Enum

enum EquipmentSlot: String, CaseIterable, Identifiable {
    case bodyType = "BodyType"
    case hairStyle = "HairStyle"
    case hairColor = "HairColor"
    case eyeColor = "EyeColor"
    case outfit = "Outfit"
    case weapon = "Weapon"
    case accessory = "Accessory"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .bodyType: return String(localized: "equipment_body_type")
        case .hairStyle: return String(localized: "equipment_hair_style")
        case .hairColor: return String(localized: "equipment_hair_color")
        case .eyeColor: return String(localized: "equipment_eye_color")
        case .outfit: return String(localized: "equipment_outfit")
        case .weapon: return String(localized: "equipment_weapon")
        case .accessory: return String(localized: "equipment_accessory")
        }
    }

    var category: CustomizationCategory {
        return CustomizationCategory(rawValue: self.rawValue) ?? .bodyType
    }

    var allowsMultiple: Bool {
        // Currently only accessories might allow multiple items
        return self == .accessory
    }

    var isRequired: Bool {
        // All slots except accessory are required
        return self != .accessory
    }
}

// MARK: - Equipment Validation

struct EquipmentValidation {
    static func canEquip(item: CustomizationItemEntity, to slot: EquipmentSlot, for user: UserEntity) -> (canEquip: Bool, reason: String?) {
        // Check if item is unlocked
        guard item.isUnlocked else {
            return (false, String(localized: "item_not_unlocked"))
        }

        // Check if item category matches slot
        guard item.category == slot.rawValue else {
            return (false, String(localized: "item_category_mismatch"))
        }

        // Check if user owns the item
        guard item.owner == user else {
            return (false, String(localized: "item_not_owned"))
        }

        // Slot-specific validation
        switch slot {
        case .accessory:
            // Check if too many accessories are equipped
            let equippedAccessories = user.customizationItems?.allObjects as? [CustomizationItemEntity] ?? []
            let accessoryCount = equippedAccessories.filter { $0.category == EquipmentSlot.accessory.rawValue && $0.isEquipped }.count

            if accessoryCount >= 3 { // Max 3 accessories
                return (false, String(localized: "max_accessories_exceeded"))
            }
        default:
            break
        }

        return (true, nil)
    }

    static func getConflictingItems(for slot: EquipmentSlot, user: UserEntity) -> [CustomizationItemEntity] {
        let items = user.customizationItems?.allObjects as? [CustomizationItemEntity] ?? []
        return items.filter { item in
            item.category == slot.rawValue && item.isEquipped
        }
    }
}

// MARK: - Equipment Manager

final class EquipmentManager: ObservableObject {
    // MARK: - Singleton

    static let shared = EquipmentManager()

    // MARK: - Published Properties

    @Published var equippedItems: [EquipmentSlot: [CustomizationItemEntity]] = [:]
    @Published var currentCustomization = CharacterCustomization()

    // MARK: - Private Properties

    private let customizationService = CharacterCustomizationService()
    private let itemService = CustomizationItemService()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    private init() {
        setupNotifications()
    }

    private func setupNotifications() {
        NotificationCenter.default.publisher(for: .userDidUpdate)
            .sink { [weak self] _ in
                self?.refreshEquippedItems()
            }
            .store(in: &cancellables)
    }

    // MARK: - Equipment Management

    func loadEquippedItems(for user: UserEntity) {
        let items = itemService.fetchEquippedItems(for: user)

        // Group by equipment slot
        var groupedItems: [EquipmentSlot: [CustomizationItemEntity]] = [:]

        for item in items {
            if let slot = EquipmentSlot(rawValue: item.category ?? "") {
                if groupedItems[slot] == nil {
                    groupedItems[slot] = []
                }
                groupedItems[slot]?.append(item)
            }
        }

        DispatchQueue.main.async {
            self.equippedItems = groupedItems
            self.updateCurrentCustomization(for: user)
        }
    }

    func equipItem(_ item: CustomizationItemEntity, to slot: EquipmentSlot) -> Bool {
        guard let user = item.owner else { return false }

        // Validate the equipment
        let validation = EquipmentValidation.canEquip(item: item, to: slot, for: user)
        guard validation.canEquip else {
            print("❌ Cannot equip item: \(validation.reason ?? String(localized: "unknown_error"))")
            return false
        }

        // Handle slot-specific logic
        if !slot.allowsMultiple {
            // Unequip conflicting items
            let conflictingItems = EquipmentValidation.getConflictingItems(for: slot, user: user)
            for conflictingItem in conflictingItems {
                unequipItem(conflictingItem)
            }
        }

        // Equip the item
        itemService.equipItem(item)

        // Refresh equipped items
        loadEquippedItems(for: user)

        return true
    }

    func unequipItem(_ item: CustomizationItemEntity) {
        itemService.unequipItem(item)

        if let user = item.owner {
            loadEquippedItems(for: user)
        }
    }

    func unequipAllItems(for user: UserEntity, in slot: EquipmentSlot) {
        itemService.unequipAllItems(for: user, in: slot.category)
        loadEquippedItems(for: user)
    }

    // MARK: - Equipment Queries

    func getEquippedItem(for slot: EquipmentSlot) -> CustomizationItemEntity? {
        return equippedItems[slot]?.first
    }

    func getEquippedItems(for slot: EquipmentSlot) -> [CustomizationItemEntity] {
        return equippedItems[slot] ?? []
    }

    func isItemEquipped(_ item: CustomizationItemEntity) -> Bool {
        return item.isEquipped
    }

    func getEquipmentSummary(for user: UserEntity) -> [EquipmentSlot: CustomizationItemEntity?] {
        var summary: [EquipmentSlot: CustomizationItemEntity?] = [:]

        for slot in EquipmentSlot.allCases {
            summary[slot] = getEquippedItem(for: slot)
        }

        return summary
    }

    // MARK: - Customization Integration

    private func updateCurrentCustomization(for user: UserEntity) {
        guard let customizationEntity = customizationService.fetchCustomization(for: user) else {
            return
        }

        currentCustomization = customizationEntity.toCharacterCustomization()
    }

    func applyEquipmentToCustomization(for user: UserEntity) {
        var customization = CharacterCustomization()

        // Apply equipped items to customization
        for slot in EquipmentSlot.allCases {
            if let equippedItem = getEquippedItem(for: slot) {
                applyItemToCustomization(&customization, item: equippedItem, slot: slot)
            }
        }

        // Update the customization entity
        if let customizationEntity = customizationService.fetchCustomization(for: user) {
            customizationService.updateCustomization(customizationEntity, with: customization)
        }

        currentCustomization = customization
    }

    private func applyItemToCustomization(_ customization: inout CharacterCustomization, item: CustomizationItemEntity, slot: EquipmentSlot) {
        guard let itemName = item.assetName else { return }

        switch slot {
        case .bodyType:
            if let bodyType = BodyType(rawValue: itemName) {
                customization.bodyType = bodyType
            }
        case .hairStyle:
            if let hairStyle = HairStyle(rawValue: itemName) {
                customization.hairStyle = hairStyle
            }
        case .hairColor:
            if let hairColor = HairColor(rawValue: itemName) {
                customization.hairColor = hairColor
            }
        case .eyeColor:
            if let eyeColor = EyeColor(rawValue: itemName) {
                customization.eyeColor = eyeColor
            }
        case .outfit:
            if let outfit = Outfit(rawValue: itemName) {
                customization.outfit = outfit
            }
        case .weapon:
            if let weapon = CharacterWeapon(rawValue: itemName) {
                customization.weapon = weapon
            }
        case .accessory:
            if let accessory = Accessory(rawValue: itemName) {
                customization.accessory = accessory
            }
        }
    }

    private func refreshEquippedItems() {
        // This method will be called when user data changes
        UserManager().fetchUser { [weak self] user, _ in
            if let user = user {
                self?.loadEquippedItems(for: user)
            }
        }
    }
}
