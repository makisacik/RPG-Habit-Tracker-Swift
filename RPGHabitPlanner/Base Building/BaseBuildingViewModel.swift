import Foundation
import SwiftUI
import Combine

class BaseBuildingViewModel: ObservableObject {
    @Published var base = Base()
    @Published var selectedBuildingType: BuildingType?
    @Published var selectedBuildingColor: BuildingColor = .blue
    @Published var showingBuildingMenu = false
    @Published var showingBuildingDetails = false
    @Published var selectedBuilding: Building?
    @Published var selectedGridPosition: CGPoint = .zero
    @Published var totalGoldCollected = 0
    @Published var currentCoins = 0
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
        loadCurrentCoins()
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
            updatedBuilding.color = selectedBuildingColor
            
            // Deduct coins from user
            currencyManager.spendCoins(type.baseCost) { success, _ in
                if success {
                    // Update building in base
                    self.base.updateBuilding(updatedBuilding)
                    self.baseService.saveBase(self.base)
                    
                    // Add experience for starting construction
                    self.base.addExperience(5)
                    self.baseService.saveBase(self.base)
                    
                    // Reload coins
                    self.loadCurrentCoins()
                }
            }
        }
    }
    
    func upgradeBuilding(_ building: Building) {
        guard canAffordUpgrade(building) else { return }
        
        var updatedBuilding = building
        updatedBuilding.level += 1
        
        currencyManager.spendCoins(building.upgradeCost) { success, _ in
            if success {
                self.base.updateBuilding(updatedBuilding)
                self.baseService.saveBase(self.base)
                
                // Add experience for upgrading
                self.base.addExperience(15)
                self.baseService.saveBase(self.base)
                
                self.loadCurrentCoins()
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
                    self.loadCurrentCoins()
                }
            }
        }
        loadBase()
    }
    
    func destroyBuilding(_ building: Building) {
        var updatedBuilding = building
        updatedBuilding.state = .destroyed
        updatedBuilding.level = 1
        base.updateBuilding(updatedBuilding)
        baseService.saveBase(base)
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
                    self.loadCurrentCoins()
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
    
    func getFixedPositions() -> [BuildingType: CGPoint] {
        return VillageLayout.getFixedPositions()
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        // Listen for user updates
        NotificationCenter.default.publisher(for: .userDidUpdate)
            .sink { [weak self] _ in
                self?.loadCurrentCoins()
            }
            .store(in: &cancellables)
    }
    
    private func loadCurrentCoins() {
        currencyManager.getCurrentCoins { coins, _ in
            DispatchQueue.main.async {
                self.currentCoins = coins
            }
        }
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
                updatedBuilding.state = .active
                base.updateBuilding(updatedBuilding)
                hasChanges = true
                
                // Add experience for completing construction
                base.addExperience(10)
            }
        }
        
        if hasChanges {
            baseService.saveBase(base)
            objectWillChange.send()
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
