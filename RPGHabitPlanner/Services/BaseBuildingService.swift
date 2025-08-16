import Foundation
import Combine

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
    private let userDefaults = UserDefaults.standard
    private let baseKey = "user_base"
    private var timer: Timer?
    
    init() {
        loadBaseFromStorage()
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
        saveBaseToStorage()
    }
    
    func addBuilding(_ building: Building) {
        var newBuilding = building
        if newBuilding.state == .construction {
            newBuilding.constructionStartTime = Date()
        }
        base.addBuilding(newBuilding)
        saveBaseToStorage()
    }
    
    func removeBuilding(_ building: Building) {
        base.removeBuilding(building)
        saveBaseToStorage()
    }
    
    func updateBuilding(_ building: Building) {
        base.updateBuilding(building)
        saveBaseToStorage()
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
            saveBaseToStorage()
        }
    }
    
    // MARK: - Private Methods
    
    private func loadBaseFromStorage() {
        if let data = userDefaults.data(forKey: baseKey),
           let loadedBase = try? JSONDecoder().decode(Base.self, from: data) {
            base = loadedBase
        }
    }
    
    private func saveBaseToStorage() {
        if let data = try? JSONEncoder().encode(base) {
            userDefaults.set(data, forKey: baseKey)
        }
    }
    
    private func startConstructionTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkConstructionProgress()
        }
    }
}
