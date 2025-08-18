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
    let startTime: Date
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
        startTime: Date = Date(),
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
        self.startTime = startTime
        self.expiresAt = expiresAt
    }
    
    var isExpired: Bool {
        guard let expiresAt = expiresAt else { return false }
        return Date() > expiresAt
    }
    
    var remainingTime: TimeInterval? {
        guard let expiresAt = expiresAt else { return nil }
        let remaining = expiresAt.timeIntervalSince(Date())
        return remaining > 0 ? remaining : nil
    }

    var progress: Double {
        guard let expiresAt = expiresAt else { return 1.0 }
        let totalDuration = expiresAt.timeIntervalSince(startTime)
        let elapsed = Date().timeIntervalSince(startTime)
        return min(1.0, max(0.0, elapsed / totalDuration))
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
    
    private lazy var inventoryManager = InventoryManager.shared
    private var cleanupTimer: Timer?
    
    private init() {
        setupObservers()
        setupCleanupTimer()
        refreshBoosters()
    }
    
    deinit {
        cleanupTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public Methods
    
    func refreshBoosters() {
        calculateItemBoosters()
        updateTotalBoosters()
    }
    
    func calculateBoostedRewards(baseExperience: Int, baseCoins: Int) -> (experience: Int, coins: Int) {
        let boostedExperience = Int(Double(baseExperience) * totalExperienceMultiplier) + totalExperienceBonus
        let boostedCoins = Int(Double(baseCoins) * totalCoinsMultiplier) + totalCoinsBonus
        
        return (experience: boostedExperience, coins: boostedCoins)
    }
    
    func getActiveBoosters(for type: BoosterType) -> [BoosterEffect] {
        return activeBoosters.filter { booster in
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
        
        // Post notification for UI updates
        NotificationCenter.default.post(name: .boosterAdded, object: booster)
    }
    
    func addBuildingBooster(
        type: BoosterType,
        multiplier: Double,
        flatBonus: Int = 0,
        buildingId: String,
        buildingName: String
    ) {
        // Remove existing building booster with same ID
        activeBoosters.removeAll { $0.sourceId == buildingId }
        
        let booster = BoosterEffect(
            type: type,
            source: .building,
            multiplier: multiplier,
            flatBonus: flatBonus,
            sourceId: buildingId,
            sourceName: buildingName
        )
        
        activeBoosters.append(booster)
        updateTotalBoosters()
    }
    
    func removeBooster(id: UUID) {
        activeBoosters.removeAll { $0.id == id }
        updateTotalBoosters()
    }
    
    func removeBuildingBooster(buildingId: String) {
        activeBoosters.removeAll { $0.sourceId == buildingId }
        updateTotalBoosters()
    }
    
    func clearExpiredBoosters() {
        let expiredCount = activeBoosters.count
        activeBoosters.removeAll { $0.isExpired }
        
        if activeBoosters.count != expiredCount {
            updateTotalBoosters()
        }
    }
    
    // MARK: - Private Methods
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleActiveEffectsChanged),
            name: .activeEffectsChanged,
            object: nil
        )
    }
    
    private func setupCleanupTimer() {
        // Clean up expired boosters every minute
        cleanupTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.clearExpiredBoosters()
        }
    }
    
    @objc private func handleActiveEffectsChanged() {
        DispatchQueue.main.async { [weak self] in
            self?.refreshBoosters()
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
                startTime: effect.startTime,
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
                startTime: effect.startTime,
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
        
        // Post notification for UI updates
        NotificationCenter.default.post(name: .boostersUpdated, object: nil)
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let boosterAdded = Notification.Name("boosterAdded")
    static let boostersUpdated = Notification.Name("boostersUpdated")
}
