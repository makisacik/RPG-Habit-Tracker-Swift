import Foundation
import SwiftUI
import Combine

class BaseBuildingViewModel: ObservableObject {
    @Published var base = Base()
    @Published var selectedBuildingType: BuildingType?
    @Published var showingBuildingMenu = false
    @Published var showingBuildingDetails = false
    @Published var selectedBuilding: Building?
    @Published var selectedGridPosition: CGPoint = .zero
    @Published var totalGoldCollected = 0
    var currentCoins: Int {
        return currencyManager.currentCoins
    }
    @Published var showingVillageInfo = false
    
    private let baseService: BaseBuildingServiceProtocol
    private let currencyManager: CurrencyManager
    private var cancellables = Set<AnyCancellable>()
    private var constructionTimer: Timer?
    
    init(baseService: BaseBuildingServiceProtocol, userManager: UserManager) {
        self.baseService = baseService
        self.currencyManager = CurrencyManager.shared
        
        setupBindings()
        loadBase()
        startConstructionTimer()
    }
    
    deinit {
        constructionTimer?.invalidate()
    }
    
    // MARK: - Public Methods
    
    func loadBase() {
        base = baseService.loadBase()
        
        // Initialize village if it's empty
        if base.buildings.isEmpty {
            base.initializeVillage()
            baseService.saveBase(base)
        }
        
        calculateTotalGoldCollected()
        checkConstructionCompletion()
    }
    
    func canAffordBuilding(_ type: BuildingType) -> Bool {
        return currentCoins >= type.baseCost
    }
    
    func canAffordUpgrade(_ building: Building) -> Bool {
        return currentCoins >= building.upgradeCost
    }
    
    func buildStructure(_ type: BuildingType, at position: CGPoint) {
        guard canAffordBuilding(type) else { return }
        
        // Find the existing building at this position
        if let existingBuilding = base.getBuilding(at: position) {
            // Start construction on the existing building
            var updatedBuilding = existingBuilding
            updatedBuilding.state = .construction
            updatedBuilding.constructionStartTime = Date()
            
            // Deduct coins from user
            currencyManager.spendCoins(type.baseCost) { success, _ in
                if success {
                    // Update building in base
                    self.base.updateBuilding(updatedBuilding)
                    self.baseService.saveBase(self.base)

                    // Add experience for starting construction
                    self.base.addExperience(5)
                    self.baseService.saveBase(self.base)
                }
            }
        }
    }
    
        func upgradeBuilding(_ building: Building) {
        guard canAffordUpgrade(building) else { return }
        
        print("🏗️ Starting upgrade for \(building.type.rawValue) from level \(building.level) to level \(building.level + 1)")

        // Start upgrade construction
        var updatedBuilding = building
        updatedBuilding.state = .construction
        updatedBuilding.constructionStartTime = Date()
        
        currencyManager.spendCoins(building.upgradeCost) { success, _ in
            if success {
                self.base.updateBuilding(updatedBuilding)
                self.baseService.saveBase(self.base)

                // Add experience for starting upgrade
                self.base.addExperience(5)
                self.baseService.saveBase(self.base)

                // Note: Boosters will be refreshed when construction completes and building becomes active
                print("🏗️ Upgrade started successfully for \(building.type.rawValue)")
            }
        }
    }
    
    func selectBuilding(_ building: Building) {
        selectedBuilding = building
        showingBuildingDetails = true
    }
    
    func collectGold(from building: Building) {
        let goldAmount = baseService.collectGold(from: building)
        if goldAmount > 0 {
            currencyManager.addCoins(goldAmount) { error in
                if error == nil {
                    self.totalGoldCollected += goldAmount
                }
            }
        }
        loadBase()
    }
    
                func completeConstruction(for building: Building) {
        print("🏗️ completeConstruction called for \(building.type.rawValue) - Level: \(building.level), State: \(building.state)")

        // Check if this is an upgrade construction by looking at the construction start time
        // If the building was already active (level >= 1) and went into construction, it's an upgrade
        if building.state == .readyToComplete && building.level >= 1 && building.constructionStartTime != nil {
            // This is an upgrade completion
            var upgradedBuilding = building
            upgradedBuilding.state = .active
            upgradedBuilding.level += 1
            upgradedBuilding.constructionStartTime = nil

            // Add experience for completing upgrade
            base.addExperience(15)
            baseService.saveBase(base)

                        // Update the building
            print("🏗️ Before update - Building level: \(building.level)")
            base.updateBuilding(upgradedBuilding)
            baseService.saveBase(base)

            // Verify the update worked
            let updatedBase = baseService.loadBase()
            if let updatedBuilding = updatedBase.getBuilding(at: building.position) {
                print("🏗️ After update - Building level: \(updatedBuilding.level), State: \(updatedBuilding.state)")
            }

            print("🏗️ Building upgrade completed: \(building.type.rawValue) -> Level \(upgradedBuilding.level)")
            print("🏗️ Building state: \(upgradedBuilding.state), Level: \(upgradedBuilding.level)")
        } else {
            // Regular construction completion
            print("🏗️ Regular construction completion for \(building.type.rawValue)")
            baseService.completeConstruction(for: building)
        }

        // Refresh building boosters after construction completion
        print("🏗️ Refreshing building boosters...")
        BuildingBoosterManager.shared.refreshBuildingBoosters()

        // Post notification to update boosters
        print("🏗️ Posting notifications...")
        NotificationCenter.default.post(name: .buildingUpdated, object: nil)
        NotificationCenter.default.post(name: .boostersUpdated, object: nil)

        print("🏗️ Construction completed, boosters refreshed")

        // Update the local base to reflect changes
        self.base = baseService.loadBase()
    }
    
    func destroyBuilding(_ building: Building) {
        var updatedBuilding = building
        updatedBuilding.state = .destroyed
        updatedBuilding.level = 1
        base.updateBuilding(updatedBuilding)
        baseService.saveBase(base)

        // Refresh building boosters after destruction
        BuildingBoosterManager.shared.refreshBuildingBoosters()

        // Post notification to update boosters
        NotificationCenter.default.post(name: .buildingUpdated, object: nil)
        NotificationCenter.default.post(name: .boostersUpdated, object: nil)
    }
    
    func repairBuilding(_ building: Building) {
        let repairCost = building.type.baseCost / 2
        
        if currentCoins >= repairCost {
            currencyManager.spendCoins(repairCost) { success, _ in
                if success {
                    var updatedBuilding = building
                    updatedBuilding.state = .active
                    self.base.updateBuilding(updatedBuilding)
                    self.baseService.saveBase(self.base)

                    // Refresh building boosters after repair
                    BuildingBoosterManager.shared.refreshBuildingBoosters()

                    // Post notification to update boosters
                    NotificationCenter.default.post(name: .buildingUpdated, object: nil)
                    NotificationCenter.default.post(name: .boostersUpdated, object: nil)
                }
            }
        }
    }
    
    func getAvailableGold() -> Int {
        return currentCoins
    }
    
    func getBuildingAtPosition(_ position: CGPoint) -> Building? {
        return base.getBuilding(at: position)
    }
    
    func getFixedPositions(for screenSize: CGSize) -> [BuildingType: CGPoint] {
        return VillageLayout.getFixedPositions(for: screenSize)
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        // Listen for user updates
        NotificationCenter.default.publisher(for: .userDidUpdate)
            .sink { [weak self] _ in
                // CurrencyManager will automatically update its published property
                // No need to manually reload coins
            }
            .store(in: &cancellables)
        
        // Observe currency manager's published property
        currencyManager.$currentCoins
            .sink { [weak self] newCoins in
                // Trigger UI update when coins change
                print("🏗️ BaseBuildingViewModel: Currency changed to \(newCoins), triggering UI update")
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    
    private func calculateTotalGoldCollected() {
        totalGoldCollected = base.totalGoldGeneration
    }
    
    private func startConstructionTimer() {
        constructionTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkConstructionCompletion()
        }
    }
    
    private func checkConstructionCompletion() {
        var hasChanges = false
        
        for building in base.buildings where building.state == .construction {
            if building.isConstructionComplete {
                var updatedBuilding = building
                updatedBuilding.state = .readyToComplete
                base.updateBuilding(updatedBuilding)
                hasChanges = true
            }
        }
        
        if hasChanges {
            baseService.saveBase(base)
            objectWillChange.send()
            print("🏗️ Construction state changed to readyToComplete")
        }
    }
    
    // MARK: - Village Management
    
    struct VillageStats {
        let active: Int
        let construction: Int
        let destroyed: Int
        let totalGold: Int
    }
    
    func getVillageStats() -> VillageStats {
        return VillageStats(
            active: base.activeBuildings.count,
            construction: base.constructionBuildings.count,
            destroyed: base.destroyedBuildings.count,
            totalGold: base.totalGoldGeneration
        )
    }
    
    func getVillageProgress() -> Double {
        let totalBuildings = BuildingType.allCases.count
        let activeBuildings = base.activeBuildings.count
        return Double(activeBuildings) / Double(totalBuildings)
    }
}
