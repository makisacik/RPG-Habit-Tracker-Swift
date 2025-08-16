import Foundation
import SwiftUI

// MARK: - Building Types
enum BuildingType: String, CaseIterable, Codable {
    case house = "house"
    case castle = "castle"
    case tower = "tower"
    case goldmine = "goldmine"
    
    var displayName: String {
        switch self {
        case .house: return "House"
        case .castle: return "Castle"
        case .tower: return "Tower"
        case .goldmine: return "Gold Mine"
        }
    }
    
    var description: String {
        switch self {
        case .house: return "Provides shelter and basic resources"
        case .castle: return "Fortified structure for defense"
        case .tower: return "Watchtower for surveillance"
        case .goldmine: return "Generates gold over time"
        }
    }
    
    var baseCost: Int {
        switch self {
        case .house: return 1
        case .castle: return 1
        case .tower: return 1
        case .goldmine: return 1
        }
    }
    
    var constructionTime: TimeInterval {
        switch self {
        case .house: return 60 // 1 minute
        case .castle: return 300 // 5 minutes
        case .tower: return 180 // 3 minutes
        case .goldmine: return 120 // 2 minutes
        }
    }
    
    var iconName: String {
        switch self {
        case .house: return "house.fill"
        case .castle: return "building.2.fill"
        case .tower: return "building.columns.fill"
        case .goldmine: return "mountain.2.fill"
        }
    }
    
    var villagePosition: CGPoint {
        switch self {
        case .house: return CGPoint(x: 200, y: 200)
        case .castle: return CGPoint(x: 320, y: 250)
        case .tower: return CGPoint(x: 440, y: 200)
        case .goldmine: return CGPoint(x: 320, y: 400)
        }
    }
    
    var size: CGSize {
        switch self {
        case .house: return CGSize(width: 100, height: 100)
        case .castle: return CGSize(width: 140, height: 140)
        case .tower: return CGSize(width: 80, height: 120)
        case .goldmine: return CGSize(width: 100, height: 100)
        }
    }
}

// MARK: - Building States
enum BuildingState: String, CaseIterable, Codable {
    case destroyed = "destroyed"
    case construction = "construction"
    case active = "active"
    case inactive = "inactive"
    
    var displayName: String {
        switch self {
        case .destroyed: return "Destroyed"
        case .construction: return "Under Construction"
        case .active: return "Active"
        case .inactive: return "Inactive"
        }
    }
    
    var color: Color {
        switch self {
        case .destroyed: return .red
        case .construction: return .orange
        case .active: return .green
        case .inactive: return .gray
        }
    }
    
    var priority: Int {
        switch self {
        case .destroyed: return 0
        case .construction: return 1
        case .inactive: return 2
        case .active: return 3
        }
    }
}

// MARK: - Building Colors
enum BuildingColor: String, CaseIterable, Codable {
    case blue = "blue"
    case red = "red"
    case yellow = "yellow"
    case purple = "purple"
    
    var color: Color {
        switch self {
        case .blue: return .blue
        case .red: return .red
        case .yellow: return .yellow
        case .purple: return .purple
        }
    }
}

// MARK: - Building Model
struct Building: Identifiable, Codable {
    var id = UUID()
    let type: BuildingType
    var color: BuildingColor
    var state: BuildingState
    var position: CGPoint
    var constructionStartTime: Date?
    var lastGoldGeneration: Date?
    var level: Int = 1
    
    var isUnderConstruction: Bool {
        state == .construction
    }
    
    var constructionProgress: Double {
        guard let startTime = constructionStartTime else { return 0.0 }
        let elapsed = Date().timeIntervalSince(startTime)
        let total = type.constructionTime
        return min(elapsed / total, 1.0)
    }
    
    var isConstructionComplete: Bool {
        constructionProgress >= 1.0
    }
    
    var imageName: String {
        switch type {
        case .goldmine:
            return "goldmine_active"
        default:
            return "\(type.rawValue)_\(color.rawValue)"
        }
    }
    
    var constructionImageName: String {
        "\(type.rawValue)_construction"
    }
    
    var destroyedImageName: String {
        "\(type.rawValue)_destroyed"
    }
    
    var inactiveImageName: String {
        switch type {
        case .goldmine:
            return "goldmine_inactive"
        default:
            return "\(type.rawValue)_inactive"
        }
    }
    
    var currentImageName: String {
        switch state {
        case .destroyed:
            return destroyedImageName
        case .construction:
            return constructionImageName
        case .active:
            return imageName
        case .inactive:
            return inactiveImageName
        }
    }
    
    // Gold generation for goldmines
    var goldGenerationRate: Int {
        guard type == .goldmine && state == .active else { return 0 }
        return 10 * level // 10 gold per hour per level
    }
    
    var canGenerateGold: Bool {
        guard type == .goldmine && state == .active else { return false }
        guard let lastGeneration = lastGoldGeneration else { return true }
        return Date().timeIntervalSince(lastGeneration) >= 3600 // 1 hour
    }
    
    var upgradeCost: Int {
        return type.baseCost * level
    }
    
    var canUpgrade: Bool {
        return state == .active && level < 5
    }
}

// MARK: - Village Layout
struct VillageLayout {
    static let gridSize: CGFloat = 80
    static let villageSize = CGSize(width: 640, height: 520)
    
    static func getFixedPositions() -> [BuildingType: CGPoint] {
        var positions: [BuildingType: CGPoint] = [:]
        for buildingType in BuildingType.allCases {
            positions[buildingType] = buildingType.villagePosition
        }
        return positions
    }
    
    static func getBuildingAtPosition(_ position: CGPoint) -> BuildingType? {
        let fixedPositions = getFixedPositions()
        for (type, fixedPosition) in fixedPositions {
            let distance = sqrt(pow(position.x - fixedPosition.x, 2) + pow(position.y - fixedPosition.y, 2))
            if distance < gridSize / 2 {
                return type
            }
        }
        return nil
    }
}

// MARK: - Base Model
struct Base: Codable {
    var buildings: [Building] = []
    var level: Int = 1
    var experience: Int = 0
    var maxBuildings: Int = 4
    var villageName: String = "Adventure Village"
    
    var experienceToNextLevel: Int {
        level * 100
    }
    
    var canAddBuilding: Bool {
        buildings.count < maxBuildings
    }
    
    var activeBuildings: [Building] {
        buildings.filter { $0.state == .active }
    }
    
    var constructionBuildings: [Building] {
        buildings.filter { $0.state == .construction }
    }
    
    var destroyedBuildings: [Building] {
        buildings.filter { $0.state == .destroyed }
    }
    
    var inactiveBuildings: [Building] {
        buildings.filter { $0.state == .inactive }
    }
    
    var totalGoldGeneration: Int {
        activeBuildings
            .filter { $0.type == .goldmine }
            .reduce(0) { total, building in
                total + building.goldGenerationRate
            }
    }
    
    mutating func addBuilding(_ building: Building) {
        buildings.append(building)
        checkLevelUp()
    }
    
    mutating func removeBuilding(_ building: Building) {
        buildings.removeAll { $0.id == building.id }
    }
    
    mutating func updateBuilding(_ building: Building) {
        if let index = buildings.firstIndex(where: { $0.id == building.id }) {
            buildings[index] = building
        }
    }
    
    mutating func checkLevelUp() {
        let requiredExp = experienceToNextLevel
        if experience >= requiredExp {
            level += 1
            experience -= requiredExp
            maxBuildings = min(maxBuildings + 1, 8)
        }
    }
    
    mutating func addExperience(_ amount: Int) {
        experience += amount
        checkLevelUp()
    }
    
    func getBuilding(at position: CGPoint) -> Building? {
        return buildings.first { building in
            let distance = sqrt(pow(building.position.x - position.x, 2) + pow(building.position.y - position.y, 2))
            return distance < VillageLayout.gridSize / 2
        }
    }
    
    mutating func initializeVillage() {
        let fixedPositions = VillageLayout.getFixedPositions()
        buildings = []
        
        for (type, position) in fixedPositions {
            let building = Building(
                type: type,
                color: .blue, // Default color
                state: .destroyed, // Start with destroyed buildings
                position: position
            )
            buildings.append(building)
        }
    }
}
