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
    case item = "item"
    case temporary = "temporary"
    
    var displayName: String {
        switch self {
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
    let sourceId: String // Item id
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
    private static var _shared: BoosterManager?
    private static let lock = NSLock()
    
    static var shared: BoosterManager {
        lock.lock()
        defer { lock.unlock() }
        
        if _shared == nil {
            _shared = BoosterManager()
            print("🚀 BoosterManager: Singleton initialized")
        }
        return _shared!
    }
    
    @Published var activeBoosters: [BoosterEffect] = []
    @Published var totalExperienceMultiplier: Double = 1.0
    @Published var totalCoinsMultiplier: Double = 1.0
    @Published var totalExperienceBonus: Int = 0
    @Published var totalCoinsBonus: Int = 0
    
    private lazy var inventoryManager: InventoryManager = {
        return InventoryManager.shared
    }()
    private var cleanupTimer: Timer?
    
    private init() {
        setupObservers()
        setupCleanupTimer()
        // Don't call refreshBoosters() during init to avoid circular dependency
        // Item boosters will be loaded separately after initialization
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
    
    /// Refreshes boosters when active effects are loaded from persistence
    func refreshBoostersFromPersistence() {
        print("🚀 BoosterManager: Refreshing boosters from persistence")
        calculateItemBoosters()
        updateTotalBoosters()
        print("🚀 BoosterManager: Refreshed boosters from persistence - Total: \(activeBoosters.count)")
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
    
    
    func removeBooster(id: UUID) {
        activeBoosters.removeAll { $0.id == id }
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
        // Clean up expired boosters and effects every minute
        cleanupTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.clearExpiredBoosters()
            
            // Also clear expired effects from persistence
            let activeEffectsService = ActiveEffectsCoreDataService()
            activeEffectsService.clearExpiredEffects()
            
            // Refresh boosters after clearing expired effects
            self?.refreshBoosters()
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
        print("🚀 BoosterManager: updateTotalBoosters called")
        
        // First, clear expired boosters
        clearExpiredBoosters()
        
        // Reset totals
        totalExperienceMultiplier = 1.0
        totalCoinsMultiplier = 1.0
        totalExperienceBonus = 0
        totalCoinsBonus = 0
        
        // Get all active boosters (excluding expired ones)
        let activeBoosters = self.activeBoosters.filter { $0.isActive && !$0.isExpired }
        
        // Calculate total experience boosters by adding percentages
        let expBoosters = activeBoosters.filter { $0.type == .experience || $0.type == .both }
        var totalExpPercentage = 0.0
        for booster in expBoosters {
            // Convert multiplier to percentage and add it
            let percentage = (booster.multiplier - 1.0) * 100.0
            totalExpPercentage += percentage
            totalExperienceBonus += booster.flatBonus
        }
        // Convert total percentage back to multiplier
        totalExperienceMultiplier = 1.0 + (totalExpPercentage / 100.0)
        
        // Calculate total coin boosters by adding percentages
        let coinBoosters = activeBoosters.filter { $0.type == .coins || $0.type == .both }
        var totalCoinPercentage = 0.0
        for booster in coinBoosters {
            // Convert multiplier to percentage and add it
            let percentage = (booster.multiplier - 1.0) * 100.0
            totalCoinPercentage += percentage
            totalCoinsBonus += booster.flatBonus
        }
        // Convert total percentage back to multiplier
        totalCoinsMultiplier = 1.0 + (totalCoinPercentage / 100.0)
        
        // Force UI update and post notification for UI updates
        print("🚀 BoosterManager: Sending objectWillChange and boostersUpdated notification")
        objectWillChange.send()
        NotificationCenter.default.post(name: .boostersUpdated, object: nil)
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let boosterAdded = Notification.Name("boosterAdded")
    static let boostersUpdated = Notification.Name("boostersUpdated")
}
