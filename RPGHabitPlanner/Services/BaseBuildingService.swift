import Foundation
import Combine
import CoreData

protocol BaseBuildingServiceProtocol {
    func loadBase() -> Base
    func saveBase(_ base: Base)
    func addBuilding(_ building: Building)
    func removeBuilding(_ building: Building)
    func updateBuilding(_ building: Building)
    func collectGold(from building: Building) -> Int
    func checkConstructionProgress()
}

class BaseBuildingService: BaseBuildingServiceProtocol, ObservableObject {
    @Published var base = Base()
    private let context: NSManagedObjectContext
    private var timer: Timer?
    
    init(context: NSManagedObjectContext) {
        self.context = context
        loadBaseFromCoreData()
        startConstructionTimer()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - Public Methods
    
    func loadBase() -> Base {
        return base
    }
    
    func saveBase(_ base: Base) {
        self.base = base
        saveBaseToCoreData()
    }
    
    func addBuilding(_ building: Building) {
        var newBuilding = building
        if newBuilding.state == .construction {
            newBuilding.constructionStartTime = Date()
        }
        base.addBuilding(newBuilding)
        saveBaseToCoreData()
    }
    
    func removeBuilding(_ building: Building) {
        base.removeBuilding(building)
        saveBaseToCoreData()
    }
    
    func updateBuilding(_ building: Building) {
        base.updateBuilding(building)
        saveBaseToCoreData()
    }
    
    func collectGold(from building: Building) -> Int {
        guard building.canGenerateGold else { return 0 }
        
        var updatedBuilding = building
        updatedBuilding.lastGoldGeneration = Date()
        updateBuilding(updatedBuilding)
        
        return building.goldGenerationRate
    }
    
    func checkConstructionProgress() {
        var hasChanges = false
        
        for building in base.buildings {
            if building.state == .construction && building.isConstructionComplete {
                var updatedBuilding = building
                updatedBuilding.state = .active
                base.updateBuilding(updatedBuilding)
                hasChanges = true
            }
        }
        
        if hasChanges {
            saveBaseToCoreData()
        }
    }
    
    // MARK: - Private Methods
    
    private func loadBaseFromCoreData() {
        let fetchRequest: NSFetchRequest<TownEntity> = TownEntity.fetchRequest()

        do {
            let towns = try context.fetch(fetchRequest)
            if let town = towns.first {
                base = town.toBase()
            } else {
                // Create default town if none exists
                createDefaultTown()
            }
        } catch {
            print("Error loading town from Core Data: \(error)")
            createDefaultTown()
        }
    }

    private func saveBaseToCoreData() {
        let fetchRequest: NSFetchRequest<TownEntity> = TownEntity.fetchRequest()

        do {
            let towns = try context.fetch(fetchRequest)
            let town: TownEntity

            if let existingTown = towns.first {
                town = existingTown
            } else {
                town = TownEntity(context: context)
                town.id = UUID()
                town.createdAt = Date()
            }

            // Update town from base
            town.updateFromBase(base)

            // Update buildings
            updateBuildingsInCoreData(for: town)

            try context.save()
        } catch {
            print("Error saving town to Core Data: \(error)")
        }
    }

    private func updateBuildingsInCoreData(for town: TownEntity) {
        // Remove existing buildings
        if let existingBuildings = town.buildings?.allObjects as? [BuildingEntity] {
            for building in existingBuildings {
                context.delete(building)
            }
        }

        // Add current buildings
        for building in base.buildings {
            let buildingEntity = BuildingEntity(context: context)
            buildingEntity.updateFromBuilding(building)
            buildingEntity.town = town
        }
    }

    private func createDefaultTown() {
        base = Base()
        base.initializeVillage()
        saveBaseToCoreData()
    }

    private func startConstructionTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkConstructionProgress()
        }
    }
}
