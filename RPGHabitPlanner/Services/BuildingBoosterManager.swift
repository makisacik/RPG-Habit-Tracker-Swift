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
    private let boosterManager: BoosterManager
    
    private init() {
        self.baseBuildingService = BaseBuildingService(context: PersistenceController.shared.container.viewContext)
        self.boosterManager = BoosterManager.shared
        setupObservers()
        refreshBuildingBoosters()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public Methods
    
    func refreshBuildingBoosters() {
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
        let base = baseBuildingService.loadBase()
        let activeBuildings = base.buildings.filter { $0.state == .active }
        
        for building in activeBuildings {
            let booster = createBuildingBooster(for: building)
            if let booster = booster {
                boosterManager.addBuildingBooster(
                    type: booster.type,
                    multiplier: booster.multiplier,
                    flatBonus: booster.flatBonus,
                    buildingId: booster.sourceId,
                    buildingName: booster.sourceName
                )
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
}

// MARK: - Notifications

extension Notification.Name {
    static let buildingUpdated = Notification.Name("buildingUpdated")
}
