//
//  BuildingBoosterManager.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 6.08.2025.
//

import Foundation

// MARK: - Building Booster Manager

final class BuildingBoosterManager: ObservableObject {
    static let shared = BuildingBoosterManager()
    
    private let baseBuildingService: BaseBuildingService
    private var boosterManager: BoosterManager?
    
    private init() {
        self.baseBuildingService = BaseBuildingService(context: PersistenceController.shared.container.viewContext)
        // Don't access BoosterManager.shared during init to avoid circular dependency
        self.boosterManager = nil
        setupObservers()
        
        // Initialize boosterManager and refresh boosters after initialization
        DispatchQueue.main.async { [weak self] in
            self?.boosterManager = BoosterManager.shared
            self?.refreshBuildingBoosters()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public Methods
    
    func refreshBuildingBoosters() {
        print("🏗️ BuildingBoosterManager: refreshBuildingBoosters called")
        calculateBuildingBoosters()
    }
    
    // MARK: - Private Methods
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBuildingUpdate),
            name: .buildingUpdated,
            object: nil
        )
    }
    
    @objc private func handleBuildingUpdate() {
        DispatchQueue.main.async { [weak self] in
            self?.refreshBuildingBoosters()
        }
    }
    
        private func calculateBuildingBoosters() {
        guard let boosterManager = boosterManager else {
            print("🏗️ BuildingBoosterManager: BoosterManager not available yet")
            return
        }
        
        print("🏗️ BuildingBoosterManager: Starting building booster calculation")

        // Clear all existing building boosters first
        boosterManager.clearAllBuildingBoosters()

        let base = baseBuildingService.loadBase()
        let activeBuildings = base.buildings.filter { $0.state == .active }

        print("🏗️ BuildingBoosterManager: Found \(activeBuildings.count) active buildings out of \(base.buildings.count) total buildings")
        for building in base.buildings {
            print("🏗️ BuildingBoosterManager: Building \(building.type.rawValue) - State: \(building.state), Level: \(building.level)")
        }

        for building in activeBuildings {
            print("🏗️ BuildingBoosterManager: Processing building \(building.type.rawValue) (Level \(building.level))")
            let booster = createBuildingBooster(for: building)
            if let booster = booster {
                print("🏗️ BuildingBoosterManager: Adding booster for \(booster.sourceName) - \(booster.type.rawValue) x\(booster.multiplier)")
                boosterManager.addBuildingBooster(
                    type: booster.type,
                    multiplier: booster.multiplier,
                    flatBonus: booster.flatBonus,
                    buildingId: booster.sourceId,
                    buildingName: booster.sourceName
                )
            }
        }

        print("🏗️ BuildingBoosterManager: Total boosters after calculation: \(boosterManager.activeBoosters.filter { $0.source == .building }.count)")
        print("🏗️ BuildingBoosterManager: All active boosters: \(boosterManager.activeBoosters.map { "\($0.sourceName) (Level \($0.sourceId.components(separatedBy: "_").last ?? "?"))" })")

        // Force UI update by posting notification
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .boostersUpdated, object: nil)
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
                sourceId: "\(building.type.rawValue)_\(building.level)",
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
                sourceId: "\(building.type.rawValue)_\(building.level)",
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
                sourceId: "\(building.type.rawValue)_\(building.level)",
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
                sourceId: "\(building.type.rawValue)_\(building.level)",
                sourceName: "Tower (Lv.\(building.level))"
            )
        }
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let buildingUpdated = Notification.Name("buildingUpdated")
}
