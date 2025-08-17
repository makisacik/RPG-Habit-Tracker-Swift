//
//  BoosterSystem.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import Foundation

// MARK: - Booster Types

enum BoosterType: String, CaseIterable, Codable {
    case experience = "experience"
    case coins = "coins"
    case both = "both"
    
    var displayName: String {
        switch self {
        case .experience: return "Experience"
        case .coins: return "Coins"
        case .both: return "Both"
        }
    }
    
    var description: String {
        switch self {
        case .experience: return "Increases experience gained from quests"
        case .coins: return "Increases coins gained from quests"
        case .both: return "Increases both experience and coins gained from quests"
        }
    }
}

// MARK: - Booster Source

enum BoosterSource: String, CaseIterable, Codable {
    case building = "building"
    case item = "item"
    case temporary = "temporary"
    
    var displayName: String {
        switch self {
        case .building: return "Building"
        case .item: return "Item"
        case .temporary: return "Temporary"
        }
    }
}

// MARK: - Booster Effect

struct BoosterEffect: Identifiable, Codable {
    let id: UUID
    let type: BoosterType
    let source: BoosterSource
    let multiplier: Double
    let flatBonus: Int
    let sourceId: String // Building type or item id
    let sourceName: String
    let isActive: Bool
    let expiresAt: Date?
    
    init(
        id: UUID = UUID(),
        type: BoosterType,
        source: BoosterSource,
        multiplier: Double = 1.0,
        flatBonus: Int = 0,
        sourceId: String,
        sourceName: String,
        isActive: Bool = true,
        expiresAt: Date? = nil
    ) {
        self.id = id
        self.type = type
        self.source = source
        self.multiplier = multiplier
        self.flatBonus = flatBonus
        self.sourceId = sourceId
        self.sourceName = sourceName
        self.isActive = isActive
        self.expiresAt = expiresAt
    }
    
    var isExpired: Bool {
        guard let expiresAt = expiresAt else { return false }
        return Date() > expiresAt
    }
    
    var totalBonus: Double {
        return multiplier
    }
    
    var description: String {
        var desc = "\(sourceName) provides "
        
        if multiplier > 1.0 {
            let percentage = Int((multiplier - 1.0) * 100)
            desc += "+\(percentage)% "
        }
        
        if flatBonus > 0 {
            desc += "+\(flatBonus) "
        }
        
        desc += type.displayName.lowercased()
        return desc
    }
}

// MARK: - Booster Manager

final class BoosterManager: ObservableObject {
    static let shared = BoosterManager()
    
    @Published var activeBoosters: [BoosterEffect] = []
    @Published var totalExperienceMultiplier: Double = 1.0
    @Published var totalCoinsMultiplier: Double = 1.0
    @Published var totalExperienceBonus: Int = 0
    @Published var totalCoinsBonus: Int = 0
    
    private let baseBuildingService: BaseBuildingService
    private let inventoryManager: InventoryManager
    
    private init() {
        self.baseBuildingService = BaseBuildingService(context: PersistenceController.shared.container.viewContext)
        self.inventoryManager = InventoryManager.shared
        setupObservers()
        refreshBoosters()
    }
    
    // MARK: - Public Methods
    
    func refreshBoosters() {
        calculateBuildingBoosters()
        calculateItemBoosters()
        updateTotalBoosters()
    }
    
    func calculateBoostedRewards(baseExperience: Int, baseCoins: Int) -> (experience: Int, coins: Int) {
        let boostedExperience = Int(Double(baseExperience) * totalExperienceMultiplier) + totalExperienceBonus
        let boostedCoins = Int(Double(baseCoins) * totalCoinsMultiplier) + totalCoinsBonus
        
        return (experience: boostedExperience, coins: boostedCoins)
    }
    
    func getActiveBoosters(for type: BoosterType) -> [BoosterEffect] {
        // Create a local copy to avoid modification during iteration
        let currentBoosters = activeBoosters
        return currentBoosters.filter { booster in
            booster.isActive && !booster.isExpired &&
            (booster.type == type || booster.type == .both)
        }
    }
    
    func addTemporaryBooster(
        type: BoosterType,
        multiplier: Double,
        flatBonus: Int = 0,
        duration: TimeInterval,
        sourceName: String
    ) {
        let booster = BoosterEffect(
            type: type,
            source: .temporary,
            multiplier: multiplier,
            flatBonus: flatBonus,
            sourceId: UUID().uuidString,
            sourceName: sourceName,
            expiresAt: Date().addingTimeInterval(duration)
        )
        
        activeBoosters.append(booster)
        updateTotalBoosters()
    }
    
    func removeBooster(id: UUID) {
        activeBoosters.removeAll { $0.id == id }
        updateTotalBoosters()
    }
    
    func clearExpiredBoosters() {
        activeBoosters.removeAll { $0.isExpired }
        // Don't call updateTotalBoosters() here to avoid infinite recursion
        // The calling method will handle updating totals
    }
    
    // MARK: - Private Methods
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserUpdate),
            name: .userDidUpdate,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBuildingUpdate),
            name: .buildingUpdated,
            object: nil
        )
    }
    
    @objc private func handleUserUpdate() {
        DispatchQueue.main.async { [weak self] in
            self?.refreshBoosters()
        }
    }
    
    @objc private func handleBuildingUpdate() {
        DispatchQueue.main.async { [weak self] in
            self?.refreshBoosters()
        }
    }
    
    private func calculateBuildingBoosters() {
        // Remove existing building boosters
        activeBoosters.removeAll { $0.source == .building }
        
        let base = baseBuildingService.loadBase()
        let activeBuildings = base.buildings.filter { $0.state == .active }
        
        for building in activeBuildings {
            let booster = createBuildingBooster(for: building)
            if let booster = booster {
                activeBoosters.append(booster)
            }
        }
    }
    
    private func createBuildingBooster(for building: Building) -> BoosterEffect? {
        switch building.type {
        case .castle:
            // Castle provides coin boost
            let multiplier = 1.0 + (Double(building.level) * 0.1) // +10% per level
            let flatBonus = building.level * 5 // +5 coins per level
            return BoosterEffect(
                type: .coins,
                source: .building,
                multiplier: multiplier,
                flatBonus: flatBonus,
                sourceId: building.type.rawValue,
                sourceName: "Castle (Lv.\(building.level))"
            )
            
        case .house:
            // House provides experience boost
            let multiplier = 1.0 + (Double(building.level) * 0.15) // +15% per level
            let flatBonus = building.level * 3 // +3 exp per level
            return BoosterEffect(
                type: .experience,
                source: .building,
                multiplier: multiplier,
                flatBonus: flatBonus,
                sourceId: building.type.rawValue,
                sourceName: "House (Lv.\(building.level))"
            )
            
        case .goldmine:
            // Goldmine provides additional coin boost
            let multiplier = 1.0 + (Double(building.level) * 0.05) // +5% per level
            let flatBonus = building.level * 2 // +2 coins per level
            return BoosterEffect(
                type: .coins,
                source: .building,
                multiplier: multiplier,
                flatBonus: flatBonus,
                sourceId: building.type.rawValue,
                sourceName: "Gold Mine (Lv.\(building.level))"
            )
            
        case .tower, .tower2:
            // Towers provide small experience boost
            let multiplier = 1.0 + (Double(building.level) * 0.08) // +8% per level
            let flatBonus = building.level * 1 // +1 exp per level
            return BoosterEffect(
                type: .experience,
                source: .building,
                multiplier: multiplier,
                flatBonus: flatBonus,
                sourceId: building.type.rawValue,
                sourceName: "Tower (Lv.\(building.level))"
            )
        }
    }
    
    private func calculateItemBoosters() {
        // Remove existing item boosters
        activeBoosters.removeAll { $0.source == .item }
        
        // Get active effects from inventory manager
        let activeEffects = inventoryManager.activeEffects
        
        for effect in activeEffects {
            if let booster = createItemBooster(from: effect) {
                activeBoosters.append(booster)
            }
        }
    }
    
    private func createItemBooster(from effect: ActiveEffect) -> BoosterEffect? {
        // This would be implemented based on your item system
        // For now, we'll create a placeholder implementation
        guard effect.isActive else { return nil }
        
        // Check if the effect is an XP boost
        if effect.effect.type == .xpBoost {
            let multiplier = 1.0 + (Double(effect.effect.value) / 100.0) // Convert percentage to multiplier
            return BoosterEffect(
                type: .experience,
                source: .item,
                multiplier: multiplier,
                flatBonus: 0,
                sourceId: effect.sourceItemId.uuidString,
                sourceName: "XP Boost Item",
                expiresAt: effect.endTime
            )
        }
        
        // Check if the effect is a coin boost
        if effect.effect.type == .coinBoost {
            let multiplier = 1.0 + (Double(effect.effect.value) / 100.0) // Convert percentage to multiplier
            return BoosterEffect(
                type: .coins,
                source: .item,
                multiplier: multiplier,
                flatBonus: 0,
                sourceId: effect.sourceItemId.uuidString,
                sourceName: "Coin Boost Item",
                expiresAt: effect.endTime
            )
        }
        
        return nil
    }
    
    private func updateTotalBoosters() {
        // First, clear expired boosters
        clearExpiredBoosters()
        
        // Reset totals
        totalExperienceMultiplier = 1.0
        totalCoinsMultiplier = 1.0
        totalExperienceBonus = 0
        totalCoinsBonus = 0
        
        // Get all active boosters (excluding expired ones)
        let activeBoosters = self.activeBoosters.filter { $0.isActive && !$0.isExpired }
        
        // Calculate total experience boosters
        let expBoosters = activeBoosters.filter { $0.type == .experience || $0.type == .both }
        for booster in expBoosters {
            totalExperienceMultiplier *= booster.multiplier
            totalExperienceBonus += booster.flatBonus
        }
        
        // Calculate total coin boosters
        let coinBoosters = activeBoosters.filter { $0.type == .coins || $0.type == .both }
        for booster in coinBoosters {
            totalCoinsMultiplier *= booster.multiplier
            totalCoinsBonus += booster.flatBonus
        }
    }
}

// MARK: - Extensions

// Note: ActiveEffect extensions have been removed as they're no longer needed
// The booster logic is now handled directly in createItemBooster method

// MARK: - Notifications

extension Notification.Name {
    static let buildingUpdated = Notification.Name("buildingUpdated")
}
