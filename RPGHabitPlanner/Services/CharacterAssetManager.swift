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
    case wings = "Wings"
    case mustache = "Mustache"
    case flower = "Flower"
    case pet = "Pet"

    public var id: String { rawValue }

    var displayName: String {
        switch self {
        case .bodyType: return "Body Type"
        case .hairStyle: return "Hair Style"
        case .hairBackStyle: return "Hair Back Style"
        case .hairColor: return "Hair Color"
        case .eyeColor: return "Eye Color"
        case .outfit: return "Outfit"
        case .weapon: return "Weapon"
        case .accessory: return "Accessory"
        case .head: return "Head"
        case .wings: return "Wings"
        case .mustache: return "Mustache"
        case .flower: return "Flower"
        case .pet: return "Pet"
        }
    }

    var icon: String {
        switch self {
        case .bodyType: return "person.fill"
        case .hairStyle: return "scissors"
        case .hairBackStyle: return "scissors"
        case .hairColor: return "paintbrush.fill"
        case .eyeColor: return "eye.fill"
        case .outfit: return "tshirt.fill"
        case .weapon: return "sword.fill"
        case .accessory: return "crown.fill"
        case .head: return "helmet"
        case .wings: return "airplane"
        case .mustache: return "mustache"
        case .flower: return "leaf.fill"
        case .pet: return "pawprint.fill"
        }
    }
}

// MARK: - Asset Rarity Enum

public enum AssetRarity: String, CaseIterable, Identifiable {
    case common = "Common"
    case uncommon = "Uncommon"
    case rare = "Rare"
    case epic = "Epic"
    case legendary = "Legendary"

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

    /// Gets all available assets for a category
    func getAvailableAssets(for category: AssetCategory) -> [AssetItem] {
        switch category {
        case .bodyType:
            return BodyType.allCases.map { AssetItem(id: $0.rawValue, name: $0.displayName, imageName: $0.rawValue, category: category, rarity: .common) }
        case .hairStyle:
            return HairStyle.allCases.map { AssetItem(id: $0.rawValue, name: $0.displayName, imageName: $0.rawValue, category: category, rarity: getRarity(for: $0.rawValue)) }
        case .hairBackStyle:
            return HairBackStyle.allCases.map { AssetItem(id: $0.rawValue, name: $0.displayName, imageName: $0.rawValue, category: category, rarity: getRarity(for: $0.rawValue)) }
        case .hairColor:
            return HairColor.allCases.map { AssetItem(id: $0.rawValue, name: $0.displayName, imageName: "", category: category, rarity: .common) }
        case .eyeColor:
            return EyeColor.allCases.map { AssetItem(id: $0.rawValue, name: $0.displayName, imageName: $0.rawValue, category: category, rarity: .common) }
        case .outfit:
            return Outfit.allCases.map { AssetItem(id: $0.rawValue, name: $0.displayName, imageName: $0.rawValue, category: category, rarity: getRarity(for: $0.rawValue)) }
        case .weapon:
            return CharacterWeapon.allCases.map { AssetItem(id: $0.rawValue, name: $0.displayName, imageName: $0.rawValue, category: category, rarity: getRarity(for: $0.rawValue)) }
        case .accessory:
            return Accessory.allCases.map { AssetItem(id: $0.rawValue, name: $0.displayName, imageName: $0.rawValue, category: category, rarity: getRarity(for: $0.rawValue)) }
        case .head:
            return [] // Head gear items will be handled separately
        case .wings:
            return [] // Wing items will be handled separately
        case .mustache:
            return Mustache.allCases.map { AssetItem(id: $0.rawValue, name: $0.displayName, imageName: $0.rawValue, category: category, rarity: getRarity(for: $0.rawValue)) }
        case .flower:
            return Flower.allCases.map { AssetItem(id: $0.rawValue, name: $0.displayName, imageName: $0.rawValue, category: category, rarity: getRarity(for: $0.rawValue)) }
        case .pet:
            return Pet.allCases.map { AssetItem(id: $0.rawValue, name: $0.displayName, imageName: $0.rawValue, category: category, rarity: getRarity(for: $0.rawValue)) }
        }
    }

    /// Gets all available assets for a category with preview images (for shop and onboarding)
    func getAvailableAssetsWithPreview(for category: AssetCategory) -> [AssetItem] {
        switch category {
        case .bodyType:
            return BodyType.allCases.map { AssetItem(id: $0.rawValue, name: $0.displayName, imageName: $0.previewImageName, category: category, rarity: .common) }
        case .hairStyle:
            return HairStyle.allCases.map { AssetItem(id: $0.rawValue, name: $0.displayName, imageName: $0.previewImageName, category: category, rarity: getRarity(for: $0.rawValue)) }
        case .hairBackStyle:
            return HairBackStyle.allCases.map { AssetItem(id: $0.rawValue, name: $0.displayName, imageName: $0.previewImageName, category: category, rarity: getRarity(for: $0.rawValue)) }
        case .hairColor:
            return HairColor.allCases.map { AssetItem(id: $0.rawValue, name: $0.displayName, imageName: "", category: category, rarity: .common) }
        case .eyeColor:
            return EyeColor.allCases.map { AssetItem(id: $0.rawValue, name: $0.displayName, imageName: $0.previewImageName, category: category, rarity: .common) }
        case .outfit:
            return Outfit.allCases.map { AssetItem(id: $0.rawValue, name: $0.displayName, imageName: $0.previewImageName, category: category, rarity: getRarity(for: $0.rawValue)) }
        case .weapon:
            return CharacterWeapon.allCases.map { AssetItem(id: $0.rawValue, name: $0.displayName, imageName: $0.previewImageName, category: category, rarity: getRarity(for: $0.rawValue)) }
        case .accessory:
            return Accessory.allCases.map { AssetItem(id: $0.rawValue, name: $0.displayName, imageName: $0.previewImageName, category: category, rarity: getRarity(for: $0.rawValue)) }
        case .head:
            return [] // Head gear items will be handled separately
        case .wings:
            return [] // Wing items will be handled separately
        case .mustache:
            return Mustache.allCases.map { AssetItem(id: $0.rawValue, name: $0.displayName, imageName: $0.previewImageName, category: category, rarity: getRarity(for: $0.rawValue)) }
        case .flower:
            return Flower.allCases.map { AssetItem(id: $0.rawValue, name: $0.displayName, imageName: $0.previewImageName, category: category, rarity: getRarity(for: $0.rawValue)) }
        case .pet:
            return Pet.allCases.map { AssetItem(id: $0.rawValue, name: $0.displayName, imageName: $0.previewImageName, category: category, rarity: getRarity(for: $0.rawValue)) }
        }
    }

    /// Determines rarity based on asset name
    private func getRarity(for assetName: String) -> AssetRarity {
        let name = assetName.lowercased()

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
