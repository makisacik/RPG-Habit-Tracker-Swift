//
//  CharacterAssetManager.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 7.01.2025.
//

import Foundation
import SwiftUI

// MARK: - Asset Category Enum

public enum AssetCategory: String, CaseIterable, Identifiable {
    case bodyType = "BodyType"
    case hairStyle = "HairStyle"
    case hairBackStyle = "HairBackStyle"
    case hairColor = "HairColor"
    case eyeColor = "EyeColor"
    case outfit = "Outfit"
    case weapon = "Weapon"
    case accessory = "Accessory"
    case head = "Head"
    case headGear = "HeadGear"
    case shield = "Shield"
    case wings = "Wings"
    case mustache = "Mustache"
    case flower = "Flower"
    case pet = "Pet"

    public var id: String { rawValue }

    var displayName: String {
        switch self {
        case .bodyType: return "character_asset_body_type".localized
        case .hairStyle: return "character_asset_hair_style".localized
        case .hairBackStyle: return "character_asset_hair_back_style".localized
        case .hairColor: return "character_asset_hair_color".localized
        case .eyeColor: return "character_asset_eye_color".localized
        case .outfit: return "character_asset_outfit".localized
        case .weapon: return "character_asset_weapon".localized
        case .accessory: return "character_asset_accessory".localized
        case .head: return "character_asset_head".localized
        case .headGear: return "character_asset_head_gear".localized
        case .shield: return "character_asset_shield".localized
        case .wings: return "character_asset_wings".localized
        case .mustache: return "character_asset_mustache".localized
        case .flower: return "character_asset_flower".localized
        case .pet: return "character_asset_pet".localized
        }
    }

    var icon: String {
        switch self {
        case .bodyType: return "person.fill"
        case .hairStyle: return "scissors"
        case .hairBackStyle: return "scissors"
        case .hairColor: return "paintbrush.fill"
        case .eyeColor: return "eye.fill"
        case .outfit: return "icon_armor"
        case .weapon: return "icon_sword"
        case .accessory: return "crown.fill"
        case .head: return "icon_helmet"
        case .headGear: return "icon_helmet"
        case .shield: return "icon_shield"
        case .wings: return "icon_wing"
        case .mustache: return "mustache"
        case .flower: return "leaf.fill"
        case .pet: return "pawprint.fill"
        }
    }
    
    // Check if this category is a gear category (should have rarity)
    var isGearCategory: Bool {
        switch self {
        case .head, .headGear, .outfit, .weapon, .shield, .wings, .pet:
            return true
        case .bodyType, .hairStyle, .hairBackStyle, .hairColor, .eyeColor, .accessory, .mustache, .flower:
            return false
        }
    }
}

// MARK: - Asset Rarity Enum

public enum AssetRarity: String, CaseIterable, Identifiable {
    case common = "common"
    case uncommon = "uncommon"
    case rare = "rare"
    case epic = "epic"
    case legendary = "legendary"

    public var id: String { rawValue }

    var color: Color {
        switch self {
        case .common: return .gray
        case .uncommon: return .green
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .orange
        }
    }

    var borderColor: Color {
        switch self {
        case .common: return .gray.opacity(0.8)
        case .uncommon: return .green.opacity(0.8)
        case .rare: return .blue.opacity(0.8)
        case .epic: return .purple.opacity(0.8)
        case .legendary: return .orange.opacity(0.8)
        }
    }

    var glowColor: Color {
        switch self {
        case .common: return .clear
        case .uncommon: return .green.opacity(0.3)
        case .rare: return .blue.opacity(0.3)
        case .epic: return .purple.opacity(0.3)
        case .legendary: return .orange.opacity(0.5)
        }
    }

    var basePriceMultiplier: Double {
        switch self {
        case .common: return 1.0
        case .uncommon: return 2.0
        case .rare: return 5.0
        case .epic: return 10.0
        case .legendary: return 25.0
        }
    }
}

// MARK: - Character Asset Manager

final class CharacterAssetManager: ObservableObject {
    static let shared = CharacterAssetManager()

    // MARK: - Asset Cache

    private var imageCache: [String: UIImage] = [:]
    private let cacheQueue = DispatchQueue(label: "asset-cache", qos: .utility)

    private init() {
        preloadCommonAssets()
    }

    // MARK: - Asset Loading

    /// Loads an asset image with caching
    func loadAsset(named imageName: String) -> UIImage? {
        // Check cache first
        if let cachedImage = imageCache[imageName] {
            return cachedImage
        }

        // Load from bundle
        guard let image = UIImage(named: imageName) else {
            print("⚠️ Asset not found: \(imageName)")
            return nil
        }

        // Cache the image
        cacheQueue.async { [weak self] in
            self?.imageCache[imageName] = image
        }

        return image
    }

    /// Preloads commonly used assets
    private func preloadCommonAssets() {
        cacheQueue.async { [weak self] in
            let commonAssets = [
                // Default body types (skin colors)
                BodyType.bodyWhite.rawValue,
                BodyType.bodyBlue.rawValue,

                // Default hair styles
                HairStyle.hair1Brown.rawValue,
                HairStyle.hair1Black.rawValue,

                // Default outfits
                Outfit.outfitVillager.rawValue,
                Outfit.outfitVillagerBlue.rawValue,

                // Default weapons
                CharacterWeapon.swordWood.rawValue,
                CharacterWeapon.swordIron.rawValue,

                // Default eye colors
                EyeColor.eyeBlack.rawValue,
                EyeColor.eyeBlue.rawValue
            ]

            for assetName in commonAssets {
                _ = self?.loadAsset(named: assetName)
            }
        }
    }

    // MARK: - Asset Information

    /// Gets a single asset by name
    func getAsset(byName assetName: String) -> AssetItem? {
        // Try to find the asset in any category
        for category in AssetCategory.allCases {
            let assets = getAvailableAssets(for: category)
            if let asset = assets.first(where: { $0.id == assetName || $0.imageName == assetName }) {
                return asset
            }
        }
        return nil
    }

    /// Gets all available assets for a category
    func getAvailableAssets(for category: AssetCategory) -> [AssetItem] {
        switch category {
        case .bodyType:
            return BodyType.allCases.map { AssetItem(id: $0.rawValue, name: $0.displayName, imageName: $0.rawValue, previewImage: $0.previewImageName, category: category, rarity: .common) }
        case .hairStyle:
            return HairStyle.allCases.map { AssetItem(id: $0.rawValue, name: $0.displayName, imageName: $0.rawValue, previewImage: $0.previewImageName, category: category, rarity: getRarity(for: $0.rawValue, category: category)) }
        case .hairBackStyle:
            return HairBackStyle.allCases.map { AssetItem(id: $0.rawValue, name: $0.displayName, imageName: $0.rawValue, previewImage: $0.previewImageName, category: category, rarity: getRarity(for: $0.rawValue, category: category)) }
        case .hairColor:
            return HairColor.allCases.map { AssetItem(id: $0.rawValue, name: $0.displayName, imageName: $0.rawValue, previewImage: $0.previewImageName, category: category, rarity: .common) }
        case .eyeColor:
            return EyeColor.allCases.map { AssetItem(id: $0.rawValue, name: $0.displayName, imageName: $0.rawValue, previewImage: $0.previewImageName, category: category, rarity: .common) }
        case .outfit:
            return Outfit.allCases.map { AssetItem(id: $0.rawValue, name: $0.displayName, imageName: $0.rawValue, previewImage: $0.previewImageName, category: category, rarity: getRarity(for: $0.rawValue, category: category)) }
        case .weapon:
            return CharacterWeapon.allCases.map { AssetItem(id: $0.rawValue, name: $0.displayName, imageName: $0.rawValue, previewImage: $0.previewImageName, category: category, rarity: getRarity(for: $0.rawValue, category: category)) }
        case .accessory:
            // Filter out pets, wings, and helmets from accessories
            return Accessory.allCases.filter { accessory in
                !accessory.rawValue.contains("pet") &&
                !accessory.rawValue.contains("wings") &&
                !accessory.rawValue.contains("helmet")
            }.map { AssetItem(id: $0.rawValue, name: $0.displayName, imageName: $0.rawValue, previewImage: $0.previewImageName, category: category, rarity: getRarity(for: $0.rawValue, category: category)) }
        case .head:
            // Return helmet assets from HeadGear enum
            return HeadGear.allCases.map { AssetItem(id: $0.rawValue, name: $0.displayName, imageName: $0.rawValue, previewImage: $0.previewImageName, category: category, rarity: getRarity(for: $0.rawValue, category: category)) }
        case .headGear:
            return HeadGear.allCases.map { AssetItem(id: $0.rawValue, name: $0.displayName, imageName: $0.rawValue, previewImage: $0.previewImageName, category: category, rarity: getRarity(for: $0.rawValue, category: category)) }
        case .shield:
            return Shield.allCases.map { AssetItem(id: $0.rawValue, name: $0.displayName, imageName: $0.rawValue, previewImage: $0.previewImageName, category: category, rarity: getRarity(for: $0.rawValue, category: category)) }
        case .wings:
            return [] // Wing items will be handled separately
        case .mustache:
            return Mustache.allCases.map { AssetItem(id: $0.rawValue, name: $0.displayName, imageName: $0.rawValue, previewImage: $0.previewImageName, category: category, rarity: getRarity(for: $0.rawValue, category: category)) }
        case .flower:
            return Flower.allCases.map { AssetItem(id: $0.rawValue, name: $0.displayName, imageName: $0.rawValue, previewImage: $0.previewImageName, category: category, rarity: getRarity(for: $0.rawValue, category: category)) }
        case .pet:
            return Pet.allCases.map { AssetItem(id: $0.rawValue, name: $0.displayName, imageName: $0.rawValue, previewImage: $0.previewImageName, category: category, rarity: getRarity(for: $0.rawValue, category: category)) }
        }
    }


    /// Determines rarity based on asset name - only for gear items
    private func getRarity(for assetName: String, category: AssetCategory) -> AssetRarity {
        // Only gear items should have rarity
        guard category.isGearCategory else {
            return .common // Non-gear items don't have rarity
        }
        
        let name = assetName.lowercased()
        
        // Define rarity mappings for specific items
        let rarityMappings: [String: AssetRarity] = [
            // Head items
            "helmet_red": .epic, // Crimson Crest
            "helmet_iron": .epic, // Ironclad Crown
            "helmet_hood": .rare, // Shadow Veil

            // Outfits
            "outfit_villager_blue": .common, // Azure Tunic
            "outfit_wizard": .rare, // Arcane Robes
            "outfit_dress": .rare, // Silken Grace
            "outfit_fire": .legendary, // Inferno Mantle
            "outfit_red": .legendary, // Crimson Raiment
            "outfit_bat": .epic, // Nightwing Shroud
            "outfit_hoodie": .uncommon, // Comfort Cloak

            // Shields
            "shield_wood": .uncommon, // Oakheart Ward
            "shield_red": .rare, // Crimson Ward
            "shield_gold": .epic, // Golden Aegis

            // Weapons
            "sword_wood": .common, // Oakheart Blade
            "sword_iron": .common, // Ironclad Edge
            "sword_steel": .uncommon, // Steel Serpent
            "sword_copper": .uncommon, // Copper Fang
            "sword_axe_small": .uncommon, // Storm Hatchet
            "sword_gold": .rare, // Golden Dawn
            "sword_red": .epic, // Crimson Fang
            "sword_red_2": .legendary, // Blazing Fang
            "sword_axe": .epic, // Thunder Axe
            "sword_mace": .epic, // Iron Maiden
            "sword_whip": .epic, // Viper's Lash
            "sword_staff": .legendary, // Arcane Staff

            // Pets
            "pet_chicken": .uncommon, // Golden Cluck
            "pet_cat": .epic, // Shadowpaw and Whiskerwind

            // Wings
            "wings_white": .epic, // Celestial Wings
            "wings_red": .legendary // Phoenix Wings and Blazing Phoenix
        ]
        
        // Check for exact matches first
        for (key, rarity) in rarityMappings {
            if name.contains(key) {
                return rarity
            }
        }
        
        // Fallback to old logic for other items
        if name.contains("legendary") || name.contains("firelord") || name.contains("deadly") {
            return .legendary
        } else if name.contains("epic") || name.contains("fire") || name.contains("iron") || name.contains("assassin") {
            return .epic
        } else if name.contains("rare") || name.contains("copper") || name.contains("red") || name.contains("wings") {
            return .rare
        } else if name.contains("uncommon") || name.contains("hoodie") || name.contains("punk") || name.contains("blue") || name.contains("green") {
            return .uncommon
        }
        
        return .common
    }

    // MARK: - Asset Validation

    /// Checks if an asset exists in the bundle
    func assetExists(named imageName: String) -> Bool {
        return UIImage(named: imageName) != nil
    }

    /// Gets fallback asset for category
    func getFallbackAsset(for category: AssetCategory) -> String {
        switch category {
        case .bodyType: return BodyType.bodyWhite.rawValue
        case .hairStyle: return HairStyle.hair1Brown.rawValue
        case .hairBackStyle: return ""
        case .hairColor: return HairColor.brown.rawValue
        case .eyeColor: return EyeColor.eyeBlack.rawValue
        case .outfit: return Outfit.outfitVillager.rawValue
        case .weapon: return CharacterWeapon.swordWood.rawValue
        case .accessory: return ""
        case .head: return ""
        case .headGear: return ""
        case .shield: return ""
        case .wings: return ""
        case .mustache: return ""
        case .flower: return ""
        case .pet: return ""
        }
    }

    /// Gets the default asset for a category
    func getDefaultAssetForCategory(_ category: AssetCategory) -> String {
        switch category {
        case .bodyType: return BodyType.bodyWhite.rawValue
        case .hairStyle: return HairStyle.hair1Brown.rawValue
        case .hairBackStyle: return ""
        case .hairColor: return HairColor.brown.rawValue
        case .eyeColor: return EyeColor.eyeBlack.rawValue
        case .outfit: return Outfit.outfitVillager.rawValue
        case .weapon: return CharacterWeapon.swordWood.rawValue
        case .accessory: return ""
        case .head: return ""
        case .headGear: return ""
        case .shield: return ""
        case .wings: return ""
        case .mustache: return ""
        case .flower: return ""
        case .pet: return ""
        }
    }

    // MARK: - Cache Management

    /// Clears the asset cache
    func clearCache() {
        cacheQueue.async { [weak self] in
            self?.imageCache.removeAll()
        }
    }

    /// Gets cache size information
    func getCacheInfo() -> (count: Int, estimatedSizeKB: Int) {
        let count = imageCache.count
        let estimatedSize = count * 50 // Rough estimate of 50KB per image
        return (count: count, estimatedSizeKB: estimatedSize)
    }
}

// MARK: - Asset Item Model

struct AssetItem: Identifiable, Hashable {
    let id: String
    let name: String
    let imageName: String
    let previewImage: String
    let category: AssetCategory
    let rarity: AssetRarity
    var isUnlocked: Bool = false
    var isEquipped: Bool = false
    var price: Int = 0

    var basePrice: Int {
        return Int(50.0 * rarity.basePriceMultiplier)
    }
}

// MARK: - Asset Loading Extensions

extension CharacterAssetManager {
    /// Batch loads multiple assets
    func preloadAssets(_ assetNames: [String], completion: @escaping () -> Void) {
        cacheQueue.async { [weak self] in
            for assetName in assetNames {
                _ = self?.loadAsset(named: assetName)
            }

            DispatchQueue.main.async {
                completion()
            }
        }
    }

    /// Preloads assets for a specific category
    func preloadCategory(_ category: AssetCategory, completion: @escaping () -> Void) {
        let assets = getAvailableAssets(for: category)
        let assetNames = assets.map { $0.imageName }.filter { !$0.isEmpty }
        preloadAssets(assetNames, completion: completion)
    }

    /// Preloads all character customization assets
    func preloadAllCustomizationAssets(completion: @escaping () -> Void) {
        cacheQueue.async { [weak self] in
            for category in AssetCategory.allCases {
                let assets = self?.getAvailableAssets(for: category) ?? []
                for asset in assets {
                    if !asset.imageName.isEmpty {
                        _ = self?.loadAsset(named: asset.imageName)
                    }
                }
            }

            DispatchQueue.main.async {
                completion()
            }
        }
    }
}
