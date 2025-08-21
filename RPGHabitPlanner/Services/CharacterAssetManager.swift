//
//  CharacterAssetManager.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 7.01.2025.
//

import Foundation
import SwiftUI

// MARK: - Asset Category Enum

enum AssetCategory: String, CaseIterable, Identifiable {
    case bodyType = "BodyType"
    case skinColor = "SkinColor"
    case hairStyle = "HairStyle"
    case hairColor = "HairColor"
    case eyeColor = "EyeColor"
    case outfit = "Outfit"
    case weapon = "Weapon"
    case accessory = "Accessory"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .bodyType: return "Body Type"
        case .skinColor: return "Skin Color"
        case .hairStyle: return "Hair Style"
        case .hairColor: return "Hair Color"
        case .eyeColor: return "Eye Color"
        case .outfit: return "Outfit"
        case .weapon: return "Weapon"
        case .accessory: return "Accessory"
        }
    }
    
    var icon: String {
        switch self {
        case .bodyType: return "person.fill"
        case .skinColor: return "paintpalette.fill"
        case .hairStyle: return "scissors"
        case .hairColor: return "paintbrush.fill"
        case .eyeColor: return "eye.fill"
        case .outfit: return "tshirt.fill"
        case .weapon: return "sword.fill"
        case .accessory: return "crown.fill"
        }
    }
}

// MARK: - Asset Rarity Enum

enum AssetRarity: String, CaseIterable, Identifiable {
    case common = "Common"
    case uncommon = "Uncommon"
    case rare = "Rare"
    case epic = "Epic"
    case legendary = "Legendary"
    
    var id: String { rawValue }
    
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
                // Default body types
                BodyType.body1.rawValue,
                BodyType.body2.rawValue,
                
                // Default hair styles
                HairStyle.brown1.rawValue,
                HairStyle.brown2.rawValue,
                
                // Default outfits
                Outfit.simple.rawValue,
                Outfit.hoodie.rawValue,
                
                // Default weapons
                CharacterWeapon.swordDaggerWood.rawValue,
                CharacterWeapon.swordDagger.rawValue,
                
                // Default eye colors
                EyeColor.brown.rawValue,
                EyeColor.blue.rawValue
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
        case .skinColor:
            return SkinColor.allCases.map { AssetItem(id: $0.rawValue, name: $0.displayName, imageName: "", category: category, rarity: .common) }
        case .hairStyle:
            return HairStyle.allCases.map { AssetItem(id: $0.rawValue, name: $0.displayName, imageName: $0.rawValue, category: category, rarity: getRarity(for: $0.rawValue)) }
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
        case .bodyType: return BodyType.body1.rawValue
        case .skinColor: return SkinColor.light.rawValue
        case .hairStyle: return HairStyle.brown1.rawValue
        case .hairColor: return HairColor.brown.rawValue
        case .eyeColor: return EyeColor.brown.rawValue
        case .outfit: return Outfit.simple.rawValue
        case .weapon: return CharacterWeapon.swordDaggerWood.rawValue
        case .accessory: return ""
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